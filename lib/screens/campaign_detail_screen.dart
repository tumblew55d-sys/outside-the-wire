import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/character.dart';
import '../services/campaign_feed_service.dart';
import '../services/campaign_service.dart';
import '../widgets/campaign_feed_view.dart';
import '../widgets/character_sheet_preview.dart';
import 'campaigns_screen.dart';

/// Shows the characters shared into one campaign.
/// The GM can open each as a read-only live sheet and remove characters;
/// players can see the party and un-share their own characters.
class CampaignDetailScreen extends StatelessWidget {
  final Map<String, dynamic> campaign;
  final bool isGm;

  const CampaignDetailScreen({
    super.key,
    required this.campaign,
    required this.isGm,
  });

  String get _id => campaign['id'] as String;
  String get _gmId => campaign['gmId'] as String;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text((campaign['name'] ?? 'Campaign').toString()),
          actions: [
            if (isGm)
              IconButton(
                tooltip: 'Delete campaign',
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteCampaign(context),
              ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.groups), text: 'CHARACTERS'),
              Tab(icon: Icon(Icons.forum), text: 'FEED & DICE'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _charactersTab(context),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: CampaignFeedView(campaignId: _id, isGm: isGm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _charactersTab(BuildContext context) {
    final uid = CampaignService.currentUid;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add),
        label: Text(isGm ? 'ADD CHARACTER / NPC' : 'SHARE A CHARACTER'),
        onPressed: () => _addMenu(context),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              if (isGm) _JoinCodeBanner(code: campaign['joinCode'].toString()),
              _InstructionBox(isGm: isGm),
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: CampaignService.sharedCharacters(_id),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Center(child: Text('Error: ${snap.error}'));
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = snap.data!;
                    if (items.isEmpty) {
                      return const Center(
                        child: Text('No characters shared yet.'),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final s in items)
                          Card(
                            child: ListTile(
                              leading: Icon(
                                s['kind'] == 'file'
                                    ? (s['contentType'] == 'application/pdf'
                                        ? Icons.picture_as_pdf
                                        : Icons.image)
                                    : Icons.person,
                              ),
                              title: Text(
                                (s['characterName'] ?? 'Unnamed').toString(),
                              ),
                              subtitle: Text(
                                '${s['ownerId'] == _gmId ? 'GM / NPC' : 'Player: ${s['ownerName'] ?? ''}'}'
                                '${(s['subtitle'] ?? '').toString().isEmpty ? '' : ' • ${s['subtitle']}'}',
                              ),
                              onTap: s['kind'] == 'file'
                                  ? () => launchUrl(
                                      Uri.parse(s['fileUrl'] as String),
                                      mode: LaunchMode.externalApplication,
                                    )
                                  : (isGm || s['ownerId'] == uid)
                                  ? () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => SharedCharacterView(
                                          characterId:
                                              s['characterId'] as String,
                                        ),
                                      ),
                                    )
                                  : null,
                              trailing: (isGm || s['ownerId'] == uid)
                                  ? IconButton(
                                      tooltip: isGm
                                          ? 'Remove from campaign'
                                          : 'Leave campaign',
                                      icon: const Icon(Icons.logout),
                                      onPressed: () => _remove(context, s),
                                    )
                                  : null,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String title, String body) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _remove(BuildContext context, Map<String, dynamic> s) async {
    final name = (s['characterName'] ?? 'this character').toString();
    final ok = await _confirm(
      context,
      isGm ? 'Remove character?' : 'Leave campaign?',
      isGm
          ? 'Remove $name from this campaign?'
          : 'Stop sharing $name with this campaign?',
    );
    if (!ok || !context.mounted) return;
    try {
      if (isGm) {
        await CampaignService.removeSharedCharacter(
          campaignId: _id,
          characterId: s['characterId'] as String,
          ownerId: s['ownerId'] as String,
          entry: s,
        );
      } else {
        await CampaignService.unshareCharacter(
          campaignId: _id,
          gmId: _gmId,
          characterId: s['characterId'] as String,
          entry: s,
        );
        if (context.mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _deleteCampaign(BuildContext context) async {
    final ok = await _confirm(
      context,
      'Delete campaign?',
      'This removes the campaign and its join code for everyone.',
    );
    if (!ok || !context.mounted) return;
    try {
      await CampaignFeedService.deleteAll(_id);
      await CampaignService.deleteCampaign(
        _id,
        campaign['joinCode'].toString(),
      );
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _addMenu(BuildContext context) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(isGm ? 'Add character or NPC' : 'Add a character'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'saved'),
            child: const ListTile(
              leading: Icon(Icons.person),
              title: Text('From my saved characters'),
              subtitle: Text('Live, read-only sheet'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'file'),
            child: const ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('Upload a PDF or image'),
              subtitle: Text('NPC or sheet made elsewhere. PNG, JPG, PDF, max 5 MB'),
            ),
          ),
        ],
      ),
    );
    if (!context.mounted || choice == null) return;
    if (choice == 'saved') {
      await _shareAnother(context);
    } else {
      await _uploadSheet(context);
    }
  }

  Future<void> _uploadSheet(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: CampaignFeedService.allowedTypes.keys.toList(),
        withData: true,
      );
      final file = result?.files.single;
      if (file == null) return;
      final bytes = file.bytes;
      if (bytes == null) throw ArgumentError('Could not read that file.');
      if (!context.mounted) return;
      final defaultName = file.name.contains('.')
          ? file.name.substring(0, file.name.lastIndexOf('.'))
          : file.name;
      final controller = TextEditingController(text: defaultName);
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Name for this sheet'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 100,
            decoration: const InputDecoration(labelText: 'Character / NPC name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Upload'),
            ),
          ],
        ),
      );
      if (name == null) return;
      await CampaignService.shareSheetFile(
        campaignId: _id,
        displayName: name,
        fileName: file.name,
        bytes: bytes,
      );
      messenger.showSnackBar(const SnackBar(content: Text('Sheet uploaded.')));
    } on ArgumentError catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message.toString())));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not upload: $e')));
    }
  }

  Future<void> _shareAnother(BuildContext context) async {
    final choices = localCharacterChoices();
    if (choices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have no saved characters.')),
      );
      return;
    }
    final chosen = await showDialog<LocalCharacterChoice>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(isGm ? 'Add which character or NPC?' : 'Share which character?'),
        children: [
          for (final c in choices)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, c),
              child: Text(c.name),
            ),
        ],
      ),
    );
    if (chosen == null || !context.mounted) return;
    try {
      await CampaignService.shareCharacter(
        campaignId: _id,
        gmId: _gmId,
        characterId: chosen.id,
        characterName: chosen.name,
        subtitle: chosen.subtitle,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not share: $e')));
    }
  }
}

