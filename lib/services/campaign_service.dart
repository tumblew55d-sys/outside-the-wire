import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'campaign_feed_service.dart';
import 'firebase_service.dart';

/// Campaign data layout in Firestore:
///   campaigns/{id}                 name, gmId, gmName, joinCode, memberIds
///   campaigns/{id}/shared/{charId} characterId, ownerId, ownerName,
///                                  characterName, subtitle, sharedAt
///   campaignCodes/{joinCode}       campaignId, gmId, name  (get-only lookup)
/// Shared characters stay in `characters/{id}`; the owner adds the GM's uid to
/// the character's `sharedGmIds` so the GM can read (never write) it live.
class CampaignService {
  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static User? get _user => FirebaseAuth.instance.currentUser;

  static String get currentUid {
    final u = _user;
    if (u == null) throw StateError('Sign in to use campaigns');
    return u.uid;
  }

  static String get _displayName {
    final u = _user;
    final n = u?.displayName;
    if (n != null && n.trim().isNotEmpty) return n;
    final email = u?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'Player';
  }

  static String normalizeCode(String raw) =>
      raw.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  static String _randomCode() {
    final r = Random.secure();
    return List.generate(
      6,
      (_) => _codeChars[r.nextInt(_codeChars.length)],
    ).join();
  }

