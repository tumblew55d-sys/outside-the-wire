import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/character.dart';
import '../utils/body_type_descriptor.dart';
import 'storage_service.dart';

// Platform-specific file handling
import 'pdf_export_service_io.dart'
    if (dart.library.html) 'pdf_export_service_web.dart';

/// PDF export service that generates military-style character sheets
/// matching the OTW field form design
class PdfCharacterSheetService {
  static Future<String> exportCharacterSheet(Character character) async {
    final pdf = pw.Document();

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

            // Core Attributes - Compact (Abilities are more important)
            _buildCompactAttributesRow(character.attributes),
            pw.SizedBox(height: 6),

            // Service Record Section
            _buildSection('III. SERVICE RECORD', [
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
            pw.SizedBox(height: 8),

            // CHARACTER NARRATIVE (First paragraph only) - Matches preview
            if (_getFirstNarrativeParagraph(character).isNotEmpty)
              _buildSection('CHARACTER NARRATIVE', [
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    color: PdfColors.grey50,
                  ),
                  child: pw.Text(
                    _getFirstNarrativeParagraph(character),
                    style: const pw.TextStyle(fontSize: 7, lineSpacing: 1.3),
                    textAlign: pw.TextAlign.justify,
                  ),
                ),
              ]),
            pw.SizedBox(height: 6),

            // IV. Skills & Qualifications Section - Matches preview
            _buildSection('IV. SKILLS & QUALIFICATIONS', [
              _buildSkillsCheckboxes(character.skills),
            ]),
            pw.SizedBox(height: 8),

            // V. ABILITIES - PROMINENT SECTION - Matches preview
            _buildAbilitiesSectionLarge(character),

            pw.Spacer(),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );

