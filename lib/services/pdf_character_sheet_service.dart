
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/character.dart';
import '../utils/body_type_descriptor.dart';
import 'abilities_resolver.dart';
import 'pdf_field_log_page.dart';
import 'storage_service.dart';

// Platform-specific file handling
import 'pdf_export_service_io.dart'
    if (dart.library.html) 'pdf_export_service_web.dart';

/// PDF export service that generates military-style character sheets
/// matching the OTW field form design
class PdfCharacterSheetService {
  static Future<String> exportCharacterSheet(Character character) async {
    final pdf = buildDocument(character);
    final fileName =
        'OTW_CharSheet_${character.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final bytes = await pdf.save();
    return _saveAndUpload(character, bytes, fileName);
  }

  static pw.Document buildDocument(
    Character character, {
    bool compress = true,
  }) {
    final pdf = pw.Document(compress: compress);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(character),
            pw.SizedBox(height: 8),

            // Personnel Identity Section
            _buildSection('I. PERSONNEL IDENTITY', [
              _buildFieldRow([
                _buildField('NAME', character.name, flex: 3),
                _buildField(
                  'NICKNAME / CALL SIGN',
                  character.nickname,
                  flex: 2,
                ),
              ]),
              _buildFieldRow([
                _buildField('AGE', character.age.toString()),
                _buildField('NATIONALITY', character.nationality, flex: 2),
                _buildField('BACKGROUND', character.background, flex: 2),
              ]),
              _buildFieldRow([
                _buildField('HEIGHT', character.height),
                _buildField(
                  'WEIGHT',
                  '${character.weight} ${character.weightUnit}',
                ),
              ]),
              _buildField(
                'BODY TYPE',
                character.weight > 0
                    ? BodyTypeDescriptor.getFullBodyTypeDescription(
                        character.height,
                        character.weightUnit == 'kg'
                            ? character.weight * 2.20462
                            : character.weight,
                      )
                    : '',
                fullWidth: true,
              ),
              _buildFieldRow([
                _buildField(
                  'LANGUAGES',
                  character.languages.join(', '),
                  flex: 2,
                ),
                _buildField('MOTIVATION', character.motivation, flex: 2),
              ]),
            ]),
            pw.SizedBox(height: 6),

            // Core Attributes - Compact
            _buildCompactAttributesRow(character.attributes),
            pw.SizedBox(height: 6),

            _buildSection('III. SKILLS & QUALIFICATIONS', [
              _buildSkillsCheckboxes(character.skills),
            ]),
            pw.SizedBox(height: 6),

            _buildAbilitiesSectionLarge(character),
            pw.SizedBox(height: 6),

            // Service Record Section
            _buildSection('V. SERVICE RECORD', [
              _buildFieldRow([
                _buildField(
                  'SERVICE BRANCH',
                  character.enlistment['service']?.toString() ?? '',
                ),
                _buildField(
                  'RANK',
                  character.enlistment['rank']?.toString() ?? '',
                ),
                _buildField(
                  'SPECIALTY / MOS',
                  character.enlistment['specialty']?.toString() ?? '',
                  flex: 2,
                ),
              ]),
              _buildFieldRow([
                _buildField('HOOK / TRAIT', character.specialtyHook, flex: 2),
                _buildField('CONFLICT', character.personalConflict, flex: 2),
              ]),
              _buildField('TRADEMARK', character.trademark, fullWidth: true),
              _buildFieldRow([
                _buildField(
                  'SCHOOLS / QUALIFICATIONS',
                  _getSchools(character),
                  flex: 3,
                ),
              ]),
              _buildFieldRow([
                _buildField('DEPLOYMENTS', _getDeployments(character), flex: 3),
              ]),
              _buildFieldRow([
                _buildField(
                  'AWARDS / DECORATIONS',
                  _getAwards(character),
                  flex: 3,
                ),
              ]),
              _buildFieldRow([
                _buildField(
                  'COMBAT EXPERIENCE',
                  (character.skills['Combat'] ?? 0).toString(),
                ),
                _buildField(
                  'TRAINING BONUS',
                  (character.skills['Training'] ?? 0).toString(),
                ),
              ]),
            ]),
            pw.Spacer(),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );

    // Page 2: equipment checklist and full narrative
    final fullNarrative = character.enlistment['narrative']?.toString() ?? '';
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(character),
            pw.SizedBox(height: 12),

            // VI. EQUIPMENT / LOADOUT CHECKLIST
            _buildEquipmentSectionCheckboxes(character),
            pw.SizedBox(height: 12),