  /// Creates a campaign and returns its join code.
  static Future<String> createCampaign(String name) async {
    final uid = currentUid;
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Campaign name is required');

    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _randomCode();
      final codeRef = _db.collection('campaignCodes').doc(code);
      final campaignRef = _db.collection('campaigns').doc();
      try {
        await _db.runTransaction((tx) async {
          final existing = await tx.get(codeRef);
          if (existing.exists) throw _CodeTaken();
          tx.set(campaignRef, {
            'name': trimmed,
            'gmId': uid,
            'gmName': _displayName,
            'joinCode': code,
            'memberIds': <String>[],
            'createdAt': FieldValue.serverTimestamp(),
          });
          tx.set(codeRef, {
            'campaignId': campaignRef.id,
            'gmId': uid,
            'name': trimmed,
          });
        });
        return code;
      } on _CodeTaken {
        continue;
      }
    }
    throw StateError('Could not generate a unique join code. Try again.');
  }

  static Stream<List<Map<String, dynamic>>> gmCampaigns() => _db
      .collection('campaigns')
      .where('gmId', isEqualTo: currentUid)
      .snapshots()
      .map(_withIds);

  static Stream<List<Map<String, dynamic>>> joinedCampaigns() => _db
      .collection('campaigns')
      .where('memberIds', arrayContains: currentUid)
      .snapshots()
      .map(_withIds);

  static List<Map<String, dynamic>> _withIds(
    QuerySnapshot<Map<String, dynamic>> s,
  ) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList();

  static Stream<List<Map<String, dynamic>>> sharedCharacters(
    String campaignId,
  ) => _db
      .collection('campaigns')
      .doc(campaignId)
      .collection('shared')
      .snapshots()
      .map(_withIds);

  /// Shares [characterId] into the campaign identified by [rawCode].
  /// Returns the campaign name.
  static Future<String> joinAndShare({
    required String rawCode,
    required String characterId,
    required String characterName,
    required String subtitle,
  }) async {
    final code = normalizeCode(rawCode);
    if (code.isEmpty) throw ArgumentError('Enter a join code');

    final lookup = await _db.collection('campaignCodes').doc(code).get();
    if (!lookup.exists) throw StateError('No campaign found for that code');
    final campaignId = lookup.data()!['campaignId'] as String;
    final gmId = lookup.data()!['gmId'] as String;
    final name = (lookup.data()!['name'] ?? 'Campaign') as String;

    await shareCharacter(
      campaignId: campaignId,
      gmId: gmId,
      characterId: characterId,
      characterName: characterName,
      subtitle: subtitle,
    );
    return name;
  }

  /// Adds the character to a campaign the user already belongs to or is
  /// joining. Order matters: the character must grant the GM read access
  /// before the campaign data points at it.
  /// Uploads the on-device copy to the cloud (claiming it for this account if
  /// it was made while signed out) so it can be shared.
  static Future<void> _uploadLocalCopy(String characterId, String uid) async {
    final box = Hive.box('characters');
    dynamic key = characterId;
    dynamic raw = box.get(key);
    if (raw == null) {
      for (final k in box.keys) {
        final v = box.get(k);
        if (v is Map && v['id']?.toString() == characterId) {
          raw = v;
          key = k;
          break;
        }
      }
    }
    if (raw is! Map) return;
    final data = Map<String, dynamic>.from(raw);
    final owner = (data['userId'] ?? '').toString();
    if (owner.isNotEmpty && owner != uid) return;
    data['userId'] = uid;
    await FirebaseService.saveCharacterToCloud(characterId, data);
    await box.put(key, data);
  }

  static Future<void> shareCharacter({
    required String campaignId,
    required String gmId,
    required String characterId,
    required String characterName,
    required String subtitle,
  }) async {
    final uid = currentUid;
    final charRef = _db.collection('characters').doc(characterId);
    await _uploadLocalCopy(characterId, uid);
    final charSnap = await charRef.get();
    if (!charSnap.exists || charSnap.data()?['userId'] != uid) {
      throw StateError('This character could not be uploaded to your account.');
    }
    await charRef.update({
      'sharedGmIds': FieldValue.arrayUnion([gmId]),
    });

    final campaignRef = _db.collection('campaigns').doc(campaignId);
    await campaignRef.update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });
    await campaignRef.collection('shared').doc(characterId).set({
      'characterId': characterId,
      'ownerId': uid,
      'ownerName': _displayName,
      'characterName': characterName,
      'subtitle': subtitle,
      'sharedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Adds an uploaded PDF/image (e.g. an NPC sheet made elsewhere) to the
  /// campaign. Anyone in the campaign, including the GM, can do this.
  static Future<void> shareSheetFile({
    required String campaignId,
    required String displayName,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final error = CampaignFeedService.validateFile(fileName, bytes.length);
    if (error != null) throw ArgumentError(error);
    final uid = currentUid;
    final name = displayName.trim().isEmpty ? fileName : displayName.trim();
    final campaignRef = _db.collection('campaigns').doc(campaignId);
    final doc = campaignRef.collection('shared').doc();
    final contentType = CampaignFeedService.contentTypeFor(fileName)!;
    final path =
        'campaign_files/$campaignId/$uid/'
        'sheet_${doc.id}_${CampaignFeedService.safeFileName(fileName)}';
    final ref = FirebaseStorage.instance.ref(path);
    final gmId = await gmIdOf(campaignId);
    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: contentType,
        customMetadata: {'gmId': gmId},
      ),
    );
    try {
      final url = await ref.getDownloadURL();
      await campaignRef.update({
        'memberIds': FieldValue.arrayUnion([uid]),
      });
      await doc.set({
        'kind': 'file',
        'characterId': doc.id,
        'ownerId': uid,
        'ownerName': _displayName,
        'characterName': name.length > 100 ? name.substring(0, 100) : name,
        'subtitle': 'Uploaded sheet',
        'fileName': fileName,
        'contentType': contentType,
        'fileUrl': url,
        'storagePath': path,
        'sharedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await ref.delete().catchError((_) {});
      rethrow;
    }
  }

  static Future<void> _deleteSheetFile(Map<String, dynamic> entry) async {
    final path = entry['storagePath'];
    if (path is String && path.isNotEmpty) {
      await FirebaseStorage.instance.ref(path).delete().catchError((_) {});
    }
  }

  /// Player removes one of their characters from a campaign.
  static Future<void> unshareCharacter({
    required String campaignId,
    required String gmId,
    required String characterId,
    Map<String, dynamic>? entry,
  }) async {
    final campaignRef = _db.collection('campaigns').doc(campaignId);
    await campaignRef.collection('shared').doc(characterId).delete();
    if (entry?['kind'] == 'file') {
      await _deleteSheetFile(entry!);
    } else {
      await _revokeAccessIfUnused(gmId: gmId, characterId: characterId);
    }
    await _dropMembershipIfNoCharacters(campaignRef, currentUid);
  }

  /// GM removes a player's character from the campaign.
  static Future<void> removeSharedCharacter({
    required String campaignId,
    required String characterId,
    required String ownerId,
    Map<String, dynamic>? entry,
  }) async {
    final campaignRef = _db.collection('campaigns').doc(campaignId);
    await campaignRef.collection('shared').doc(characterId).delete();
    if (entry?['kind'] == 'file') {
      await _deleteSheetFile(entry!);
    } else {
      await _revokeGmAccess(characterId, excludeCampaignId: campaignId);
    }
    final remaining = await campaignRef
        .collection('shared')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (remaining.docs.isEmpty) {
      await campaignRef.update({
        'memberIds': FieldValue.arrayRemove([ownerId]),
      });
    }
  }

  static Future<void> deleteCampaign(String campaignId, String joinCode) async {
    final campaignRef = _db.collection('campaigns').doc(campaignId);
    final shared = await campaignRef.collection('shared').get();
    for (final d in shared.docs) {
      final data = d.data();
      if (data['kind'] == 'file') {
        await _deleteSheetFile(data);
      } else {
        await _revokeGmAccess(d.id, excludeCampaignId: campaignId);
      }
      await d.reference.delete();
    }
    await _db.collection('campaignCodes').doc(joinCode).delete();
    await campaignRef.delete();
  }

  static Future<String> gmIdOf(String campaignId) async {
    try {
      final snap = await _db.collection('campaigns').doc(campaignId).get();
      return (snap.data()?['gmId'] ?? '').toString();
    } catch (_) {
      return '';
    }
  }

  /// Run by the GM: drops their own access to a character unless it is still
  /// shared into another of their campaigns.
  static Future<void> _revokeGmAccess(
    String characterId, {
    required String excludeCampaignId,
  }) async {
    final gmId = currentUid;
    final others = await _db
        .collection('campaigns')
        .where('gmId', isEqualTo: gmId)
        .get();
    for (final c in others.docs) {
      if (c.id == excludeCampaignId) continue;
      final s = await c.reference.collection('shared').doc(characterId).get();
      if (s.exists) return;
    }
    await _db
        .collection('characters')
        .doc(characterId)
        .update({
          'sharedGmIds': FieldValue.arrayRemove([gmId]),
        })
        .catchError((_) {});
  }

  // The GM keeps read access only while the character is still shared into
  // another campaign run by that same GM.
  static Future<void> _revokeAccessIfUnused({
    required String gmId,
    required String characterId,
  }) async {
    final mine = await _db
        .collection('campaigns')
        .where('memberIds', arrayContains: currentUid)
        .get();
    for (final c in mine.docs) {
      if (c.data()['gmId'] != gmId) continue;
      final shared = await c.reference
          .collection('shared')
          .doc(characterId)
          .get();
      if (shared.exists) return;
    }
    await _db.collection('characters').doc(characterId).update({
      'sharedGmIds': FieldValue.arrayRemove([gmId]),
    });
  }

  static Future<void> _dropMembershipIfNoCharacters(
    DocumentReference<Map<String, dynamic>> campaignRef,
    String uid,
  ) async {
    final mine = await campaignRef
        .collection('shared')
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();
    if (mine.docs.isEmpty) {
      await campaignRef.update({
        'memberIds': FieldValue.arrayRemove([uid]),
      });
    }
  }

  static Stream<Map<String, dynamic>?> watchCharacterJson(String characterId) =>
      _db
          .collection('characters')
          .doc(characterId)
          .snapshots()
          .map((s) => s.data());
}

class _CodeTaken implements Exception {}