    // Add second page with full narrative and additional information
    final fullNarrative = character.enlistment['narrative']?.toString() ?? '';
    if (fullNarrative.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.all(36),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(character),
              pw.SizedBox(height: 12),

              // VI. EQUIPMENT / LOADOUT CHECKLIST
              _buildEquipmentSectionCheckboxes(character),
              pw.SizedBox(height: 12),

              // Full Character Narrative
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
              pw.SizedBox(height: 12),

              // Notes Section
              _buildSection('MISSION NOTES / CAMPAIGN LOG', [
                pw.Container(
                  height: 200,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    color: PdfColors.grey50,
                  ),
                  child: pw.Text(
                    '(Use this space for mission notes, character development, injuries, etc.)',
                    style: pw.TextStyle(
                      fontSize: 7,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ]),

              pw.Spacer(),

              // Footer
              _buildFooter(),
            ],
          ),
        ),
      );
    }

    final fileName =
        'OTW_CharSheet_${character.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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

  /// Build attributes display
  static pw.Widget _buildAttributesRow(Map<String, int> attributes) {
    return pw.Row(
      children: [
        _buildAttributeBox('STR', attributes['Strength'] ?? 0),
        pw.SizedBox(width: 12),
        _buildAttributeBox('AGI', attributes['Agility'] ?? 0),
        pw.SizedBox(width: 12),
        _buildAttributeBox('WIS', attributes['Combat Wisdom'] ?? 0),
        pw.SizedBox(width: 12),
        _buildAttributeBox('KNOW', attributes['Combat Knowledge'] ?? 0),
      ],
    );
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

  /// Build a single attribute box
  static pw.Widget _buildAttributeBox(String label, int value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey700),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value.toString(),
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
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

  /// Build abilities section
  static pw.Widget _buildAbilitiesSection(Character character) {
    // Try to get abilities from character data, calculate if missing
    var abilities = character.enlistment['abilities'] as Map<String, dynamic>?;
    
    if (abilities == null || abilities.isEmpty) {
      debugPrint('⚠️ Abilities missing from character data - calculating on-the-fly');
      abilities = _calculateAbilities(character);
    }
    
    // Ensure abilities is non-null for the widget tree
    final nonNullAbilities = abilities ?? <String, dynamic>{};

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildAbilityCategory('PROWESS', [
          'Small Arms',
          'Heavy Weapons',
          'Fires',
        ], nonNullAbilities),
        pw.SizedBox(height: 8),
        _buildAbilityCategory('INSTINCT', [
          'First Aid',
          'Communication',
          'Civil Affairs',
        ], nonNullAbilities),
        pw.SizedBox(height: 8),
        _buildAbilityCategory('TACTICS', [
          'Spying',
          'Explosives',
          'Signals Intel',
        ], nonNullAbilities),
      ],
    );
  }

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

  /// Build LARGE prominent abilities section (Most Important)
  static pw.Widget _buildAbilitiesSectionLarge(Character character) {
    // Try to get abilities from character data, calculate if missing
    var abilities = character.enlistment['abilities'] as Map<String, dynamic>?;
    
    if (abilities == null || abilities.isEmpty) {
      debugPrint('⚠️ Abilities missing from character data - calculating on-the-fly');
      abilities = _calculateAbilities(character);
    }
    
    // Ensure abilities is non-null for the widget tree
    final nonNullAbilities = abilities ?? <String, dynamic>{};
    
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
            'V. ABILITIES',
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

  /// Build ability category row
  static pw.Widget _buildAbilityCategory(
    String category,
    List<String> skillNames,
    Map<String, dynamic> abilities,
  ) {
    return pw.Row(
      children: [
        pw.Container(
          width: 80,
          child: pw.Text(
            category,
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: pw.Row(
            children: skillNames.map((skill) {
              final value = abilities[skill] ?? 0;
              return pw.Expanded(
                child: pw.Container(
                  margin: const pw.EdgeInsets.only(right: 8),
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey600),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(skill, style: const pw.TextStyle(fontSize: 7)),
                      pw.Text(
                        value.toString(),
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Build equipment section
  static pw.Widget _buildEquipmentSection(Character character) {
    final inventory = character.inventory;
    final loadoutWeapons = (inventory['loadoutWeapons'] as List?) ?? [];
    final equipment = (inventory['selectedEquipment'] as List?) ?? [];

    // Organize equipment into categories
    final headEyes = <String>[];
    final clothing = <String>[];
    final loadBearing = <String>[];
    final weapons = <String>[...loadoutWeapons.cast<String>()];
    final grenades = <String>[];
    final comms = <String>[];
    final tools = <String>[];
    final pack = <String>[];

    for (var item in equipment.cast<String>()) {
      final itemLower = item.toLowerCase();
      if (itemLower.contains('helmet') ||
          itemLower.contains('nvg') ||
          itemLower.contains('gas mask') ||
          itemLower.contains('eye')) {
        headEyes.add(item);
      } else if (itemLower.contains('uniform') ||
          itemLower.contains('boots') ||
          itemLower.contains('gloves') ||
          itemLower.contains('jacket')) {
        clothing.add(item);
      } else if (itemLower.contains('vest') ||
          itemLower.contains('magazine') ||
          itemLower.contains('plate') ||
          itemLower.contains('pouch')) {
        loadBearing.add(item);
      } else if (itemLower.contains('grenade') ||
          itemLower.contains('explosive') ||
          itemLower.contains('smoke') ||
          itemLower.contains('flash')) {
        grenades.add(item);
      } else if (itemLower.contains('radio') ||
          itemLower.contains('jtac') ||
          itemLower.contains('jammer')) {
        comms.add(item);
      } else if (itemLower.contains('pack') ||
          itemLower.contains('ruck') ||
          itemLower.contains('camelback') ||
          itemLower.contains('meal')) {
        pack.add(item);
      } else {
        tools.add(item);
      }
    }

    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (headEyes.isNotEmpty) _buildEquipmentCategory('HEAD/EYES', headEyes),
        if (clothing.isNotEmpty) _buildEquipmentCategory('CLOTHING', clothing),
        if (loadBearing.isNotEmpty)
          _buildEquipmentCategory('LOAD BEARING/VEST', loadBearing),
        if (weapons.isNotEmpty) _buildEquipmentCategory('WEAPONS', weapons),
        if (grenades.isNotEmpty)
          _buildEquipmentCategory('GRENADES/EXPLOSIVES', grenades),
        if (comms.isNotEmpty) _buildEquipmentCategory('COMMUNICATIONS', comms),
        if (tools.isNotEmpty)
          _buildEquipmentCategory('TOOLS/ACCESSORIES', tools),
        if (pack.isNotEmpty) _buildEquipmentCategory('DAYPACK/RUCKSACK', pack),
      ],
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
                      final isSelected = selectedEquipment.any((selectedItem) =>
                          selectedItem.toString().toLowerCase() ==
                              item.toLowerCase() ||
                          selectedItem
                              .toString()
                              .toLowerCase()
                              .contains(item.toLowerCase()) ||
                          item
                              .toLowerCase()
                              .contains(selectedItem.toString().toLowerCase()));
                      
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

  /// Build equipment category
  static pw.Widget _buildEquipmentCategory(String title, List<String> items) {
    return pw.Container(
      width: 180,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 3),
          if (items.isEmpty)
            pw.Text('—', style: const pw.TextStyle(fontSize: 7))
          else
            ...items.map((item) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 2),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 7,
                      height: 7,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.grey700,
                          width: 0.5,
                        ),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          '✓',
                          style: pw.TextStyle(
                            fontSize: 5,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 3),
                    pw.Expanded(
                      child: pw.Text(
                        item,
                        style: const pw.TextStyle(fontSize: 6),
                        maxLines: 2,
                        overflow: pw.TextOverflow.clip,
                      ),
                    ),
                  ],
                ),
              );
            }),
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

  static String _getFirstNarrativeParagraph(Character character) {
    final narrative = character.enlistment['narrative']?.toString() ?? '';
    if (narrative.isEmpty) return '';

    // Split by double newlines (paragraphs) or single newlines if no doubles exist
    final paragraphs = narrative.contains('\n\n')
        ? narrative.split('\n\n')
        : narrative.split('\n');

    // Return first non-empty paragraph
    return paragraphs
        .firstWhere((p) => p.trim().isNotEmpty, orElse: () => '')
        .trim();
  }
}