            if (fullNarrative.isNotEmpty)
              _buildSection('CHARACTER NARRATIVE (FULL)', [
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    color: PdfColors.grey50,
                  ),
                  child: pw.Text(
                    fullNarrative,
                    style: const pw.TextStyle(fontSize: 8, lineSpacing: 1.4),
                    textAlign: pw.TextAlign.justify,
                  ),
                ),
              ]),

            pw.Spacer(),

            _buildFooter(),
          ],
        ),
      ),
    );

    pdf.addPage(PdfFieldLogPage.build(character));

    return pdf;
  }

  static Future<String> _saveAndUpload(
    Character character,
    Uint8List bytes,
    String fileName,
  ) async {
    // Upload to Firebase Storage
    String? cloudUrl;
    try {
      cloudUrl = await StorageService.uploadPdfSheet(
        character.id,
        bytes,
        character.name,
      );
      if (cloudUrl != null) {
        debugPrint('Character sheet uploaded to Firebase: $cloudUrl');
      }
    } catch (e) {
      debugPrint('Failed to upload character sheet: $e');
    }

    // Save locally
    final localPath = await PdfFileHandler.saveFile(bytes, fileName);

    return cloudUrl != null ? '$localPath\nCloud: $cloudUrl' : localPath;
  }

  /// Build the header section
  static pw.Widget _buildHeader(Character character) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700, width: 2),
      ),
      padding: const pw.EdgeInsets.all(12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'OUTSIDE THE WIRE',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'PERSONNEL RECORD / CHARACTER SHEET',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'DOCUMENT ID: OTW-PERSREC-01',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text('REV 2025-A', style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a section with title and content
  static pw.Widget _buildSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            border: pw.Border.all(color: PdfColors.grey400),
          ),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        ...children,
      ],
    );
  }

  /// Build a field row with multiple fields
  static pw.Widget _buildFieldRow(List<pw.Widget> fields) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: fields,
      ),
    );
  }

  /// Build a single field
  static pw.Widget _buildField(
    String label,
    String value, {
    int flex = 1,
    bool fullWidth = false,
  }) {
    final widget = pw.Container(
      margin: const pw.EdgeInsets.only(right: 4),
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        color: value.isEmpty ? PdfColors.grey50 : PdfColors.white,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 7,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value.isEmpty ? '—' : value,
            style: pw.TextStyle(
              fontSize: 8,
              color: value.isEmpty ? PdfColors.grey400 : PdfColors.black,
            ),
          ),
        ],
      ),
    );

    return fullWidth ? widget : pw.Expanded(flex: flex, child: widget);
  }

  /// Build compact attributes row (single line)
  static pw.Widget _buildCompactAttributesRow(Map<String, int> attributes) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        color: PdfColors.grey100,
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'II. CORE ATTRIBUTES:',
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'STR: ${attributes['Strength'] ?? 0}',
            style: const pw.TextStyle(fontSize: 7),
          ),
          pw.Text(
            'AGI: ${attributes['Agility'] ?? 0}',
            style: const pw.TextStyle(fontSize: 7),
          ),
          pw.Text(
            'WIS: ${attributes['Combat Wisdom'] ?? 0}',
            style: const pw.TextStyle(fontSize: 7),
          ),
          pw.Text(
            'KNOW: ${attributes['Combat Knowledge'] ?? 0}',
            style: const pw.TextStyle(fontSize: 7),
          ),
        ],
      ),
    );
  }


  /// Build skills checkboxes
  static pw.Widget _buildSkillsCheckboxes(Map<String, int> skills) {
    final skillNames = [
      'Small Arms',
      'Heavy Weapons',
      'First Aid',
      'Communications',
      'Civil Affairs',
      'Fires',
      'Signals Intel',
      'Explosives Expert',
      'Spy/Recon',
      'Other',
    ];

    return pw.Wrap(
      spacing: 16,
      runSpacing: 6,
      children: skillNames.map((skillName) {
        final normalizedName = _normalizeSkillName(skillName);
        final value = skills[normalizedName] ?? 0;
        final hasSkill = value > 0;

        return pw.Container(
          width: 120,
          child: pw.Row(
            children: [
              pw.Container(
                width: 10,
                height: 10,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey700),
                ),
                child: hasSkill
                    ? pw.Center(
                        child: pw.Text(
                          'X',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
              pw.SizedBox(width: 4),
              pw.Text(skillName, style: const pw.TextStyle(fontSize: 8)),
              if (hasSkill) ...[
                pw.SizedBox(width: 4),
                pw.Text(
                  '(+$value)',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build LARGE prominent abilities section (Most Important)
  static pw.Widget _buildAbilitiesSectionLarge(Character character) {
    final nonNullAbilities = AbilitiesResolver.resolve(character);

    final abilityGroups = {
      'Prowess': ['Small Arms', 'Heavy Weapons', 'First Aid'],
      'Instincts': ['Communication', 'Civil Affairs', 'Fires'],
      'Tactics': ['Spying', 'Explosives', 'Signals Intel'],
    };

    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 2),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'IV. ABILITIES',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: abilityGroups.entries.map((group) {
              final score = nonNullAbilities[group.key] ?? 0;
              return pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${group.key}: $score',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      ...group.value.map((skill) {
                        final value = nonNullAbilities[skill] ?? 0;
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 2),
                          child: pw.Text(
                            '$skill: $value',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: value > 0
                                  ? PdfColors.black
                                  : PdfColors.grey,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build equipment section with checkboxes (8 categories)
  static pw.Widget _buildEquipmentSectionCheckboxes(Character character) {
    // Check both inventory locations for weapons/equipment
    final inventory = character.inventory;
    final enlistmentInventory = character.enlistment['inventory'];

    // Try to get weapons from character.inventory first, then fall back to enlistment.inventory
    List weapons = [];
    if (inventory['loadoutWeapons'] != null) {
      weapons = inventory['loadoutWeapons'] as List;
    } else if (enlistmentInventory is Map &&
        enlistmentInventory['loadoutWeapons'] != null) {
      weapons = enlistmentInventory['loadoutWeapons'] as List;
    }

    // Also check for custom weapons
    List customWeapons = [];
    if (enlistmentInventory is Map &&
        enlistmentInventory['customWeapons'] != null) {
      customWeapons = enlistmentInventory['customWeapons'] as List;
    } else if (inventory['customWeapons'] != null) {
      customWeapons = inventory['customWeapons'] as List;
    }

    // Combine all weapons
    final allWeapons = [...weapons, ...customWeapons];

    // Get actual weapon names
    final weaponNames = allWeapons.map((w) => w.toString()).toList();

    // Get selected equipment - check both locations
    List selectedEquipment = [];
    if (inventory['selectedEquipment'] != null) {
      selectedEquipment = inventory['selectedEquipment'] as List;
    } else if (enlistmentInventory is Map &&
        enlistmentInventory['equipment'] != null) {
      selectedEquipment = enlistmentInventory['equipment'] as List;
    }

    // Equipment categories matching PDF form exactly - with actual weapons listed
    final categories = <String, List<String>>{
      'HEAD/EYES': [
        'Helmet',
        'Kevlar helmet',
        'Goggles',
        'Night vision',
        'Night vision goggles',
        'Night Vision Goggles',
      ],
      'CLOTHING': [
        'Combat uniform',
        'Combat jacket',
        'Boots',
        'Gloves',
        'Cold weather gear',
      ],
      'GRENADES': [
        'Frag grenade',
        'Smoke grenade',
        'CS grenade',
        'Flashbang',
        'Flashbang grenade',
        'Stun grenade',
        'Gas grenade',
        'Concussion grenade',
        'Thermite grenade',
      ],
      'COMMS': [
        'Radio',
        'GPS',
        'Compass',
        'Flashlight',
        'Signal flares',
        'Red star cluster signal flare',
        'Illumination signal flare',
        'Green start cluster signal flare',
        'Inter Squad Radio',
        'Backpack Radio',
        'Hand held walkie talkie',
      ],
      'WEAPONS': weaponNames,
      'TOOLS': [
        'Multi-tool',
        'Combat knife',
        'Binoculars',
        'First aid',
        'Hand held mine detector',
        'EOD demo kit',
        'EOD robot and computer',
        'Breacher Kit',
        'JTAC computer and radio',
        'Civil Affairs Kit',
        'Signal Collection Kit',
        'Spy Kit',
        'Canine Kit',
      ],
      'DAYPACK': [
        'Day pack',
        'Day patrol pack',
        'Water',
        'Water canteen',
        'MRE',
        'Personal medical kit',
        'Unit 1 Medical Kit',
      ],
      'LOAD BEARING': [
        'LBV',
        'Load bearing vest',
        'Mag pouches',
        'Magazine pouches',
        'Utility pouch',
        'First aid pouch',
        'Grenade pouch',
      ],
    };

    // Add selected equipment items to appropriate categories
    for (var item in selectedEquipment) {
      final itemStr = item.toString();
      bool found = false;
      for (var category in categories.values) {
        if (category.contains(itemStr)) {
          found = true;
          break;
        }
      }
      // If not found in any category, add to TOOLS or appropriate category
      if (!found) {
        if (itemStr.toLowerCase().contains('grenade')) {
          if (!categories['GRENADES']!.contains(itemStr)) {
            categories['GRENADES']!.add(itemStr);
          }
        } else if (itemStr.toLowerCase().contains('radio') ||
            itemStr.toLowerCase().contains('flare') ||
            itemStr.toLowerCase().contains('jammer')) {
          if (!categories['COMMS']!.contains(itemStr)) {
            categories['COMMS']!.add(itemStr);
          }
        } else if (itemStr.toLowerCase().contains('vision') ||
            itemStr.toLowerCase().contains('goggle') ||
            itemStr.toLowerCase().contains('ir pointer') ||
            itemStr.toLowerCase().contains('flashlight')) {
          if (!categories['HEAD/EYES']!.contains(itemStr)) {
            categories['HEAD/EYES']!.add(itemStr);
          }
        } else {
          if (!categories['TOOLS']!.contains(itemStr)) {
            categories['TOOLS']!.add(itemStr);
          }
        }
      }
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'VI. EQUIPMENT / LOADOUT CHECKLIST',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 6),
          ...categories.entries.map((category) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    color: PdfColors.grey300,
                    child: pw.Text(
                      category.key,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 3,
                    children: category.value.map((item) {
                      // Check if item is in selectedEquipment (case-insensitive partial match)
                      final isSelected = selectedEquipment.any(
                        (selectedItem) =>
                            selectedItem.toString().toLowerCase() ==
                                item.toLowerCase() ||
                            selectedItem.toString().toLowerCase().contains(
                              item.toLowerCase(),
                            ) ||
                            item.toLowerCase().contains(
                              selectedItem.toString().toLowerCase(),
                            ),
                      );

                      return pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Container(
                            width: 8,
                            height: 8,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.black),
                            ),
                            child: isSelected
                                ? pw.Center(
                                    child: pw.Text(
                                      '✓',
                                      style: pw.TextStyle(
                                        fontSize: 6,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          pw.SizedBox(width: 2),
                          pw.Text(item, style: const pw.TextStyle(fontSize: 7)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'ADDITIONAL',
                        style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Container(
                        height: 10,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'HEALTH/MEDICAL',
                        style: pw.TextStyle(
                          fontSize: 7,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Container(
                        height: 10,
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom: pw.BorderSide(color: PdfColors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  /// Build footer
  static pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey700)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated: ${DateTime.now().toString().split('.')[0]}',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
          pw.Text(
            'Outside the Wire Character Generator v1.0',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  // Helper methods

  static String _getSchools(Character character) {
    final deployments = character.enlistment['deployments'] as List? ?? [];
    final schools = deployments
        .map((d) => d['school'])
        .where((s) => s != null && s.toString().isNotEmpty)
        .toSet()
        .join(', ');
    return schools.isEmpty ? 'None' : schools;
  }

  static String _getDeployments(Character character) {
    final deployments = character.enlistment['deployments'] as List? ?? [];
    if (deployments.isEmpty) return 'None';
    final locations = deployments
        .map((d) => d['location'])
        .where((l) => l != null)
        .toSet()
        .join(', ');

    String result = '${deployments.length}x ($locations)';

    // Add re-enlistment count if applicable
    final reenlistmentCount =
        character.enlistment['reenlistmentCount'] as int? ?? 0;
    if (reenlistmentCount > 0) {
      final plural = reenlistmentCount == 1
          ? 'Re-enlistment'
          : 'Re-enlistments';
      result += ' | $reenlistmentCount $plural';
    }

    return result;
  }

  static String _getAwards(Character character) {
    final deployments = character.enlistment['deployments'] as List? ?? [];
    final awards = deployments
        .map((d) => d['award'])
        .where((a) => a != null && a.toString() != 'None')
        .toSet()
        .join(', ');
    return awards.isEmpty ? 'None' : awards;
  }

  static String _normalizeSkillName(String skillName) {
    // Map display names to actual skill names in character data
    final mapping = {
      'Small Arms': 'Small Arms',
      'Heavy Weapons': 'Heavy Weapons',
      'First Aid': 'First Aid',
      'Communications': 'Radio Ops',
      'Civil Affairs': 'Civil Affairs',
      'Fires': 'Fires',
      'Signals Intel': 'Signals Intel',
      'Explosives Expert': 'Explosives',
      'Spy/Recon': 'Spying',
      'Other': 'Other',
    };
    return mapping[skillName] ?? skillName;
  }
}
