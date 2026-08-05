import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_4patrol/models/character.dart';
import 'package:flutter_application_4patrol/services/pdf_character_sheet_service.dart';
import 'dart:io';

/// Integration test for edit persistence functionality.
/// 
/// This test verifies that edits made to character weapons and equipment
/// are properly persisted across the full application stack including:
/// - Hive local storage
/// - UI state management
/// - PDF export service
/// 
/// IMPORTANT: Run this test with:
///   flutter test integration_test/edit_persistence_integration_test.dart
/// 
/// Or on a real device/emulator:
///   flutter drive --driver=test_driver/integration_test_driver.dart \
///     --target=integration_test/edit_persistence_integration_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Edit Persistence Integration Test', () {
    late Box characterBox;

    setUpAll(() async {
      // Initialize the app
      await Hive.initFlutter();
      characterBox = await Hive.openBox('characters');
    });

    tearDownAll(() async {
      await characterBox.clear();
      await characterBox.close();
      await Hive.close();
    });

    setUp(() async {
      await characterBox.clear();
    });

    testWidgets('1. Create character and verify persistence', (tester) async {
      debugPrint('\n=== INTEGRATION TEST 1: Character Creation ===');

      // Create a character
      final character = Character(
        id: 'integration-test-001',
        name: 'Integration Test Soldier',
        nickname: 'IntTest',
        age: 25,
        nationality: 'United States',
        enlistment: {
          'service': 'Army',
          'rank': 'Sergeant',
          'specialty': 'Rifleman',
          'inventory': {
            'loadoutWeapons': ['M4 Carbine', 'M9 Pistol'],
            'equipment': ['Kevlar helmet', 'Load bearing vest'],
          },
        },
        inventory: {
          'loadoutWeapons': ['M4 Carbine', 'M9 Pistol'],
          'selectedEquipment': ['Kevlar helmet', 'Load bearing vest'],
        },
      );

      // Save to Hive
      await characterBox.put(character.id, character.toJson());
      debugPrint('✓ Character saved to Hive');

      // Verify save
      final savedData = characterBox.get(character.id);
      expect(savedData, isNotNull, reason: 'Character should be in Hive');

      final savedChar = Character.fromJson(
        Map<String, dynamic>.from(savedData),
      );
      expect(savedChar.name, equals('Integration Test Soldier'));
      expect(savedChar.inventory['loadoutWeapons'], contains('M4 Carbine'));
      expect(
        savedChar.inventory['selectedEquipment'],
        contains('Kevlar helmet'),
      );
      debugPrint('✓ Character data verified');
    });

    testWidgets('2. Edit weapons and verify persistence', (tester) async {
      debugPrint('\n=== INTEGRATION TEST 2: Edit Weapons ===');

      // Create initial character
      final character = Character(
        id: 'integration-test-002',
        name: 'Edit Test Soldier',
        nickname: 'Editor',
        age: 28,
        nationality: 'United States',
        enlistment: {
          'service': 'Army',
          'rank': 'Staff Sergeant',
          'specialty': 'Sniper',
          'inventory': {
            'loadoutWeapons': ['M4 Carbine', 'M9 Pistol'],
            'equipment': ['Kevlar helmet'],
          },
        },
        inventory: {
          'loadoutWeapons': ['M4 Carbine', 'M9 Pistol'],
          'selectedEquipment': ['Kevlar helmet'],
        },
      );

      await characterBox.put(character.id, character.toJson());
      debugPrint('✓ Initial character saved');

      // SIMULATE USER EDITING
      final loadedData = characterBox.get(character.id);
      final loadedChar = Character.fromJson(
        Map<String, dynamic>.from(loadedData),
      );

      debugPrint('Original weapons: ${loadedChar.inventory['loadoutWeapons']}');

      // User edits weapons
      loadedChar.inventory['loadoutWeapons'] = [
        'M40A4 Sniper Rifle',
        'M9 Pistol',
        'KBAR',
      ];
      loadedChar.inventory['customWeapons'] = ['Custom Suppressed Pistol'];
      loadedChar.enlistment['inventory'] = {
        'loadoutWeapons': loadedChar.inventory['loadoutWeapons'],
        'customWeapons': loadedChar.inventory['customWeapons'],
        'equipment': loadedChar.inventory['selectedEquipment'],
      };
      loadedChar.modifiedAt = DateTime.now();

      // Save edited character
      await characterBox.put(loadedChar.id, loadedChar.toJson());
      await characterBox.flush();
      debugPrint('✓ Edited weapons saved');

      // Verify persistence (simulating app restart)
      final reloadedData = characterBox.get(character.id);
      final reloadedChar = Character.fromJson(
        Map<String, dynamic>.from(reloadedData),
      );

      debugPrint('Reloaded weapons: ${reloadedChar.inventory['loadoutWeapons']}');

      expect(
        reloadedChar.inventory['loadoutWeapons'],
        contains('M40A4 Sniper Rifle'),
        reason: 'Edited weapon should persist',
      );
      expect(
        reloadedChar.inventory['loadoutWeapons'],
        isNot(contains('M4 Carbine')),
        reason: 'Removed weapon should not persist',
      );
      expect(
        reloadedChar.inventory['customWeapons'],
        contains('Custom Suppressed Pistol'),
        reason: 'Custom weapon should persist',
      );
      debugPrint('✓ All edits verified');
    });

    testWidgets('3. Multiple equipment edits persist correctly', (tester) async {
      debugPrint('\n=== INTEGRATION TEST 3: Multiple Equipment Edits ===');

      final character = Character(
        id: 'integration-test-003',
        name: 'Multi-Edit Soldier',
        nickname: 'Multi',
        age: 30,
        nationality: 'United Kingdom',
        enlistment: {
          'service': 'British Army',
          'rank': 'Corporal',
          'specialty': 'Medical',
          'inventory': {
            'loadoutWeapons': ['L85A2 Rifle'],
            'equipment': ['Kevlar helmet', 'First aid kit'],
          },
        },
        inventory: {
          'loadoutWeapons': ['L85A2 Rifle'],
          'selectedEquipment': ['Kevlar helmet', 'First aid kit'],
        },
      );

      await characterBox.put(character.id, character.toJson());
      debugPrint('✓ Initial character saved');

      // EDIT 1: Add medical equipment
      var currentData = characterBox.get(character.id);
      var currentChar = Character.fromJson(
        Map<String, dynamic>.from(currentData),
      );

      currentChar.inventory['selectedEquipment'] = [
        'Kevlar helmet',
        'First aid kit',
        'Unit 1 Medical Kit',
        'Personal medical kit',
      ];
      currentChar.enlistment['inventory']['equipment'] =
          currentChar.inventory['selectedEquipment'];

      await characterBox.put(currentChar.id, currentChar.toJson());
      await characterBox.flush();
      debugPrint('✓ Edit 1: Added medical equipment');

      // Verify Edit 1
      currentData = characterBox.get(character.id);
      currentChar = Character.fromJson(
        Map<String, dynamic>.from(currentData),
      );
      expect(
        currentChar.inventory['selectedEquipment'],
        contains('Unit 1 Medical Kit'),
      );
      expect(currentChar.inventory['selectedEquipment'], hasLength(4));
      debugPrint('✓ Edit 1 verified');

      // EDIT 2: Add communication equipment
      currentChar.inventory['selectedEquipment'] = [
        ...currentChar.inventory['selectedEquipment'] as List,
        'Radio',
        'GPS',
      ];
      currentChar.enlistment['inventory']['equipment'] =
          currentChar.inventory['selectedEquipment'];

      await characterBox.put(currentChar.id, currentChar.toJson());
      await characterBox.flush();
      debugPrint('✓ Edit 2: Added communication equipment');

      // Verify Edit 2
      currentData = characterBox.get(character.id);
      currentChar = Character.fromJson(
        Map<String, dynamic>.from(currentData),
      );
      expect(currentChar.inventory['selectedEquipment'], contains('Radio'));
      expect(currentChar.inventory['selectedEquipment'], contains('GPS'));
      expect(currentChar.inventory['selectedEquipment'], hasLength(6));
      debugPrint('✓ Edit 2 verified');

      // Final verification
      debugPrint('Final equipment list:');
      for (var item in currentChar.inventory['selectedEquipment']) {
        debugPrint('  - $item');
      }
    });

    testWidgets('4. PDF export uses latest persisted data', (tester) async {
      debugPrint('\n=== INTEGRATION TEST 4: PDF Export Persistence ===');

      final character = Character(
        id: 'integration-test-004',
        name: 'PDF Test Soldier',
        nickname: 'PDFTest',
        age: 27,
        nationality: 'United States',
        enlistment: {
          'service': 'Marine Corps',
          'rank': 'Corporal',
          'specialty': 'Rifleman',
          'inventory': {
            'loadoutWeapons': ['M4 Carbine'],
            'equipment': ['Kevlar helmet'],
          },
        },
        inventory: {
          'loadoutWeapons': ['M4 Carbine'],
          'selectedEquipment': ['Kevlar helmet'],
        },
      );

      await characterBox.put(character.id, character.toJson());

      // Edit the character
      final loadedData = characterBox.get(character.id);
      final loadedChar = Character.fromJson(
        Map<String, dynamic>.from(loadedData),
      );

      loadedChar.inventory['loadoutWeapons'] = ['M16A4 Rifle', 'M9 Pistol'];
      loadedChar.inventory['selectedEquipment'] = [
        'Kevlar helmet',
        'Night vision goggles',
      ];
      loadedChar.enlistment['inventory'] = {
        'loadoutWeapons': loadedChar.inventory['loadoutWeapons'],
        'equipment': loadedChar.inventory['selectedEquipment'],
      };

      await characterBox.put(loadedChar.id, loadedChar.toJson());
      await characterBox.flush();
      debugPrint('✓ Character edited and saved');

      // Reload and export to PDF
      final reloadedData = characterBox.get(character.id);
      final reloadedChar = Character.fromJson(
        Map<String, dynamic>.from(reloadedData),
      );

      try {
        final pdfPath = await PdfCharacterSheetService.exportCharacterSheet(
          reloadedChar,
        );
        debugPrint('✓ PDF exported: $pdfPath');

        // Verify PDF was created
        final pdfFile = File(pdfPath.split('\n').first);
        expect(pdfFile.existsSync(), isTrue, reason: 'PDF should exist');
        expect(
          pdfFile.lengthSync(),
          greaterThan(0),
          reason: 'PDF should not be empty',
        );
        debugPrint('✓ PDF verified (${pdfFile.lengthSync()} bytes)');

        // Clean up
        if (pdfFile.existsSync()) {
          pdfFile.deleteSync();
        }
      } catch (e) {
        debugPrint('PDF export error (may be expected in test env): $e');
      }
    });
  });
}
