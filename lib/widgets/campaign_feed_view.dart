import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/campaign_feed_service.dart';
import '../services/campaign_service.dart';

/// Chat-style feed for a campaign: messages, screenshots/PDFs and dice rolls.
class CampaignFeedView extends StatefulWidget {
  final String campaignId;
  final bool isGm;

  const CampaignFeedView({
    super.key,
    required this.campaignId,
    required this.isGm,
  });

  @override
  State<CampaignFeedView> createState() => _CampaignFeedViewState();
}

class _CampaignFeedViewState extends State<CampaignFeedView> {
  final _text = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _run(Future<void> Function() action, String failPrefix) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on ArgumentError catch (e) {
      _toast(e.message.toString());
    } catch (e) {
      _toast('$failPrefix: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() => _run(() async {
    final t = _text.text;
    if (t.trim().isEmpty) return;
    await CampaignFeedService.postMessage(widget.campaignId, t);
    _text.clear();
  }, 'Could not post');

  Future<void> _roll(DiceKind kind) => _run(() async {
    final note = _text.text;
    await CampaignFeedService.postRoll(widget.campaignId, kind, note: note);
    _text.clear();
  }, 'Could not roll');

  Future<void> _attach() => _run(() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: CampaignFeedService.allowedTypes.keys.toList(),
      withData: true,
    );
    final file = result?.files.single;
    if (file == null) return;
    final bytes = file.bytes;
    if (bytes == null) throw ArgumentError('Could not read that file.');
    await CampaignFeedService.postFile(
      widget.campaignId,
      fileName: file.name,
      bytes: bytes,
      note: _text.text,
    );
    _text.clear();
  }, 'Could not upload');

  Future<void> _delete(Map<String, dynamic> post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This removes it for everyone in the campaign.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _run(
      () => CampaignFeedService.deletePost(widget.campaignId, post),
      'Could not delete',
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = CampaignService.currentUid;
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: CampaignFeedService.watchFeed(widget.campaignId),
            builder: (context, snap) {
              if (snap.hasError) {
                return Center(
                  child: Text('Could not load feed: ${snap.error}'),
                );
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final posts = snap.data!;
              if (posts.isEmpty) {
                return const Center(
                  child: Text(
                    'Nothing posted yet. Roll some dice or share a file.',
                  ),
                );
              }
              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: posts.length,
                itemBuilder: (context, i) {
                  final p = posts[i];
                  final canDelete = widget.isGm || p['authorId'] == uid;
                  return FeedPostCard(
                    post: p,
                    onDelete: canDelete ? () => _delete(p) : null,
                  );
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Attach image or PDF (5 MB max)',
                    icon: const Icon(Icons.attach_file),
                    onPressed: _busy ? null : _attach,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _text,
                      maxLength: CampaignFeedService.maxTextLength,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Message or note for a roll / file',
                        counterText: '',
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send',
                    icon: const Icon(Icons.send),
                    onPressed: _busy ? null : _send,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final k in DiceKind.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.casino),
                        label: Text('ROLL ${k.label}'),
                        onPressed: _busy ? null : () => _roll(k),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FeedPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback? onDelete;

  const FeedPostCard({super.key, required this.post, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final type = post['type'];
    final text = (post['text'] ?? '').toString();
    final ts = post['createdAt'];
    final time = ts != null && ts.toDate != null
        ? TimeOfDay.fromDateTime(ts.toDate()).format(context)
        : '';

    Widget body;
    if (type == 'roll') {
      body = _RollBody(roll: Map<String, dynamic>.from(post['roll'] as Map));
    } else if (type == 'file') {
      body = _FileBody(post: post);
    } else {
      body = const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${post['authorName'] ?? 'Player'}  $time',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB8956A),
                    ),
                  ),
                ),
                if (onDelete != null)
                  InkWell(
                    onTap: onDelete,
                    child: const Icon(Icons.delete_outline, size: 18),
                  ),
              ],
            ),
            if (type != 'message') ...[const SizedBox(height: 6), body],
            if (text.isNotEmpty) ...[const SizedBox(height: 6), Text(text)],
          ],
        ),
      ),
    );
  }
}

class _RollBody extends StatelessWidget {
  final Map<String, dynamic> roll;
  const _RollBody({required this.roll});

  @override
  Widget build(BuildContext context) {
    final kind = (roll['kind'] ?? '').toString().toUpperCase();
    final dice = (roll['dice'] as List).cast<num>();
    return Row(
      children: [
        const Icon(Icons.casino, size: 20),
        const SizedBox(width: 8),
        Text('Rolled $kind: ', style: const TextStyle(fontSize: 15)),
        for (final d in dice)
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF4A5D3E), width: 2),
            ),
            child: Text(
              '$d',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        if (dice.length > 1)
          Text(
            '= ${roll['total']}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}

class _FileBody extends StatelessWidget {
  final Map<String, dynamic> post;
  const _FileBody({required this.post});

  Future<void> _open(BuildContext context) async {
    final ok = await launchUrl(
      Uri.parse(post['fileUrl'] as String),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open the file.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isImage = (post['contentType'] ?? '').toString().startsWith('image/');
    final name = (post['fileName'] ?? 'file').toString();
    if (isImage) {
      return GestureDetector(
        onTap: () => _open(context),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: Image.network(
            post['fileUrl'] as String,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
            errorBuilder: (_, __, ___) => Text('Could not load image: $name'),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      icon: const Icon(Icons.picture_as_pdf),
      label: Text(name, overflow: TextOverflow.ellipsis),
      onPressed: () => _open(context),
    );
  }
}
