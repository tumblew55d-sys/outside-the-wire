import 'package:flutter/material.dart';
import '../models/character.dart';
import '../utils/body_type_descriptor.dart';

/// Live preview of character sheet that fills in as character is built
class CharacterSheetPreview extends StatefulWidget {
  final Character character;
  final Function(String item, bool isChecked)? onEquipmentChanged;

  const CharacterSheetPreview({
    super.key,
    required this.character,
    this.onEquipmentChanged,
  });

  @override
  State<CharacterSheetPreview> createState() => _CharacterSheetPreviewState();
}

class _CharacterSheetPreviewState extends State<CharacterSheetPreview> {
  late Map<String, bool> _equipmentChecked;

  @override
  void initState() {
    super.initState();
    _initializeEquipmentChecks();
  }

  void _initializeEquipmentChecks() {
    _equipmentChecked = {};

    // Check both inventory locations
    final inventory = widget.character.inventory;
    final enlistmentInventory = widget.character.enlistment['inventory'];

    // Get weapons from both possible locations
    List weapons = [];
    if (inventory['loadoutWeapons'] != null) {
      weapons = inventory['loadoutWeapons'] as List;
    } else if (enlistmentInventory is Map &&
        enlistmentInventory['loadoutWeapons'] != null) {
      weapons = enlistmentInventory['loadoutWeapons'] as List;
    }

    // Get equipment
    List equipment = [];
    if (inventory['selectedEquipment'] != null) {
      equipment = inventory['selectedEquipment'] as List;
    } else if (enlistmentInventory is Map &&
        enlistmentInventory['equipment'] != null) {
      equipment = enlistmentInventory['equipment'] as List;
    }

    // Get custom weapons - check both locations
    List customWeapons = [];
    if (inventory['customWeapons'] != null) {
      customWeapons = inventory['customWeapons'] as List;
    } else if (enlistmentInventory is Map &&
        enlistmentInventory['customWeapons'] != null) {
      customWeapons = enlistmentInventory['customWeapons'] as List;
    }

    // Mark all as checked
    for (var weapon in weapons) {
      _equipmentChecked[weapon.toString()] = true;
    }
    for (var equip in equipment) {
      _equipmentChecked[equip.toString()] = true;
    }
    for (var custom in customWeapons) {
      _equipmentChecked[custom.toString()] = true;
    }
  }

  @override
  void didUpdateWidget(CharacterSheetPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.character != widget.character) {
      _initializeEquipmentChecks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 8),

            // I. PERSONNEL IDENTITY - Matches PDF exactly
            _buildSection('I. PERSONNEL IDENTITY', [
              _buildFieldRow([
                _buildField('NAME', widget.character.name, flex: 3),
                _buildField(
                  'NICKNAME / CALL SIGN',
                  widget.character.nickname,
                  flex: 2,
                ),
              ]),
              _buildFieldRow([
                _buildField(
                  'AGE',
                  widget.character.age > 0
                      ? widget.character.age.toString()
                      : '',
                ),
                _buildField(
                  'NATIONALITY',
                  widget.character.nationality,
                  flex: 2,
                ),
                _buildField('BACKGROUND', widget.character.background, flex: 2),
              ]),
              _buildFieldRow([
                _buildField('HEIGHT', widget.character.height),
                _buildField(
                  'WEIGHT',
                  widget.character.weight > 0
                      ? '${widget.character.weight} ${widget.character.weightUnit}'
                      : '',
                ),
              ]),
              _buildField(
                'BODY TYPE',
                widget.character.weight > 0
                    ? BodyTypeDescriptor.getFullBodyTypeDescription(
                        widget.character.height,
                        widget.character.weightUnit == 'kg'
                            ? widget.character.weight * 2.20462
                            : widget.character.weight,
                      )
                    : '',
                fullWidth: true,
              ),
              _buildFieldRow([
                _buildField(
                  'LANGUAGES',
                  widget.character.languages.join(', '),
                  flex: 2,
                ),
                _buildField('MOTIVATION', widget.character.motivation, flex: 2),
              ]),
            ]),
            const SizedBox(height: 6),

