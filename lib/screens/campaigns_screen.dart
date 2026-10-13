import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/campaign_service.dart';
import 'campaign_detail_screen.dart';

/// Lists campaigns the user runs as GM and campaigns they have joined.
class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final signedIn = FirebaseAuth.instance.currentUser != null;
    return Scaffold(
      appBar: AppBar(title: const Text('CAMPAIGNS')),
      body: signedIn ? const _CampaignLists() : const _SignInPrompt(),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sign in to create or join campaigns.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/auth'),
                child: const Text('SIGN IN'),
              ),
            ],
          ),
        ),
      );
}

class _CampaignLists extends StatelessWidget {
  const _CampaignLists();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('CREATE CAMPAIGN (GM)'),
                  onPressed: () => _createCampaign(context),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.vpn_key),
                  label: const Text('JOIN WITH CODE'),
                  onPressed: () => _joinCampaign(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const _SectionTitle('CAMPAIGNS I RUN'),
            _CampaignStream(stream: CampaignService.gmCampaigns(), isGm: true),
            const SizedBox(height: 24),
            const _SectionTitle('CAMPAIGNS I JOINED'),
            _CampaignStream(
              stream: CampaignService.joinedCampaigns(),
              isGm: false,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCampaign(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Campaign'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Campaign name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty || !context.mounted) return;
    try {
      final code = await CampaignService.createCampaign(name);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Campaign created. Join code: $code')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create campaign: $e')),
      );
    }
  }

  Future<void> _joinCampaign(BuildContext context) async {
    final characters = localCharacterChoices();
    if (characters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have no saved characters to share yet.'),
        ),
      );
      return;
    }
    final codeController = TextEditingController();
    String selectedId = characters.first.id;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Join Campaign'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Join code'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedId,
                decoration: const InputDecoration(
                  labelText: 'Character to share',
                ),
                items: [
                  for (final c in characters)
                    DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => selectedId = v ?? selectedId),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
    if (result != true || !context.mounted) return;
    final chosen = characters.firstWhere((c) => c.id == selectedId);
    try {
      final name = await CampaignService.joinAndShare(
        rawCode: codeController.text,
        characterId: chosen.id,
        characterName: chosen.name,
        subtitle: chosen.subtitle,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${chosen.name} shared with $name')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not join: $e')),
      );
    }
  }
}

class LocalCharacterChoice {
  final String id;
  final String name;
  final String subtitle;
  const LocalCharacterChoice(this.id, this.name, this.subtitle);
}

/// Characters in the local roster that belong to the signed-in user.
List<LocalCharacterChoice> localCharacterChoices() {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final box = Hive.box('characters');
  final out = <LocalCharacterChoice>[];
  for (final key in box.keys) {
    final data = box.get(key);
    if (data is! Map) continue;
    final owner = (data['userId'] ?? '').toString();
    if (owner.isNotEmpty && owner != uid) continue;
    final name = (data['name'] ?? '').toString().trim();
    out.add(
      LocalCharacterChoice(
        (data['id'] ?? key).toString(),
        name.isEmpty ? 'Unnamed' : name,
        (data['nationality'] ?? '').toString(),
      ),
    );
  }
  out.sort((a, b) => a.name.compareTo(b.name));
  return out;
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Color(0xFFB8956A),
          ),
        ),
      );
}

class _CampaignStream extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> stream;
  final bool isGm;
  const _CampaignStream({required this.stream, required this.isGm});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return Text('Could not load campaigns: ${snap.error}');
        }
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.all(8),
            child: LinearProgressIndicator(),
          );
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return Text(
            isGm ? 'No campaigns yet.' : 'You have not joined any campaigns.',
            style: const TextStyle(color: Colors.white60),
          );
        }
        return Column(
          children: [
            for (final c in items)
              Card(
                child: ListTile(
                  leading: Icon(isGm ? Icons.military_tech : Icons.groups),
                  title: Text((c['name'] ?? 'Campaign').toString()),
                  subtitle: Text(
                    isGm
                        ? 'Join code: ${c['joinCode']}'
                        : 'GM: ${c['gmName'] ?? ''}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CampaignDetailScreen(
                        campaign: c,
                        isGm: isGm,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
