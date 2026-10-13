import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'campaign_service.dart';

enum DiceKind {
  d10('1d10', 1, 10, '1D10'),
  twoD10('2d10', 2, 10, '2D10');

  final String id;
  final int count;
  final int sides;
  final String label;
  const DiceKind(this.id, this.count, this.sides, this.label);
}

/// Campaign feed: chat-style posts, file uploads and dice rolls.
///   campaigns/{id}/feed/{postId}
///     type: 'message' | 'file' | 'roll'
///     authorId, authorName, text, createdAt (server time)
///     file posts: fileUrl, fileName, contentType, storagePath
///     roll posts: roll { kind, dice[], total }
class CampaignFeedService {
  static const maxFileBytes = 5 * 1024 * 1024;
  static const maxTextLength = 500;
  static const allowedTypes = {
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'pdf': 'application/pdf',
  };

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _feed(String campaignId) =>
      _db.collection('campaigns').doc(campaignId).collection('feed');

  static String get _authorName {
    final u = FirebaseAuth.instance.currentUser;
    final n = u?.displayName;
    if (n != null && n.trim().isNotEmpty) return n;
    final email = u?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'Player';
  }

  /// Rolls the dice. Pure so it can be unit tested with a seeded [Random].
  static List<int> rollDice(DiceKind kind, Random rng) =>
      List.generate(kind.count, (_) => rng.nextInt(kind.sides) + 1);

  static String? contentTypeFor(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0) return null;
    return allowedTypes[fileName.substring(dot + 1).toLowerCase()];
  }

  /// Returns an error message if the file can't be uploaded, otherwise null.
  static String? validateFile(String fileName, int size) {
    if (contentTypeFor(fileName) == null) {
      return 'Only PNG, JPG and PDF files can be shared.';
    }
    if (size <= 0) return 'That file is empty.';
    if (size > maxFileBytes) return 'Files must be 5 MB or smaller.';
    return null;
  }

  static String safeFileName(String name) =>
      name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  static String _clampText(String text) {
    final t = text.trim();
    return t.length > maxTextLength ? t.substring(0, maxTextLength) : t;
  }

  static Stream<List<Map<String, dynamic>>> watchFeed(String campaignId) =>
      _feed(campaignId)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots()
          .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());

  static Future<void> postMessage(String campaignId, String text) async {
    final t = _clampText(text);
    if (t.isEmpty) return;
    await _feed(campaignId).add({
      'type': 'message',
      'authorId': CampaignService.currentUid,
      'authorName': _authorName,
      'text': t,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<int>> postRoll(
    String campaignId,
    DiceKind kind, {
    String note = '',
    Random? rng,
  }) async {
    final dice = rollDice(kind, rng ?? Random.secure());
    await _feed(campaignId).add({
      'type': 'roll',
      'authorId': CampaignService.currentUid,
      'authorName': _authorName,
      'text': _clampText(note),
      'roll': {
        'kind': kind.id,
        'dice': dice,
        'total': dice.fold<int>(0, (a, b) => a + b),
      },
      'createdAt': FieldValue.serverTimestamp(),
    });
    return dice;
  }

  static Future<void> postFile(
    String campaignId, {
    required String fileName,
    required Uint8List bytes,
    String note = '',
  }) async {
    final error = validateFile(fileName, bytes.length);
    if (error != null) throw ArgumentError(error);
    final uid = CampaignService.currentUid;
    final contentType = contentTypeFor(fileName)!;
    final doc = _feed(campaignId).doc();
    final path =
        'campaign_files/$campaignId/$uid/${doc.id}_${safeFileName(fileName)}';
    final ref = FirebaseStorage.instance.ref(path);
    final gmId = await CampaignService.gmIdOf(campaignId);
    await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType, customMetadata: {'gmId': gmId}),
    );
    try {
      final url = await ref.getDownloadURL();
      await doc.set({
        'type': 'file',
        'authorId': uid,
        'authorName': _authorName,
        'text': _clampText(note),
        'fileName': fileName,
        'contentType': contentType,
        'fileUrl': url,
        'storagePath': path,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      await ref.delete().catchError((_) {});
      rethrow;
    }
  }

  static Future<void> deletePost(
    String campaignId,
    Map<String, dynamic> post,
  ) async {
    final path = post['storagePath'];
    if (path is String && path.isNotEmpty) {
      await FirebaseStorage.instance.ref(path).delete().catchError((_) {});
    }
    await _feed(campaignId).doc(post['id'] as String).delete();
  }

  /// Removes every feed post and uploaded file for a campaign (GM only).
  static Future<void> deleteAll(String campaignId) async {
    final posts = await _feed(campaignId).get();
    for (final p in posts.docs) {
      final path = p.data()['storagePath'];
      if (path is String && path.isNotEmpty) {
        await FirebaseStorage.instance.ref(path).delete().catchError((_) {});
      }
      await p.reference.delete();
    }
  }
}
