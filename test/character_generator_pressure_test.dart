import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_application_4patrol/models/character.dart';
import 'package:flutter_application_4patrol/services/quick_build_service.dart';

/// Comprehensive Pressure Test for Character Generator
/// Tests logic, data integrity, and edge cases without Hive dependency
/// Run with: flutter test test/character_generator_pressure_test.dart
void main() {
  group('Character Generator Logic Tests', () {
    late Stopwatch stopwatch;

    setUp(() {
      stopwatch = Stopwatch();
    });

    test('Rapid Character Generation - 50 Basic Characters', () async {
      const targetCount = 50;
      final uuid = const Uuid();
      final characters = <Character>[];

      stopwatch.start();

      for (int i = 0; i < targetCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(
          characterId,
          'US',
          'Test User $i',
        );

        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        characters.add(character);
      }

      stopwatch.stop();

      // Verify all characters were created
      expect(characters.length, targetCount);

      // Performance check: should complete in under 30 seconds
      final duration = stopwatch.elapsedMilliseconds;
      print(
        '✅ Created $targetCount characters in ${duration}ms (${(duration / targetCount).toStringAsFixed(2)}ms per character)',
      );
      expect(duration, lessThan(30000), reason: 'Batch creation took too long');
    });

    test('All Specialty Types - Data Integrity', () async {
      final specialties = [
        'Rifleman',
        'Heavy Weapons',
        'EOD',
        'JTAC',
        'SOF',
        'Agent',
        'Medic',
        'Sniper',
      ];

      final uuid = const Uuid();
      final characters = <Character>[];

      stopwatch.start();

      for (final specialty in specialties) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(
          characterId,
          'US',
          'Specialist $specialty',
        );

        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          specialty,
          baseChar,
        );

        characters.add(character);

        // Verify character data integrity
        expect(character.id, characterId);
        expect(character.name, isNotEmpty);
        expect(character.attributes, isNotEmpty);
        expect(character.skills, isNotEmpty);
        expect(character.enlistment, isNotEmpty);
        expect(character.inventory, isNotEmpty);
      }

      stopwatch.stop();

      // Verify all characters can be serialized and deserialized
      for (final character in characters) {
        final json = character.toJson();
        final reloaded = Character.fromJson(json);
        expect(reloaded.id, character.id);
        expect(reloaded.attributes.isNotEmpty, true);
        expect(reloaded.skills.isNotEmpty, true);
      }

      print(
        '✅ All ${specialties.length} specialty types created and verified in ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    test('Concurrent Character Creation - 20 Parallel Operations', () async {
      const concurrentCount = 20;
      final uuid = const Uuid();

      stopwatch.start();

      // Create 20 characters concurrently
      final futures = <Future<Character>>[];
      for (int i = 0; i < concurrentCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(
          characterId,
          'UK',
          'Concurrent Test $i',
        );

        final future = QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        futures.add(future);
      }

      final characters = await Future.wait(futures);
      stopwatch.stop();

      expect(characters.length, concurrentCount);
      print(
        '✅ Created $concurrentCount characters concurrently in ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    test('Large Character Batch - Serialization Performance Test', () async {
      const characterCount = 100;
      final uuid = const Uuid();
      final serializedData = <String, Map<String, dynamic>>{};

      // Create 100 characters first
      for (int i = 0; i < characterCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(
          characterId,
          'Germany',
          'Load Test $i',
        );

        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        serializedData[characterId] = character.toJson();
      }

      // Now test deserializing all characters
      stopwatch.start();
      final characters = <Character>[];

      for (final entry in serializedData.entries) {
        final character = Character.fromJson(entry.value);
        characters.add(character);
      }

      stopwatch.stop();

      expect(characters.length, characterCount);

      // Should deserialize in under 1 second
      final duration = stopwatch.elapsedMilliseconds;
      print(
        '✅ Deserialized $characterCount characters in ${duration}ms (${(duration / characterCount).toStringAsFixed(2)}ms per character)',
      );
      expect(duration, lessThan(1000), reason: 'Deserialization took too long');
    });

    test('Serialization - Save/Reload Verification', () async {
      final uuid = const Uuid();
      final characterId = uuid.v4();

      final baseChar = _createBaseCharacter(
        characterId,
        'France',
        'Persistence Test',
      );
      final character = await QuickBuildService.generateQuickCharacter(
        characterId,
        'SOF',
        baseChar,
      );

      // Serialize to JSON
      final json = character.toJson();
      expect(json, isNotNull);

      // Deserialize from JSON
      final reloaded = Character.fromJson(json);

      // Verify all fields match
      expect(reloaded.id, character.id);
      expect(reloaded.name, character.name);
      expect(reloaded.nationality, character.nationality);
      expect(reloaded.attributes, character.attributes);
      expect(reloaded.skills, character.skills);
      expect(reloaded.isSOF, character.isSOF);
      expect(
        reloaded.enlistment['specialty'],
        character.enlistment['specialty'],
      );
      expect(reloaded.inventory.isNotEmpty, true);

      print('✅ Serialization verified - all fields match');
    });

    test('Edge Cases - Boundary Values', () async {
      final uuid = const Uuid();

      // Test 1: Minimum age
      final youngId = uuid.v4();
      final youngChar = _createBaseCharacter(
        youngId,
        'US',
        'Young Recruit',
        age: 17,
      );
      final young = await QuickBuildService.generateQuickCharacter(
        youngId,
        'Rifleman',
        youngChar,
      );
      expect(young.age, greaterThanOrEqualTo(17));

      // Test 2: Maximum age value
      final oldId = uuid.v4();
      final oldChar = _createBaseCharacter(oldId, 'US', 'Veteran', age: 65);
      final old = await QuickBuildService.generateQuickCharacter(
        oldId,
        'Agent',
        oldChar,
      );
      expect(old.age, greaterThan(65));

      // Test 3: Empty optional fields
      final minimalId = uuid.v4();
      final minimalChar = Character(
        id: minimalId,
        name: 'Minimal',
        nationality: 'US',
        age: 18,
        userId: 'test',
        modifiedAt: DateTime.now(),
      );
      final minimal = await QuickBuildService.generateQuickCharacter(
        minimalId,
        'Rifleman',
        minimalChar,
      );

      // Should still generate valid character
      expect(minimal.attributes, isNotEmpty);
      expect(minimal.skills, isNotEmpty);

      // Test 4: Special characters in name
      final specialId = uuid.v4();
      final specialChar = _createBaseCharacter(
        specialId,
        'Japan',
        'Sgt. "Ghost" O\'Brien-Müller',
      );
      final special = await QuickBuildService.generateQuickCharacter(
        specialId,
        'Sniper',
        specialChar,
      );

      // Verify serialization works with special characters
      final json = special.toJson();
      final reloaded = Character.fromJson(json);
      expect(reloaded.name, 'Sgt. "Ghost" O\'Brien-Müller');

      print('✅ All edge cases handled correctly');
    });

    test('Stress Test - Repeated Serialization', () async {
      const iterations = 100;
      final uuid = const Uuid();
      final characterId = uuid.v4();

      // Create initial character
      final baseChar = _createBaseCharacter(
        characterId,
        'Canada',
        'Stress Test',
      );
      var character = await QuickBuildService.generateQuickCharacter(
        characterId,
        'Rifleman',
        baseChar,
      );
      final initialAge = character.age;

      stopwatch.start();

      // Repeatedly serialize, deserialize, and modify
      Map<String, dynamic> json = character.toJson();
      for (int i = 0; i < iterations; i++) {
        // Deserialize
        character = Character.fromJson(json);

        // Modify
        character.age = character.age + 1;
        character.modifiedAt = DateTime.now();

        // Serialize
        json = character.toJson();
      }

      stopwatch.stop();

      // Verify final state
      final finalChar = Character.fromJson(json);
      expect(finalChar.age, initialAge + iterations);

      final duration = stopwatch.elapsedMilliseconds;
      print(
        '✅ Completed $iterations serialize/deserialize cycles in ${duration}ms (${(duration / iterations).toStringAsFixed(2)}ms per cycle)',
      );
      expect(duration, lessThan(5000), reason: 'Repeated operations too slow');
    });

    test('Multi-Nationality Character Generation', () async {
      final nationalities = [
        'US',
        'UK',
        'Germany',
        'France',
        'Canada',
        'Australia',
        'Poland',
        'Italy',
        'Japan',
        'Spain',
        'Netherlands',
        'Sweden',
        'Belgium',
        'Norway',
      ];

      final uuid = const Uuid();
      final characters = <Character>[];

      stopwatch.start();

      for (final nationality in nationalities) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(
          characterId,
          nationality,
          '$nationality Soldier',
        );

        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        characters.add(character);

        // Verify nationality-specific data
        expect(character.nationality, nationality);
        expect(character.enlistment['rank'], isNotEmpty);
      }

      stopwatch.stop();

      expect(characters.length, nationalities.length);
      print(
        '✅ Created characters from ${nationalities.length} nationalities in ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    test('Memory Stress Test - Character JSON Size', () async {
      final uuid = const Uuid();
      final characterId = uuid.v4();

      // Create a character with maximum data
      final baseChar = _createMaximalCharacter(characterId);
      final character = await QuickBuildService.generateQuickCharacter(
        characterId,
        'Agent',
        baseChar,
      );

      // Add maximum equipment
      character.inventory = {
        'loadout': 'Heavy Assault',
        'loadoutWeapons': List.generate(10, (i) => 'Weapon $i'),
        'customWeapons': List.generate(5, (i) => 'Custom $i'),
        'selectedEquipment': List.generate(20, (i) => 'Equipment $i'),
        'clothing': List.generate(10, (i) => 'Clothing $i'),
        'pouches': List.generate(10, (i) => 'Pouch $i'),
        'dayPack': List.generate(10, (i) => 'DayPack $i'),
        'rucksack': List.generate(15, (i) => 'Ruck $i'),
        'hands': List.generate(5, (i) => 'Hands $i'),
        'holster': List.generate(5, (i) => 'Holster $i'),
        'customSlots': {
          'slot1': 'Custom 1',
          'slot2': 'Custom 2',
          'slot3': 'Custom 3',
        },
      };

      character.medals = List.generate(10, (i) => 'Medal $i');
      character.languages = List.generate(8, (i) => 'Language $i');

      final json = character.toJson();

      // Verify it can be reloaded
      final reloaded = Character.fromJson(json);
      expect(reloaded.inventory['loadoutWeapons'].length, 10);
      expect(reloaded.medals.length, 10);
      expect(reloaded.languages.length, 8);

      // Estimate JSON size
      final jsonSize = json.toString().length;
      print(
        '✅ Maximal character JSON size: $jsonSize bytes (~${(jsonSize / 1024).toStringAsFixed(2)} KB)',
      );
      expect(jsonSize, lessThan(100000), reason: 'Character JSON too large');
    });

    test('Error Recovery - Invalid Data Handling', () async {
      // Test 1: Corrupted data with missing fields - should use defaults
      final corruptedData = {'incomplete': 'data'};

      final corruptedChar = Character.fromJson(corruptedData);
      // Should create character with default values
      expect(corruptedChar.id, '');
      expect(corruptedChar.age, 17); // Default age

      // Test 2: Partial data - should fill in defaults
      final partialData = {
        'id': 'test-id',
        'name': 'Partial',
        // Missing many fields
      };

      final partialChar = Character.fromJson(partialData);
      expect(partialChar.id, 'test-id');
      expect(partialChar.name, 'Partial');
      expect(partialChar.age, 17); // Default
      expect(partialChar.nationality, ''); // Default

      // Test 3: Null values should be handled gracefully
      final nullData = {
        'id': 'null-test',
        'name': null,
        'age': null,
        'nationality': null,
        'userId': 'test',
        'modifiedAt': DateTime.now().toIso8601String(),
      };

      final nullChar = Character.fromJson(nullData);
      expect(nullChar.id, 'null-test');
      expect(nullChar.name, ''); // Default for null
      expect(nullChar.age, 17); // Default for null

      print('✅ Error recovery mechanisms working correctly');
    });

    test('Attribute Calculation Integrity', () async {
      final uuid = const Uuid();
      final characterId = uuid.v4();

      final baseChar = _createBaseCharacter(
        characterId,
        'US',
        'Attribute Test',
      );
      final character = await QuickBuildService.generateQuickCharacter(
        characterId,
        'SOF',
        baseChar,
      );

      // Verify attributes are within valid ranges
      for (final entry in character.attributes.entries) {
        expect(
          entry.value,
          greaterThanOrEqualTo(1),
          reason: '${entry.key} too low',
        );
        expect(
          entry.value,
          lessThanOrEqualTo(30),
          reason: '${entry.key} too high',
        );
      }

      // Verify skills are non-negative
      for (final entry in character.skills.entries) {
        expect(
          entry.value,
          greaterThanOrEqualTo(0),
          reason: '${entry.key} negative',
        );
        expect(
          entry.value,
          lessThanOrEqualTo(20),
          reason: '${entry.key} unreasonably high',
        );
      }

      // Verify enlistment data exists
      expect(character.enlistment['specialty'], isNotEmpty);
      expect(character.enlistment['rank'], isNotEmpty);
      expect(character.enlistment['deployments'], isNotEmpty);

      print('✅ Attribute and skill calculations within valid ranges');
    });

    test('Data Integrity - Collection Management', () async {
      final uuid = const Uuid();
      final characterMap = <String, Character>{};

      // Create 10 characters
      for (int i = 0; i < 10; i++) {
        final id = uuid.v4();
        final baseChar = _createBaseCharacter(id, 'US', 'Collection Test $i');
        final character = await QuickBuildService.generateQuickCharacter(
          id,
          'Rifleman',
          baseChar,
        );
        characterMap[id] = character;
      }

      expect(characterMap.length, 10);

      // Remove half the characters
      final keysToRemove = characterMap.keys.take(5).toList();
      for (final key in keysToRemove) {
        characterMap.remove(key);
      }

      expect(characterMap.length, 5);

      // Verify remaining characters are intact
      for (final character in characterMap.values) {
        expect(character.name, startsWith('Collection Test'));
        expect(character.attributes, isNotEmpty);
      }

      print('✅ Collection management working correctly');
    });

    test('Update Operations - Modification Tracking', () async {
      final uuid = const Uuid();
      final characterId = uuid.v4();

      final baseChar = _createBaseCharacter(
        characterId,
        'Spain',
        'Update Test',
      );
      final character = await QuickBuildService.generateQuickCharacter(
        characterId,
        'Rifleman',
        baseChar,
      );

      final initialModified = character.modifiedAt;
      final initialAge = character.age;

      // Wait a moment to ensure timestamp difference
      await Future.delayed(const Duration(milliseconds: 10));

      // Serialize and deserialize
      final json = character.toJson();
      final updated = Character.fromJson(json);
      updated.name = 'Updated Name';
      updated.age = updated.age + 4;
      updated.modifiedAt = DateTime.now();

      final updatedJson = updated.toJson();

      // Verify update
      final reloaded = Character.fromJson(updatedJson);
      expect(reloaded.name, 'Updated Name');
      expect(reloaded.age, initialAge + 4);
      expect(reloaded.modifiedAt.isAfter(initialModified), true);

      print('✅ Update operations and modification tracking working');
    });

    test('QuickBuild Performance - All Advanced Specialties', () async {
      final advancedSpecialties = ['EOD', 'JTAC', 'SOF', 'Agent'];
      final uuid = const Uuid();
      final timings = <String, int>{};

      for (final specialty in advancedSpecialties) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(
          characterId,
          'US',
          '$specialty Specialist',
        );

        final sw = Stopwatch()..start();
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          specialty,
          baseChar,
        );
        sw.stop();

        timings[specialty] = sw.elapsedMilliseconds;

        // Verify advanced specialty requirements
        if (specialty == 'SOF' || specialty == 'Agent') {
          expect(character.isSOF, true);
        }
      }

      print('Advanced specialty generation timings:');
      timings.forEach((specialty, ms) {
        print('  $specialty: ${ms}ms');
      });

      // All should complete in under 2 seconds each
      timings.forEach((specialty, ms) {
        expect(ms, lessThan(2000), reason: '$specialty took too long');
      });
    });

    test('Batch Operations - Multiple Rapid Updates', () async {
      const batchSize = 25;
      final uuid = const Uuid();
      final characters = <Character>[];

      // Create batch of characters
      for (int i = 0; i < batchSize; i++) {
        final id = uuid.v4();
        final baseChar = _createBaseCharacter(id, 'Italy', 'Batch $i');
        final character = await QuickBuildService.generateQuickCharacter(
          id,
          'Rifleman',
          baseChar,
        );
        characters.add(character);
      }

      stopwatch.start();

      // Batch serialize and deserialize all characters
      final jsonList = <Map<String, dynamic>>[];
      for (final char in characters) {
        char.age = char.age + 1;
        char.modifiedAt = DateTime.now();
        jsonList.add(char.toJson());
      }

      // Deserialize all
      final updated = <Character>[];
      for (final json in jsonList) {
        updated.add(Character.fromJson(json));
      }

      stopwatch.stop();

      // Verify all updated
      expect(updated.length, batchSize);

      print(
        '✅ Batch processed $batchSize characters in ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    test('Maximum Batch - 200 Character Generation', () async {
      const maxCharacters = 200;
      final uuid = const Uuid();
      final characters = <Character>[];

      stopwatch.start();

      // Create maximum number of characters
      for (int i = 0; i < maxCharacters; i++) {
        final id = uuid.v4();
        final baseChar = _createBaseCharacter(
          id,
          'Poland',
          'Character $i',
          age: 20 + (i % 40),
        );
        final character = await QuickBuildService.generateQuickCharacter(
          id,
          i % 2 == 0 ? 'Rifleman' : 'Medic',
          baseChar,
        );
        characters.add(character);
      }

      stopwatch.stop();

      expect(characters.length, maxCharacters);

      final duration = stopwatch.elapsedMilliseconds;
      print('✅ Created $maxCharacters characters in ${duration}ms');
      print(
        '   Average: ${(duration / maxCharacters).toStringAsFixed(2)}ms per character',
      );

      // Should handle 200 characters reasonably
      expect(
        duration,
        lessThan(60000),
        reason: 'Large batch creation too slow',
      );
    });
  });
}