class _InstructionBox extends StatelessWidget {
  final bool isGm;
  const _InstructionBox({required this.isGm});

  @override
  Widget build(BuildContext context) {
    final steps = isGm
        ? 'GM: send the join code above to your players. They join with it '
            'and add their characters. Use ADD CHARACTER / NPC to add a saved '
            'character, or upload an NPC sheet as a PDF or image. Open the FEED & DICE tab (button above) '
            'to chat, roll dice and share images or PDFs.'
        : 'Players: get the join code from your GM, join, then add a character '
            'with SHARE A CHARACTER. Open the FEED & DICE tab (button above) '
            'to chat, roll dice and share files.';
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        border: Border.all(color: Colors.blueGrey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HOW IT WORKS',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(steps),
          const SizedBox(height: 8),
          const Text(
            'Allowed files: PNG, JPG/JPEG images and PDF documents, max 5 MB each. '
            'Word, Excel, ZIP and other file types are not accepted. NPCs made '
            'outside the generator can be added with Upload a PDF or image.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Cloud: a character must be saved to the cloud (signed in, not '
            'guest) to be shared. Shared characters are a live read-only link: '
            'the GM sees your latest saved changes.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _JoinCodeBanner extends StatelessWidget {
  final String code;
  const _JoinCodeBanner({required this.code});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF4A5D3E), width: 2),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'JOIN CODE: $code',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Copy code',
          icon: const Icon(Icons.copy),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Join code copied')));
          },
        ),
      ],
    ),
  );
}

/// Read-only live view of a shared character.
class SharedCharacterView extends StatelessWidget {
  final String characterId;
  const SharedCharacterView({super.key, required this.characterId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SHARED CHARACTER (READ ONLY)')),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: CampaignService.watchCharacterJson(characterId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(
              child: Text('You no longer have access to this character.'),
            );
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snap.data;
          if (data == null) {
            return const Center(child: Text('Character not found.'));
          }
          final character = Character.fromJson(Map<String, dynamic>.from(data));
          return Padding(
            padding: const EdgeInsets.all(16),
            child: CharacterSheetPreview(
              key: ValueKey(data.hashCode),
              character: character,
              readOnly: true,
            ),
          );
        },
      ),
    );
  }
}
