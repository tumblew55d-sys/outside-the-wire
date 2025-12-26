import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../theme/tactical_theme.dart';
import '../models/character.dart';
import '../services/storage_service.dart' as storage;

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  CharacterProfile _char = CharacterProfile();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loaded = await storage.AppStorageService.loadCharacter();
    if (loaded != null) {
      setState(() {
        _char = loaded;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<Uint8List> _buildPdf(CharacterProfile c) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context ctx) => [
          pw.Header(level: 0, child: pw.Text('OUTSIDE THE WIRE - CHARACTER SUMMARY')),
          pw.SizedBox(height: 8),
          pw.Text('Name: ${c.name}'),
          pw.Text('Service: ${c.serviceBranch}'),
          pw.Text('Rank: ${c.rankTitle}'),
          pw.Text('Specialty: ${c.militarySpecialty}'),
          pw.SizedBox(height: 8),
          pw.Text('Attributes:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Bullet(text: 'Strength: ${c.attributes[AttributeType.strength] ?? 0}'),
          pw.Bullet(text: 'Agility: ${c.attributes[AttributeType.agility] ?? 0}'),
          pw.Bullet(text: 'Wisdom: ${c.attributes[AttributeType.wisdom] ?? 0}'),
          pw.Bullet(text: 'Knowledge: ${c.attributes[AttributeType.knowledge] ?? 0}'),
          pw.SizedBox(height: 8),
          pw.Text('Skills:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Column(children: c.skills.entries.map((e) => pw.Text('${e.key}: ${e.value}')).toList()),
          pw.SizedBox(height: 8),
          pw.Text('Service History:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          if (c.history.isEmpty) pw.Text('None') else pw.Column(children: c.history.map((h) => pw.Column(children: [
            pw.Text('Theater: ${h.location}'),
            pw.Text('Outcome: ${h.survivalStatus}'),
            pw.Text('Award: ${h.award}'),
            pw.Text('School: ${h.school}'),
            pw.SizedBox(height: 6),
          ])).toList()),
        ],
      ),
    );

    return pdf.save();
  }

  void _exportPdf() async {
    final bytes = await _buildPdf(_char);
    await Printing.sharePdf(bytes: bytes, filename: '${_char.name.isEmpty ? 'character' : _char.name}_summary.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TacticalTheme.gunmetal,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(padding: const EdgeInsets.all(8), color: TacticalTheme.oliveDrab, child: Text('FINAL ROLLUP', style: TacticalTheme.headerStencil)),
                  const SizedBox(height: 12),

                  Text('Name: ${_char.name}', style: TacticalTheme.dataMono),
                  Text('Service: ${_char.serviceBranch}', style: TacticalTheme.dataMono),
                  Text('Rank: ${_char.rankTitle}', style: TacticalTheme.dataMono),
                  Text('Specialty: ${_char.militarySpecialty}', style: TacticalTheme.dataMono),
                  const SizedBox(height: 12),

                  Text('Attributes', style: TacticalTheme.headerStencil.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  ...AttributeType.values.map((t) => Text('${t.toString().split('.').last}: ${_char.attributes[t] ?? 0}', style: TacticalTheme.dataMono)),

                  const SizedBox(height: 12),
                  Text('Skills', style: TacticalTheme.headerStencil.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  ..._char.skills.entries.map((e) => Text('${e.key}: ${e.value}', style: TacticalTheme.dataMono)),

                  const SizedBox(height: 12),
                  Text('Service History', style: TacticalTheme.headerStencil.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  if (_char.history.isEmpty) Text('None', style: TacticalTheme.dataMono) else Column(children: _char.history.map((h) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    color: Colors.black,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Theater: ${h.location}', style: TacticalTheme.dataMono),
                      Text('Status: ${h.survivalStatus}', style: TacticalTheme.dataMono),
                      Text('Award: ${h.award}', style: TacticalTheme.dataMono),
                      Text('School: ${h.school}', style: TacticalTheme.dataMono),
                    ]),
                  )).toList()),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _exportPdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export PDF'),
                      style: ElevatedButton.styleFrom(backgroundColor: TacticalTheme.safetyOrange),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