/// Helper function to create a base character for testing
Character _createBaseCharacter(
  String id,
  String nationality,
  String name, {
  int age = 20,
}) {
  // Map nationalities to their primary languages
  final languageMap = {
    'US': 'English',
    'UK': 'English',
    'Germany': 'German',
    'France': 'French',
    'Canada': 'English',
    'Australia': 'English',
    'Poland': 'Polish',
    'Italy': 'Italian',
    'Japan': 'Japanese',
    'Spain': 'Spanish',
    'Netherlands': 'Dutch',
    'Sweden': 'Swedish',
    'Belgium': 'French',
    'Norway': 'Norwegian',
  };

  return Character(
    id: id,
    userId: 'test-user',
    name: name,
    nickname: '',
    age: age,
    homeLocation: 'Test City',
    nationality: nationality,
    height: 'Standard (Avg)',
    weight: 170.0,
    weightUnit: 'lb',
    languages: [languageMap[nationality] ?? 'English'],
    motivation: 'Test motivation',
    background: 'Test background',
    trademark: 'Test trademark',
    characterHook: 'Test hook',
    specialtyHook: '',
    personalConflict: 'Test conflict',
    isSOF: false,
    medals: [],
    canineBreed: '',
    canineName: '',
    attributes: {},
    skills: {},
    enlistment: {},
    inventory: {},
    portraitUrl: '',
    customEquipmentImages: {},
    modifiedAt: DateTime.now(),
  );
}

