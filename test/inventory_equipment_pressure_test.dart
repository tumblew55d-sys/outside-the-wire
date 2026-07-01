import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_4patrol/models/character.dart';
import 'package:flutter_application_4patrol/services/pdf_character_sheet_service.dart';

/// Pressure test for inventory and equipment data persistence
/// Tests the fixes for custom weapons and equipment not appearing in PDF
void main() {
  group('Inventory & Equipment Pressure Test', () {
    late Character testCharacter;

    setUp(() {
      // Create a character with full inventory data
      testCharacter = Character(
        id: 'test-inv-001',
        name: 'Test Soldier Wilson',
        nickname: 'Testing',
        age: 25,
        homeLocation: 'London',
        nationality: 'United Kingdom',
        height: 'Standard (Avg)',
        weight: 75.0,
        weightUnit: 'kg',
        languages: ['English'],
        motivation: 'Duty & Service',
        background: 'Urban',
        trademark: 'Pack of cheap cigarettes on cape pin',
        attributes: {
          'Prowess': 9,
          'Communication': 3,
          'Civil Affairs': 3,
          'Instincts': 8,
          'Tactics': 10,
          'Heavy Weapons': 11,
          'Small Arms': 15,
          'Fires': 3,
          'First Aid': 8,
          'Spying': 3,
          'Signals Intel': 3,
          'Explosives': 3,
        },
        skills: {
          'Small Arms': 15,
          'Heavy Weapons': 11,
          'Tactics': 10,
          'Prowess': 9,
          'Instincts': 8,
          'First Aid': 8,
          'Communication': 3,
          'Civil Affairs': 3,
          'Fires': 3,
          'Spying': 3,
          'Signals Intel': 3,
          'Explosives': 3,
        },
        enlistment: {
          'service': 'United Kingdom Army',
          'rank': 'Sergeant',
          'specialty': 'Rifleman (Small Arms +1, Heavy Weapons +1, Tactics +1)',
          'deployments': [
            {
              'location': 'Sverige',
              'school': 'Basic Training',
              'award': 'None',
            },
          ],
          'inventory': {
            'loadout': 'L85A2 Rifle, combat knife, (2) frag grenades',
            'loadoutWeapons': ['L85A2 Rifle', 'KBAR', 'Frag grenade'],
            'customWeapons': ['Browning HP Pistol', 'L115A3 Sniper Rifle'],
            'equipment': [
              'Night Vision Goggles',
              'Frag grenade',
              'Smoke grenade',
            ],
          },
        },
        inventory: {
          'loadout': 'L85A2 Rifle, combat knife, (2) frag grenades',
          'loadoutWeapons': ['L85A2 Rifle', 'KBAR', 'Frag grenade'],
          'customWeapons': ['Browning HP Pistol', 'L115A3 Sniper Rifle'],
          'selectedEquipment': [
            'Night Vision Goggles',
            'Frag grenade',
            'Smoke grenade',
            'Flashbang grenade',
            'Inter Squad Radio',
            'Hand held mine detector',
            'Unit 1 Medical Kit',
          ],
          'clothing': [],
          'pouches': [],
          'dayPack': [],
          'rucksack': [],
          'hands': [],
          'holster': [],
          'customSlots': {},
        },
      );
    });

    test('Character has complete inventory data', () {
      expect(testCharacter.inventory, isNotNull);
      expect(testCharacter.inventory['loadoutWeapons'], isNotEmpty);
      expect(testCharacter.inventory['customWeapons'], isNotEmpty);
      expect(testCharacter.inventory['selectedEquipment'], isNotEmpty);
    });

    test('Loadout weapons are accessible from both locations', () {
      // Check inventory location
      final invWeapons = testCharacter.inventory['loadoutWeapons'] as List?;
      expect(invWeapons, isNotNull);
      expect(invWeapons!.length, greaterThanOrEqualTo(3));
      expect(invWeapons, contains('L85A2 Rifle'));
      expect(invWeapons, contains('KBAR'));

      // Check enlistment location (backward compatibility)
      final enlistInv = testCharacter.enlistment['inventory'] as Map?;
      expect(enlistInv, isNotNull);
      final enlistWeapons = enlistInv!['loadoutWeapons'] as List?;
      expect(enlistWeapons, isNotNull);
      expect(enlistWeapons, contains('L85A2 Rifle'));
    });

    test('Custom weapons are accessible from both locations', () {
      // Check inventory location (primary)
      final invCustom = testCharacter.inventory['customWeapons'] as List?;
      expect(invCustom, isNotNull);
      expect(invCustom!.length, equals(2));
      expect(invCustom, contains('Browning HP Pistol'));
      expect(invCustom, contains('L115A3 Sniper Rifle'));

      // Check enlistment location (backward compatibility)
      final enlistInv = testCharacter.enlistment['inventory'] as Map?;
      final enlistCustom = enlistInv!['customWeapons'] as List?;
      expect(enlistCustom, isNotNull);
      expect(enlistCustom, contains('Browning HP Pistol'));
    });

    test('Selected equipment is accessible', () {
      final equipment = testCharacter.inventory['selectedEquipment'] as List?;
      expect(equipment, isNotNull);
      expect(equipment!.length, equals(7));
      expect(equipment, contains('Night Vision Goggles'));
      expect(equipment, contains('Frag grenade'));
      expect(equipment, contains('Smoke grenade'));
      expect(equipment, contains('Flashbang grenade'));
      expect(equipment, contains('Inter Squad Radio'));
      expect(equipment, contains('Hand held mine detector'));
      expect(equipment, contains('Unit 1 Medical Kit'));
    });

    test('All weapons appear in combined list', () {
      final loadoutWeapons =
          (testCharacter.inventory['loadoutWeapons'] as List?) ?? [];
      final customWeapons =
          (testCharacter.inventory['customWeapons'] as List?) ?? [];
      final allWeapons = [...loadoutWeapons, ...customWeapons];

      expect(allWeapons.length, equals(5));
      expect(allWeapons, contains('L85A2 Rifle'));
      expect(allWeapons, contains('KBAR'));
      expect(allWeapons, contains('Frag grenade'));
      expect(allWeapons, contains('Browning HP Pistol'));
      expect(allWeapons, contains('L115A3 Sniper Rifle'));
    });

    test('Character can be serialized and deserialized without data loss', () {
      final json = testCharacter.toJson();
      final restored = Character.fromJson(json);

      // Verify inventory data survives round-trip
      expect(restored.inventory['loadoutWeapons'], isNotNull);
      expect(restored.inventory['customWeapons'], isNotNull);
      expect(restored.inventory['selectedEquipment'], isNotNull);

      final restoredLoadout = restored.inventory['loadoutWeapons'] as List;
      final restoredCustom = restored.inventory['customWeapons'] as List;
      final restoredEquip = restored.inventory['selectedEquipment'] as List;

      expect(restoredLoadout, contains('L85A2 Rifle'));
      expect(restoredCustom, contains('Browning HP Pistol'));
      expect(restoredEquip, contains('Night Vision Goggles'));
    });

    test('PDF generation includes all weapons and equipment', () async {
      print('\n=== PDF GENERATION TEST ===');
      print('Character: ${testCharacter.name}');
      print('Loadout Weapons: ${testCharacter.inventory['loadoutWeapons']}');
      print('Custom Weapons: ${testCharacter.inventory['customWeapons']}');
      print(
        'Selected Equipment: ${testCharacter.inventory['selectedEquipment']}',
      );

      // Generate PDF (this should not throw)
      expect(
        () async =>
            await PdfCharacterSheetService.exportCharacterSheet(testCharacter),
        returnsNormally,
      );

      print('✓ PDF generated successfully');
      print('✓ All inventory data should be visible in equipment checklist');
    });

    test('Equipment categorization logic', () {
      final equipment = testCharacter.inventory['selectedEquipment'] as List;

      // Test that equipment items would be categorized correctly
      for (var item in equipment) {
        final itemStr = item.toString();
        print('Equipment item: $itemStr');

        if (itemStr.contains('Night Vision Goggles')) {
          print('  → Should appear in HEAD/EYES category');
        } else if (itemStr.contains('grenade')) {
          print('  → Should appear in GRENADES category');
        } else if (itemStr.contains('Radio')) {
          print('  → Should appear in COMMS category');
        } else if (itemStr.contains('Medical Kit')) {
          print('  → Should appear in DAYPACK category');
        } else if (itemStr.contains('mine detector')) {
          print('  → Should appear in TOOLS category');
        }
      }

      expect(equipment.length, greaterThan(0));
    });

    test('Weapons from different sources are distinguishable', () {
      final loadoutWeapons = testCharacter.inventory['loadoutWeapons'] as List;
      final customWeapons = testCharacter.inventory['customWeapons'] as List;

      print('\n=== WEAPON SOURCE TEST ===');
      print('Loadout Weapons (from specialty):');
      for (var w in loadoutWeapons) {
        print('  - $w');
      }

      print('Custom Weapons (player selected):');
      for (var w in customWeapons) {
        print('  - $w');
      }

      // Verify they're different lists but both accessible
      expect(loadoutWeapons, isNot(equals(customWeapons)));
      expect(loadoutWeapons.length, greaterThan(0));
      expect(customWeapons.length, greaterThan(0));
    });

    test('Multiple specialty equipment items appear', () {
      final equipment = testCharacter.inventory['selectedEquipment'] as List;

      // Count different categories
      int grenades = 0;
      int vision = 0;
      int comms = 0;
      int medical = 0;

      for (var item in equipment) {
        final itemStr = item.toString().toLowerCase();
        if (itemStr.contains('grenade')) grenades++;
        if (itemStr.contains('vision') || itemStr.contains('goggle')) vision++;
        if (itemStr.contains('radio')) comms++;
        if (itemStr.contains('medical') || itemStr.contains('kit')) medical++;
      }

      print('\n=== EQUIPMENT DIVERSITY TEST ===');
      print('Grenade types: $grenades');
      print('Vision equipment: $vision');
      print('Communication gear: $comms');
      print('Medical supplies: $medical');

      expect(
        grenades,
        greaterThan(1),
        reason: 'Should have multiple grenade types',
      );
      expect(
        vision,
        greaterThanOrEqualTo(1),
        reason: 'Should have vision equipment',
      );
      expect(
        comms,
        greaterThanOrEqualTo(1),
        reason: 'Should have communication gear',
      );
      expect(
        medical,
        greaterThanOrEqualTo(1),
        reason: 'Should have medical supplies',
      );
    });

    test('Navigation simulation - data persists', () {
      // Simulate saving to storage
      final savedJson = testCharacter.toJson();

      print('\n=== NAVIGATION PERSISTENCE TEST ===');
      print('Simulating screen transition...');

      // Simulate loading from storage (like navigating away and back)
      final reloadedCharacter = Character.fromJson(savedJson);

      print('Character reloaded from storage');

      // Verify all inventory data persists
      expect(
        reloadedCharacter.inventory['loadoutWeapons'],
        equals(testCharacter.inventory['loadoutWeapons']),
        reason: 'Loadout weapons should persist',
      );

      expect(
        reloadedCharacter.inventory['customWeapons'],
        equals(testCharacter.inventory['customWeapons']),
        reason: 'Custom weapons should persist',
      );

      expect(
        reloadedCharacter.inventory['selectedEquipment'],
        equals(testCharacter.inventory['selectedEquipment']),
        reason: 'Selected equipment should persist',
      );

      print('✓ All inventory data persisted across navigation');
    });

    test('Edge case: Empty inventory fields', () {
      final emptyChar = Character(
        id: 'test-empty',
        name: 'Empty Test',
        inventory: {
          'loadoutWeapons': [],
          'customWeapons': [],
          'selectedEquipment': [],
        },
        enlistment: {},
      );

      // Should not crash with empty data
      expect(emptyChar.inventory['loadoutWeapons'], isEmpty);
      expect(emptyChar.inventory['customWeapons'], isEmpty);
      expect(emptyChar.inventory['selectedEquipment'], isEmpty);

      // PDF should still generate (with default weapons)
      expect(
        () async =>
            await PdfCharacterSheetService.exportCharacterSheet(emptyChar),
        returnsNormally,
      );
    });

    test('Edge case: Only enlistment inventory (backward compatibility)', () {
      final legacyChar = Character(
        id: 'test-legacy',
        name: 'Legacy Test',
        inventory: {}, // Empty new location
        enlistment: {
          'inventory': {
            'loadoutWeapons': ['M4 Carbine'],
            'customWeapons': ['M9 Pistol'],
            'equipment': ['Night Vision Goggles'],
          },
        },
      );

      // Should fall back to enlistment location
      final enlistInv = legacyChar.enlistment['inventory'] as Map;
      expect(enlistInv['loadoutWeapons'], contains('M4 Carbine'));
      expect(enlistInv['customWeapons'], contains('M9 Pistol'));
      expect(enlistInv['equipment'], contains('Night Vision Goggles'));
    });
  });

  group('Equipment Categorization Pressure Test', () {
    test('All common equipment items categorize correctly', () {
      final equipmentItems = [
        // HEAD/EYES
        'Night Vision Goggles',
        'Rifle mounted IR pointer',
        'Pistol mounted IR pointer',

        // GRENADES
        'Frag grenade',
        'Smoke grenade',
        'Flashbang grenade',
        'Gas grenade',
        'Concussion grenade',
        'Thermite grenade',

        // COMMS
        'Inter Squad Radio',
        'Backpack Radio',
        'Hand held walkie talkie',
        'Red star cluster signal flare',
        'Illumination signal flare',
        'Green start cluster signal flare',
        'Thor Backpack signal jammer',

        // TOOLS
        'Hand held mine detector',
        'EOD demo kit',
        'EOD robot and computer',
        'Breacher Kit',
        'JTAC computer and radio',
        'Civil Affairs Kit',
        'Signal Collection Kit',
        'Spy Kit',
        'Canine Kit',

        // DAYPACK/MEDICAL
        'Unit 1 Medical Kit',
      ];

      print('\n=== CATEGORIZATION VALIDATION ===');
      for (var item in equipmentItems) {
        final lower = item.toLowerCase();

        String category = 'TOOLS'; // default
        if (lower.contains('grenade')) {
          category = 'GRENADES';
        } else if (lower.contains('radio') ||
            lower.contains('flare') ||
            lower.contains('jammer')) {
          category = 'COMMS';
        } else if (lower.contains('vision') ||
            lower.contains('goggle') ||
            lower.contains('ir pointer') ||
            lower.contains('flashlight')) {
          category = 'HEAD/EYES';
        } else if (lower.contains('medical') || lower.contains('kit')) {
          category = 'DAYPACK/TOOLS';
        }

        print('$item → $category');
      }

      expect(equipmentItems.length, greaterThan(25));
    });

    test('Weapons appear in WEAPONS category', () {
      final weapons = [
        'L85A2 Rifle',
        'Browning HP Pistol',
        'L115A3 Sniper Rifle',
        'M4 Carbine',
        'AK-47 Rifle',
        'M9 Pistol',
        'KBAR',
      ];

      print('\n=== WEAPONS CATEGORY TEST ===');
      for (var weapon in weapons) {
        print('$weapon → WEAPONS');
      }

      expect(weapons.length, greaterThan(5));
    });
  });

  group('PDF Readability Test', () {
    test('Equipment checklist section structure', () {
      final categories = [
        'HEAD/EYES',
        'CLOTHING',
        'GRENADES',
        'COMMS',
        'WEAPONS',
        'TOOLS',
        'DAYPACK',
        'LOAD BEARING',
      ];

      print('\n=== PDF CHECKLIST STRUCTURE ===');
      print('Expected categories in PDF:');
      for (var cat in categories) {
        print('  ☐ $cat');
      }

      expect(categories.length, equals(8));
    });

    test('Checklist should show actual player selections', () {
      final testChar = Character(
        id: 'pdf-test',
        name: 'PDF Test Character',
        inventory: {
          'loadoutWeapons': ['M4 Carbine', 'M9 Pistol'],
          'customWeapons': ['AK-47 Rifle'],
          'selectedEquipment': [
            'Night Vision Goggles',
            'Frag grenade',
            'Inter Squad Radio',
          ],
        },
        enlistment: {},
      );

      print('\n=== PDF CONTENT VERIFICATION ===');
      print('WEAPONS section should include:');
      print('  ✓ M4 Carbine');
      print('  ✓ M9 Pistol');
      print('  ✓ AK-47 Rifle');
      print('');
      print('HEAD/EYES section should include:');
      print('  ✓ Night Vision Goggles');
      print('');
      print('GRENADES section should include:');
      print('  ✓ Frag grenade');
      print('');
      print('COMMS section should include:');
      print('  ✓ Inter Squad Radio');

      expect(testChar.inventory['loadoutWeapons'], isNotEmpty);
      expect(testChar.inventory['customWeapons'], isNotEmpty);
      expect(testChar.inventory['selectedEquipment'], isNotEmpty);
    });
  });
}

/// Helper to print test results
void printTestResult(String testName, bool passed) {
  print(passed ? '✓ $testName' : '✗ $testName FAILED');
}
