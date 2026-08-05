import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/character.dart';
import 'storage_service.dart';

// Platform-specific file handling
import 'pdf_export_service_io.dart'
    if (dart.library.html) 'pdf_export_service_web.dart';

class PdfExportService {
  /// Calculate abilities on-the-fly if missing from character data
  /// This is a fallback for older characters or edge cases
  static Map<String, dynamic> _calculateAbilities(Character character) {
    final a = character.attributes;
    final s = character.skills;
    
    int val(Map<String, int> map, String key) => map[key] ?? 0;
    int penalize(int base, bool earned) => earned ? base : (base ~/ 2);
    
    // Core abilities (never halved)
    final specialty = character.enlistment['specialty']?.toString() ?? '';
    var tacticsBase = val(a, 'Combat Knowledge') + val(s, 'Combat') + val(s, 'Training');
    if (specialty.contains('Rifleman')) {
      tacticsBase += 1;
    }
    
    return {
      'Prowess': val(a, 'Strength') + val(s, 'Combat') + val(s, 'Training'),
      'Instincts': val(a, 'Combat Wisdom') + val(s, 'Training') + val(s, 'Combat'),
      'Tactics': tacticsBase,
      'Small Arms': penalize(
        val(s, 'Small Arms') + val(a, 'Agility') + val(s, 'Combat'),
        val(s, 'Small Arms') > 0,
      ),
      'Heavy Weapons': penalize(
        val(s, 'Heavy Weapons') + val(a, 'Agility') + val(s, 'Combat'),
        val(s, 'Heavy Weapons') > 0,
      ),
      'First Aid': penalize(
        val(s, 'First Aid') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'First Aid') > 0,
      ),
      'Communication': penalize(
        val(s, 'Radio Ops') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Radio Ops') > 0,
      ),
      'Civil Affairs': penalize(
        val(s, 'Civil Affairs') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Civil Affairs') > 0,
      ),
      'Fires': penalize(
        val(s, 'Fires') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Fires') > 0,
      ),
      'Spying': penalize(
        val(s, 'Spying') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Spying') > 0,
      ),
      'Explosives': penalize(
        val(s, 'Explosives') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Explosives') > 0,
      ),
      'Signals Intel': penalize(
        val(s, 'Signals Intel') + val(s, 'Combat') + val(a, 'Combat Wisdom'),
        val(s, 'Signals Intel') > 0,
      ),
    };
  }

  static Future<String> exportCharacterToPdf(Character character) async {
    final pdf = pw.Document();

    // Build PDF pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'PATROL',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Character Dossier',
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Basic Info Section
          _buildSection('BASIC INFORMATION', [
            _buildInfoRow('Name:', character.nickname.isNotEmpty 
              ? '${character.name} "${character.nickname}"' 
              : character.name),
            _buildInfoRow('Nationality:', character.nationality),
            _buildInfoRow('Age:', '${character.age}'),
            _buildInfoRow('Height:', character.height),
            _buildInfoRow('Weight:', '${character.weight} ${character.weightUnit}'),
            _buildInfoRow('Languages:', character.languages.join(', ')),
          ]),
          pw.SizedBox(height: 16),

          // Enlistment Section
          _buildSection('ENLISTMENT', [
            _buildInfoRow('Service:', character.enlistment['service']?.toString() ?? 'N/A'),
            _buildInfoRow('Rank:', character.enlistment['rank']?.toString() ?? 'N/A'),
            _buildInfoRow('Specialty:', character.enlistment['specialty']?.toString() ?? 'N/A'),
          ]),
          pw.SizedBox(height: 16),

          // Attributes Section
          if (character.attributes.isNotEmpty) ...[
            _buildSection('ATTRIBUTES', [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: character.attributes.entries.take(2).map((e) =>
                        _buildStatRow(e.key, e.value)
                      ).toList(),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: character.attributes.entries.skip(2).map((e) =>
                        _buildStatRow(e.key, e.value)
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ]),
            pw.SizedBox(height: 16),
          ],

          // Skills Section
          if (character.skills.isNotEmpty) ...[
            _buildSection('SKILLS', [
              pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: character.skills.entries.take((character.skills.length / 2).ceil()).map((e) =>
                        _buildStatRow(e.key, e.value)
                      ).toList(),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: character.skills.entries.skip((character.skills.length / 2).ceil()).map((e) =>
                        _buildStatRow(e.key, e.value)
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ]),
            pw.SizedBox(height: 16),
          ],
          pw.SizedBox(height: 16),

          // Abilities Section (must come before narrative for proper display)
          () {
            // Try to get abilities from character data, calculate if missing
            var abilities = character.enlistment['abilities'] as Map<String, dynamic>?;
            
            if (abilities == null || abilities.isEmpty) {
              debugPrint('⚠️ Abilities missing from character data - calculating on-the-fly');
              abilities = _calculateAbilities(character);
            }
            
            return _buildSection('ABILITIES', [
              pw.Wrap(
                spacing: 16,
                runSpacing: 8,
                children: abilities.entries.map((e) =>
                  pw.Container(
                    width: 120,
                    child: _buildStatRow(e.key.toString(), e.value as int),
                  )
                ).toList(),
              ),
            ]);
          }(),
          pw.SizedBox(height: 16),

          // Narrative Section (if exists)
          if (character.enlistment['narrative'] != null && 
              character.enlistment['narrative'].toString().isNotEmpty) ...[
            _buildSection('NARRATIVE', [
              pw.Text(
                character.enlistment['narrative'].toString(),
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5),
                textAlign: pw.TextAlign.justify,
              ),
            ]),
            pw.SizedBox(height: 16),
          ],
          
          // Specialty Hook (if exists)
          if (character.specialtyHook.isNotEmpty) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.purple50,
                border: pw.Border.all(color: PdfColors.purple200),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SPECIALTY HOOK',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    character.specialtyHook,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
          ],
          
          // Canine Companion (if exists)
          if (character.canineName.isNotEmpty) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.orange50,
                border: pw.Border.all(color: PdfColors.orange200),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'CANINE COMPANION',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  _buildInfoRow('Name:', character.canineName),
                  _buildInfoRow('Breed:', character.canineBreed),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // Equipment Section (if exists)
          if (character.enlistment['inventory'] != null) ...[
            _buildSection('EQUIPMENT', [
              if ((character.enlistment['inventory'] as Map)['loadoutWeapons'] != null &&
                  ((character.enlistment['inventory'] as Map)['loadoutWeapons'] as List).isNotEmpty)
                _buildInfoRow('Weapons:', ((character.enlistment['inventory'] as Map)['loadoutWeapons'] as List).join(', ')),
              if ((character.enlistment['inventory'] as Map)['customWeapons'] != null &&
                  ((character.enlistment['inventory'] as Map)['customWeapons'] as List).isNotEmpty)
                _buildInfoRow('Custom Weapons:', ((character.enlistment['inventory'] as Map)['customWeapons'] as List).join(', ')),
              if ((character.enlistment['inventory'] as Map)['equipment'] != null &&
                  ((character.enlistment['inventory'] as Map)['equipment'] as List).isNotEmpty)
                _buildInfoRow('Equipment:', ((character.enlistment['inventory'] as Map)['equipment'] as List).join(', ')),
            ]),
            pw.SizedBox(height: 16),
          ],

          // Footer
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated: ${DateTime.now().toString().split('.')[0]}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
              pw.Text(
                'Outside the Wire Character Generator v1.0',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );

    final fileName = 'Patrol_${character.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final bytes = await pdf.save();

    // Upload to Firebase Storage
    String? cloudUrl;
    try {
      cloudUrl = await StorageService.uploadPdfSheet(
        character.id,
        bytes,
        character.name,
      );
      if (cloudUrl != null) {
        debugPrint('PDF uploaded to Firebase Storage: $cloudUrl');
      }
    } catch (e) {
      debugPrint('Failed to upload PDF to Storage: $e');
    }

    // Use platform-specific file handler for local save
    final localPath = await PdfFileHandler.saveFile(bytes, fileName);
    
    // Return local path with cloud URL info in message
    return cloudUrl != null 
        ? '$localPath\nCloud: $cloudUrl'
        : localPath;
  }

  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Container(
      width: double.infinity,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildStatRow(String label, int value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
          pw.Container(
            width: 30,
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
            ),
            child: pw.Text(
              value.toString(),
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