/// Helper function to create a character with maximal data
Character _createMaximalCharacter(String id) {
  return Character(
    id: id,
    userId: 'max-test-user',
    name: 'Maximilian "Max" Testington-Wellington III',
    nickname: 'The Maximum',
    age: 45,
    homeLocation:
        'Very Long City Name With Many Words And Special Characters: Test-City, ST 12345',
    nationality: 'US',
    height: 'Very Tall (6\'8")',
    weight: 250.5,
    weightUnit: 'lb',
    languages: [
      'English',
      'Spanish',
      'Arabic',
      'Russian',
      'German',
      'French',
      'Mandarin',
      'Japanese',
    ],
    motivation:
        'A very long motivation text that goes into great detail about the character\'s reasons for joining the military and their personal goals and aspirations that drive them forward in their career.',
    background:
        'An extensive background story covering childhood, education, military career, significant life events, relationships, and formative experiences that shaped the character into who they are today.',
    trademark:
        'Multiple trademarks including distinctive appearance features, behavioral quirks, signature moves, and memorable catchphrases that identify this character.',
    characterHook:
        'A compelling narrative hook that draws attention and makes this character interesting and memorable to players and game masters alike.',
    specialtyHook:
        'Specialty-specific hook detailing expertise and reputation within their field.',
    personalConflict:
        'Deep personal conflicts involving moral dilemmas, past traumas, difficult relationships, and ongoing struggles.',
    isSOF: true,
    medals: List.generate(10, (i) => 'Distinguished Medal $i'),
    canineBreed: 'Belgian Malinois',
    canineName: 'Rex von Testenhausen',
    attributes: {
      'Strength': 15,
      'Combat Knowledge': 15,
      'Leadership': 10,
      'Fieldcraft': 12,
    },
    skills: {
      'Combat': 10,
      'Driving': 8,
      'Tactics': 9,
      'Medicine': 6,
      'Demolitions': 7,
      'Languages': 8,
    },
    enlistment: {
      'service': 'Army',
      'rankType': 'Officer',
      'rank': 'Captain',
      'specialty': 'SOF',
      'deployments': List.generate(
        5,
        (i) => {
          'location': 'Deployment Location $i with very long description',
          'award': 'Distinguished Award $i',
          'school': 'Advanced School $i',
          'survival': 'Dramatic survival story $i',
        },
      ),
    },
    inventory: {},
    portraitUrl: 'https://example.com/very/long/url/to/portrait/image/file.jpg',
    customEquipmentImages: {},
    modifiedAt: DateTime.now(),
  );
}