            // II. CORE ATTRIBUTES - Compact view (Abilities are more important)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.grey.shade100,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'II. CORE ATTRIBUTES:',
                    style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold),
                  ),
                  _buildCompactAttribute(
                    'STR',
                    widget.character.attributes['Strength'] ?? 0,
                  ),
                  _buildCompactAttribute(
                    'AGI',
                    widget.character.attributes['Agility'] ?? 0,
                  ),
                  _buildCompactAttribute(
                    'WIS',
                    widget.character.attributes['Combat Wisdom'] ?? 0,
                  ),
                  _buildCompactAttribute(
                    'KNOW',
                    widget.character.attributes['Combat Knowledge'] ?? 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // III. SERVICE RECORD - Matches PDF exactly
            _buildSection('III. SERVICE RECORD', [
              _buildFieldRow([
                _buildField(
                  'SERVICE BRANCH',
                  widget.character.enlistment['service']?.toString() ?? '',
                ),
                _buildField(
                  'RANK',
                  widget.character.enlistment['rank']?.toString() ?? '',
                ),
                _buildField(
                  'SPECIALTY / MOS',
                  widget.character.enlistment['specialty']?.toString() ?? '',
                  flex: 2,
                ),
              ]),
              _buildFieldRow([
                _buildField(
                  'HOOK / TRAIT',
                  widget.character.specialtyHook,
                  flex: 2,
                ),
                _buildField(
                  'CONFLICT',
                  widget.character.personalConflict,
                  flex: 2,
                ),
              ]),
              _buildField(
                'TRADEMARK',
                widget.character.trademark,
                fullWidth: true,
              ),
              _buildFieldRow([
                _buildField(
                  'SCHOOLS / QUALIFICATIONS',
                  _getSchools(widget.character),
                  flex: 3,
                ),
              ]),
              _buildFieldRow([
                _buildField(
                  'DEPLOYMENTS',
                  _getDeployments(widget.character),
                  flex: 3,
                ),
              ]),
              _buildFieldRow([
                _buildField(
                  'AWARDS / DECORATIONS',
                  _getAwards(widget.character),
                  flex: 3,
                ),
              ]),
              _buildFieldRow([
                _buildField(
                  'COMBAT EXPERIENCE',
                  (widget.character.skills['Combat'] ?? 0).toString(),
                ),
                _buildField(
                  'TRAINING BONUS',
                  (widget.character.skills['Training'] ?? 0).toString(),
                ),
              ]),
            ]),
            const SizedBox(height: 8),

            // CHARACTER NARRATIVE (First paragraph only)
            if (_getFirstNarrativeParagraph(widget.character).isNotEmpty)
              _buildSection('CHARACTER NARRATIVE', [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    color: Colors.grey.shade50,
                  ),
                  child: Text(
                    _getFirstNarrativeParagraph(widget.character),
                    style: const TextStyle(fontSize: 7, height: 1.3),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ]),
            const SizedBox(height: 8),

            // IV. SKILLS & QUALIFICATIONS - Matches PDF exactly
            _buildSection('IV. SKILLS & QUALIFICATIONS', [
              _buildSkillsGrid(widget.character.skills),
            ]),
            const SizedBox(height: 12),

            // V. ABILITIES - PROMINENT SECTION (Most Important)
            _buildAbilitiesSectionLarge(widget.character),
            const SizedBox(height: 12),

            // VI. EQUIPMENT / LOADOUT CHECKLIST - Interactive checkboxes
            _buildEquipmentSectionCheckboxes(widget.character),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade400)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'OUTSIDE THE WIRE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'DOCUMENT ID: OTW-PERSREC-01',
                style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
              ),
              Text(
                'REV 2025-A',
                style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        ...children,
      ],
    );
  }

  Widget _buildFieldRow(List<Widget> fields) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields,
      ),
    );
  }

  Widget _buildField(
    String label,
    String value, {
    int flex = 1,
    bool fullWidth = false,
  }) {
    final widget = Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        color: value.isEmpty ? Colors.grey.shade50 : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '—' : value,
            style: TextStyle(
              fontSize: 8,
              color: value.isEmpty ? Colors.grey.shade400 : Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (fullWidth) {
      return widget;
    }
    return Expanded(flex: flex, child: widget);
  }

  Widget _buildAttributesRow(Map<String, dynamic> attributes) {
    return Row(
      children: [
        _buildAttributeBox('STR', attributes['Strength']),
        _buildAttributeBox('AGI', attributes['Agility']),
        _buildAttributeBox('WIS', attributes['Combat Wisdom']),
        _buildAttributeBox('KNOW', attributes['Combat Knowledge']),
      ],
    );
  }

  Widget _buildCompactAttribute(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold),
          ),
          Text(value.toString(), style: TextStyle(fontSize: 7)),
        ],
      ),
    );
  }

  Widget _buildAttributeBox(String label, dynamic value) {
    final displayValue = value?.toString() ?? '—';
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 2),
          color: value == null ? Colors.grey.shade50 : Colors.white,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              displayValue,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: value == null ? Colors.grey.shade400 : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsGrid(Map<String, dynamic> skills) {
    final skillsList = [
      'Small Arms',
      'Heavy Weapons',
      'First Aid',
      'Radio Ops',
      'Civil Affairs',
      'Spying',
      'Fires',
      'Signals Intel',
      'Explosives',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: skillsList.map((skill) {
        final value = skills[skill] ?? 0;
        return Container(
          width: 100,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            color: value > 0 ? Colors.white : Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Icon(
                value > 0 ? Icons.check_box : Icons.check_box_outline_blank,
                size: 12,
                color: value > 0 ? Colors.black : Colors.grey.shade400,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 7,
                    color: value > 0 ? Colors.black : Colors.grey.shade400,
                  ),
                ),
              ),
              if (value > 0)
                Text(
                  '+$value',
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAbilitiesSectionLarge(Character character) {
    final abilities = character.enlistment['abilities'] as Map? ?? {};
    final abilityGroups = {
      'Prowess': ['Small Arms', 'Heavy Weapons', 'First Aid'],
      'Instincts': ['Communication', 'Civil Affairs', 'Fires'],
      'Tactics': ['Spying', 'Explosives', 'Signals Intel'],
    };

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'V. ABILITIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: abilityGroups.entries.map((group) {
              final score = abilities[group.key] ?? 0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${group.key}: $score',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...group.value.map((skill) {
                        final value = abilities[skill] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '$skill: $value',
                            style: TextStyle(
                              fontSize: 10,
                              color: value > 0 ? Colors.black : Colors.grey,
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

  Widget _buildAbilitiesGrid(Character character) {
    // Keep old method for compatibility
    final abilities = character.enlistment['abilities'] as Map? ?? {};
    final abilityGroups = {
      'Prowess': ['Small Arms', 'Heavy Weapons', 'First Aid'],
      'Instincts': ['Communication', 'Civil Affairs', 'Fires'],
      'Tactics': ['Spying', 'Explosives', 'Signals Intel'],
    };

    return Column(
      children: abilityGroups.entries.map((group) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  color: Colors.grey.shade200,
                ),
                child: Text(
                  '${group.key}: ${abilities[group.key] ?? '—'}',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  children: group.value.map((skill) {
                    final value = abilities[skill] ?? 0;
                    return Text(
                      '$skill: $value',
                      style: TextStyle(
                        fontSize: 7,
                        color: value > 0 ? Colors.black : Colors.grey.shade400,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEquipmentSectionCheckboxes(Character character) {
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

    // Also check for custom weapons - check both locations
    List customWeapons = [];
    if (inventory['customWeapons'] != null) {
      customWeapons = inventory['customWeapons'] as List;
    } else if (enlistmentInventory is Map &&
        enlistmentInventory['customWeapons'] != null) {
      customWeapons = enlistmentInventory['customWeapons'] as List;
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

    // Equipment categories matching PDF form exactly
    final categories = <String, List<String>>{
      'HEAD/EYES': [
        'Helmet',
        'Kevlar helmet',
        'Goggles',
        'Sunglasses',
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
        'Combat knife',
        'Multi-tool',
        'Wire cutters',
        'Binoculars',
        'Entrenching tool',
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
        'Day patrol pack',
        'Personal medical kit',
        'Water canteen',
        'MRE',
        'Poncho',
        'Unit 1 Medical Kit',
      ],
      'LOAD BEARING': [
        'Load bearing vest',
        'Magazine pouches',
        'First aid pouch',
        'Grenade pouch',
        'Utility pouch',
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

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VI. EQUIPMENT / LOADOUT CHECKLIST',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...categories.entries.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    color: Colors.grey.shade200,
                    child: Text(
                      category.key,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: category.value.map((item) {
                      final isChecked = _equipmentChecked[item] ?? false;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _equipmentChecked[item] = !isChecked;
                          });
                          
                          // Notify parent of equipment change
                          if (widget.onEquipmentChanged != null) {
                            widget.onEquipmentChanged!(item, !isChecked);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(right: 2, top: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                color: isChecked ? Colors.black : Colors.white,
                              ),
                              child: isChecked
                                  ? Icon(
                                      Icons.check,
                                      size: 8,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Text(item, style: TextStyle(fontSize: 7)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: _buildSmallCheckboxField('ADDITIONAL')),
              const SizedBox(width: 4),
              Expanded(child: _buildSmallCheckboxField('HEALTH/MEDICAL')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCheckboxField(String label) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentPreview(Character character) {
    // Keep old method for compatibility
    final inventory = character.inventory;
    final weapons = (inventory['loadoutWeapons'] as List?) ?? [];
    final equipment = (inventory['selectedEquipment'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (weapons.isNotEmpty) ...[
          Text(
            'WEAPONS: ${weapons.join(', ')}',
            style: const TextStyle(fontSize: 7),
          ),
          const SizedBox(height: 4),
        ],
        if (equipment.isNotEmpty)
          Text(
            'EQUIPMENT: ${equipment.take(5).join(', ')}${equipment.length > 5 ? '...' : ''}',
            style: const TextStyle(fontSize: 7),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        if (weapons.isEmpty && equipment.isEmpty)
          Text('—', style: TextStyle(fontSize: 7, color: Colors.grey.shade400)),
      ],
    );
  }

  String _getSchools(Character character) {
    final deployments = character.enlistment['deployments'] as List? ?? [];
    final schools = deployments
        .map((d) => d['school'])
        .where((s) => s != null && s.toString().isNotEmpty)
        .toSet()
        .join(', ');
    return schools.isEmpty ? 'None' : schools;
  }

  String _getDeployments(Character character) {
    final deployments = character.enlistment['deployments'] as List? ?? [];
    if (deployments.isEmpty) return 'None';
    final locations = deployments
        .map((d) => d['location'])
        .where((l) => l != null)
        .toSet()
        .join(', ');
    return '${deployments.length}x ($locations)';
  }

  String _getAwards(Character character) {
    final deployments = character.enlistment['deployments'] as List? ?? [];
    final awards = deployments
        .map((d) => d['award'])
        .where((a) => a != null && a.toString() != 'None')
        .toSet()
        .join(', ');
    return awards.isEmpty ? 'None' : awards;
  }

  String _getFirstNarrativeParagraph(Character character) {
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
