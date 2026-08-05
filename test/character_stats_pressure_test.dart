import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_application_4patrol/models/character.dart';
import 'package:flutter_application_4patrol/services/quick_build_service.dart';

/// Comprehensive Pressure Test for Character Stats Generation
/// Tests abilities: Prowess (Small Arms, Heavy Weapons, First Aid)
/// Tactics (Spying, Explosives, Signals Intel)
/// Instincts (Communication/Civil Affairs, Fires, Radio Ops)
/// Physical Attributes (Strength, Agility, Combat Wisdom, Combat Knowledge)
///
/// Focus: Experience points from schools, deployments, awards with multiple checks
/// Run with: flutter test test/character_stats_pressure_test.dart
void main() {
  group('Character Stats Validation - Attributes', () {
    test('Base Attribute Rolls - 1000 Characters (Valid Range 3-10)', () async {
      const testCount = 1000;
      final uuid = const Uuid();
      final attributeRanges = <String, List<int>>{};

      print('\n=== BASE ATTRIBUTE VALIDATION ===');

      for (int i = 0; i < testCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(characterId, 'US', 'Test $i');
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        // Track each attribute
        character.attributes.forEach((key, value) {
          attributeRanges.putIfAbsent(key, () => []);
          attributeRanges[key]!.add(value);
        });
      }

      // Analyze ranges
      attributeRanges.forEach((attribute, values) {
        final min = values.reduce((a, b) => a < b ? a : b);
        final max = values.reduce((a, b) => a > b ? a : b);
        final avg = values.reduce((a, b) => a + b) / values.length;

        print(
          '  $attribute: min=$min, max=$max, avg=${avg.toStringAsFixed(2)}',
        );

        // Base roll is 3 + 1d8 = 3-10 (before bonuses)
        // With bonuses from schools/deployments, max can be higher
        expect(
          min,
          greaterThanOrEqualTo(3),
          reason: '$attribute minimum too low',
        );
        expect(
          max,
          lessThanOrEqualTo(20),
          reason: '$attribute maximum suspicious',
        );
      });

      print('✅ All attributes within expected ranges\n');
    });

    test('School Bonuses - Strength +1 Per School', () async {
      const testCount = 100;
      final uuid = const Uuid();
      var schoolBonusErrors = 0;

      print('\n=== SCHOOL STRENGTH BONUS VALIDATION ===');

      for (int i = 0; i < testCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(
          characterId,
          'Germany',
          'Test $i',
        );
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        // Count schools attended
        final deployments = character.enlistment['deployments'] as List? ?? [];
        var schoolCount = 0;
        for (var deployment in deployments) {
          if (deployment is Map && deployment['school'] != null) {
            schoolCount++;
          }
        }

        // Get base and final strength
        final baseAttributes = character.enlistment['baseAttributes'];
        if (baseAttributes != null && baseAttributes is Map) {
          final baseStrength = baseAttributes['Strength'] ?? 0;
          final finalStrength = character.attributes['Strength'] ?? 0;
          final expectedBonus = schoolCount; // Each school gives +1 Strength

          // Allow for other bonuses (promotions, SOF), but verify school bonus minimum
          if (finalStrength < baseStrength + expectedBonus) {
            schoolBonusErrors++;
            print(
              '  ⚠️ Character $i: Expected Strength +$expectedBonus from $schoolCount schools',
            );
            print(
              '     Base: $baseStrength, Final: $finalStrength, Difference: ${finalStrength - baseStrength}',
            );
          }
        }
      }

      print('School bonus errors: $schoolBonusErrors / $testCount');
      expect(
        schoolBonusErrors,
        0,
        reason: 'School Strength bonuses not applying correctly',
      );
      print('✅ School Strength bonuses verified\n');
    });

    test('Elite School Bonuses - Knowledge +1 For Ranger Equivalent', () async {
      const testCount = 50;
      final uuid = const Uuid();
      var eliteSchoolCount = 0;
      var correctBonuses = 0;

      print('\n=== ELITE SCHOOL KNOWLEDGE BONUS VALIDATION ===');

      for (int i = 0; i < testCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(characterId, 'US', 'Test $i');
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'SOF', // SOF always gets Ranger school
          baseChar,
        );

        // Check for elite schools
        final deployments = character.enlistment['deployments'] as List? ?? [];
        var hasEliteSchool = false;
        for (var deployment in deployments) {
          if (deployment is Map && deployment['school'] != null) {
            final school = deployment['school'] as String;
            if (school.contains('Knowledge +1')) {
              hasEliteSchool = true;
              eliteSchoolCount++;
              break;
            }
          }
        }

        if (hasEliteSchool) {
          final baseAttributes = character.enlistment['baseAttributes'];
          if (baseAttributes != null && baseAttributes is Map) {
            final baseKnowledge = baseAttributes['Combat Knowledge'] ?? 0;
            final finalKnowledge =
                character.attributes['Combat Knowledge'] ?? 0;

            // SOF gets: Ranger (+1) = at least +1 Knowledge
            if (finalKnowledge >= baseKnowledge + 1) {
              correctBonuses++;
            } else {
              print(
                '  ⚠️ SOF Character $i: Expected Knowledge +1 minimum from elite school',
              );
              print('     Base: $baseKnowledge, Final: $finalKnowledge');
            }
          }
        }
      }

      print('Elite schools found: $eliteSchoolCount');
      print('Correct bonuses applied: $correctBonuses / $eliteSchoolCount');
      expect(
        eliteSchoolCount,
        greaterThan(0),
        reason: 'No elite schools found in SOF characters',
      );
      expect(
        correctBonuses,
        eliteSchoolCount,
        reason: 'Elite school Knowledge bonuses not applying correctly',
      );
      print('✅ Elite school Knowledge bonuses verified\n');
    });

    test(
      'Officer Promotion Bonuses - Strength +1, Agility +1, Knowledge +1',
      () async {
        const testCount = 200;
        final uuid = const Uuid();
        var officerCount = 0;
        var correctBonuses = 0;

        print('\n=== OFFICER PROMOTION BONUS VALIDATION ===');

        for (int i = 0; i < testCount; i++) {
          final characterId = uuid.v4();
          final baseChar = _createBaseCharacter(characterId, 'UK', 'Test $i');
          final character = await QuickBuildService.generateQuickCharacter(
            characterId,
            'Rifleman',
            baseChar,
          );

          // Check if promoted to officer (career roll 1)
          final rank = character.enlistment['rank']?.toString() ?? '';
          if (rank.contains('Lieutenant') ||
              rank.contains('Captain') ||
              rank.contains('O-')) {
            officerCount++;

            final baseAttributes = character.enlistment['baseAttributes'];
            if (baseAttributes != null && baseAttributes is Map) {
              final baseStrength = baseAttributes['Strength'] ?? 0;
              final baseAgility = baseAttributes['Agility'] ?? 0;
              final baseKnowledge = baseAttributes['Combat Knowledge'] ?? 0;

              final finalStrength = character.attributes['Strength'] ?? 0;
              final finalAgility = character.attributes['Agility'] ?? 0;
              final finalKnowledge =
                  character.attributes['Combat Knowledge'] ?? 0;

              // Officer promotion gives: Strength +1, Agility +1, Knowledge +1
              // Note: May have additional bonuses from schools
              final strengthBonus = finalStrength - baseStrength;
              final agilityBonus = finalAgility - baseAgility;
              final knowledgeBonus = finalKnowledge - baseKnowledge;

              if (strengthBonus >= 1 &&
                  agilityBonus >= 1 &&
                  knowledgeBonus >= 1) {
                correctBonuses++;
              } else {
                print('  ⚠️ Officer $i: Expected +1 to Str/Agi/Know minimum');
                print(
                  '     Bonuses: Str +$strengthBonus, Agi +$agilityBonus, Know +$knowledgeBonus',
                );
              }
            }
          }
        }

        print('Officers found: $officerCount / $testCount');
        print('Correct officer bonuses: $correctBonuses / $officerCount');
        if (officerCount > 0) {
          expect(
            correctBonuses,
            equals(officerCount),
            reason: 'Officer promotion bonuses not consistent',
          );
        }
        print('✅ Officer promotion bonuses verified\n');
      },
    );

    test('Deployment Awards - Knowledge Bonuses (+1, +2, +3)', () async {
      const testCount = 500;
      final uuid = const Uuid();
      var awardBonusCount = 0;
      var correctBonuses = 0;

      print('\n=== DEPLOYMENT AWARD KNOWLEDGE BONUS VALIDATION ===');

      for (int i = 0; i < testCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(characterId, 'France', 'Test $i');
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        // Count award knowledge bonuses
        final deployments = character.enlistment['deployments'] as List? ?? [];
        var expectedAwardBonus = 0;
        for (var deployment in deployments) {
          if (deployment is Map && deployment['award'] != null) {
            final award = deployment['award'] as String;
            if (award.contains('+1 Knowledge')) {
              expectedAwardBonus += 1;
            } else if (award.contains('+2 Knowledge')) {
              expectedAwardBonus += 2;
            } else if (award.contains('+3 Knowledge')) {
              expectedAwardBonus += 3;
            }
          }
        }

        if (expectedAwardBonus > 0) {
          awardBonusCount++;

          final baseAttributes = character.enlistment['baseAttributes'];
          if (baseAttributes != null && baseAttributes is Map) {
            final baseKnowledge = baseAttributes['Combat Knowledge'] ?? 0;
            final finalKnowledge =
                character.attributes['Combat Knowledge'] ?? 0;
            final actualBonus = finalKnowledge - baseKnowledge;

            // Award bonus should be included (may have additional bonuses)
            if (actualBonus >= expectedAwardBonus) {
              correctBonuses++;
            } else {
              print(
                '  ⚠️ Character $i: Expected +$expectedAwardBonus Knowledge from awards',
              );
              print(
                '     Base: $baseKnowledge, Final: $finalKnowledge, Actual bonus: $actualBonus',
              );
            }
          }
        }
      }

      print('Characters with award bonuses: $awardBonusCount / $testCount');
      print('Correct award bonuses: $correctBonuses / $awardBonusCount');
      expect(awardBonusCount, greaterThan(0), reason: 'No award bonuses found');
      expect(
        correctBonuses,
        equals(awardBonusCount),
        reason: 'Award Knowledge bonuses not applying correctly',
      );
      print('✅ Award Knowledge bonuses verified\n');
    });
  });

  group('Character Stats Validation - Skills (Prowess, Tactics, Instincts)', () {
    test('Prowess Skills - Small Arms Progression', () async {
      final specialties = ['Rifleman', 'Sniper', 'SOF', 'Agent'];
      print('\n=== SMALL ARMS SKILL PROGRESSION ===');

      for (final specialty in specialties) {
        final characterId = const Uuid().v4();
        final baseChar = _createBaseCharacter(
          characterId,
          'US',
          'Test $specialty',
        );
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          specialty,
          baseChar,
        );

        final smallArms = character.skills['Small Arms'] ?? 0;
        final specialtyDetail =
            character.enlistment['specialty']?.toString() ?? '';

        // Expected minimums:
        // Rifleman: 3, Sniper: 4
        // SOF/Agent: Varies by initial specialty (Rifleman/Sniper: 4-5, Medical/Radio: 1-2)
        if (specialty == 'Rifleman') {
          expect(
            smallArms,
            greaterThanOrEqualTo(3),
            reason: 'Rifleman should start with Small Arms 3',
          );
          print('  $specialty: Small Arms = $smallArms (expected ≥3) ✓');
        } else if (specialty == 'Sniper') {
          expect(
            smallArms,
            greaterThanOrEqualTo(4),
            reason: 'Sniper should start with Small Arms 4',
          );
          print('  $specialty: Small Arms = $smallArms (expected ≥4) ✓');
        } else if (specialty == 'SOF' || specialty == 'Agent') {
          // SOF/Agent Small Arms depends on initial specialty:
          // - Rifleman/Sniper initial: Small Arms 4-6
          // - Medical/Radio initial: Small Arms 1-2 (they specialize in other skills)
          expect(
            smallArms,
            greaterThanOrEqualTo(1),
            reason: '$specialty should have Small Arms skill',
          );
          if (specialtyDetail.contains('Rifleman') ||
              specialtyDetail.contains('Sniper')) {
            expect(
              smallArms,
              greaterThanOrEqualTo(4),
              reason:
                  '$specialty with Rifleman/Sniper should have Small Arms ≥4',
            );
            print(
              '  $specialty ($specialtyDetail): Small Arms = $smallArms (expected ≥4 for combat specialty) ✓',
            );
          } else {
            // Medical or Radio Operator - Small Arms is secondary skill
            print(
              '  $specialty ($specialtyDetail): Small Arms = $smallArms (support specialty, Small Arms not primary) ✓',
            );
          }
        }
      }
      print('✅ Small Arms progression validated\n');
    });

    test(
      'Tactics Skills - Explosives Progression (EOD, Breacher Schools)',
      () async {
        print('\n=== EXPLOSIVES SKILL PROGRESSION ===');

        // Test EOD specialty
        final eodId = const Uuid().v4();
        final eodChar = _createBaseCharacter(eodId, 'US', 'EOD Test');
        final eod = await QuickBuildService.generateQuickCharacter(
          eodId,
          'EOD',
          eodChar,
        );
        final eodExplosives = eod.skills['Explosives'] ?? 0;

        // EOD gets +3 Explosives
        expect(
          eodExplosives,
          greaterThanOrEqualTo(3),
          reason: 'EOD should have Explosives +3',
        );
        print('  EOD: Explosives = $eodExplosives (expected ≥3) ✓');

        // Test Breacher school bonus (if applicable, +2 additional)
        final deployments = eod.enlistment['deployments'] as List? ?? [];
        var hasBreacher = false;
        for (var deployment in deployments) {
          if (deployment is Map && deployment['school'] != null) {
            final school = deployment['school'] as String;
            if (school.contains('Breacher') ||
                school.contains('Explosives +2')) {
              hasBreacher = true;
              break;
            }
          }
        }

        if (hasBreacher) {
          expect(
            eodExplosives,
            greaterThanOrEqualTo(5),
            reason: 'EOD with Breacher school should have Explosives ≥5',
          );
          print(
            '  EOD with Breacher: Explosives = $eodExplosives (expected ≥5) ✓',
          );
        }

        print('✅ Explosives progression validated\n');
      },
    );

    test('Tactics Skills - Spying Progression (Agent)', () async {
      print('\n=== SPYING SKILL PROGRESSION ===');

      final agentId = const Uuid().v4();
      final agentChar = _createBaseCharacter(agentId, 'US', 'Agent Test');
      final agent = await QuickBuildService.generateQuickCharacter(
        agentId,
        'Agent',
        agentChar,
      );
      final spying = agent.skills['Spying'] ?? 0;

      // Agent gets +3 Spying
      expect(
        spying,
        greaterThanOrEqualTo(3),
        reason: 'Agent should have Spying +3',
      );
      print('  Agent: Spying = $spying (expected ≥3) ✓');
      print('✅ Spying progression validated\n');
    });

    test('Instincts Skills - Fires Progression (JTAC)', () async {
      print('\n=== FIRES SKILL PROGRESSION ===');

      final jtacId = const Uuid().v4();
      final jtacChar = _createBaseCharacter(jtacId, 'US', 'JTAC Test');
      final jtac = await QuickBuildService.generateQuickCharacter(
        jtacId,
        'JTAC',
        jtacChar,
      );
      final fires = jtac.skills['Fires'] ?? 0;
      final radioOps = jtac.skills['Radio Ops'] ?? 0;

      // JTAC gets +3 Fires, +1 Radio Ops
      expect(
        fires,
        greaterThanOrEqualTo(3),
        reason: 'JTAC should have Fires +3',
      );
      expect(
        radioOps,
        greaterThanOrEqualTo(1),
        reason: 'JTAC should have Radio Ops +1',
      );
      print(
        '  JTAC: Fires = $fires (expected ≥3), Radio Ops = $radioOps (expected ≥1) ✓',
      );
      print('✅ Fires progression validated\n');
    });

    test('Combat Experience - Per Deployment Progression', () async {
      const testCount = 100;
      final uuid = const Uuid();
      var incorrectCombat = 0;

      print('\n=== COMBAT EXPERIENCE PROGRESSION ===');

      for (int i = 0; i < testCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(characterId, 'Japan', 'Test $i');
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        final deploymentCount =
            (character.enlistment['deployments'] as List?)?.length ?? 0;
        final combat = character.skills['Combat'] ?? 0;

        // Each deployment should add +1 Combat
        if (combat != deploymentCount) {
          incorrectCombat++;
          print(
            '  ⚠️ Character $i: $deploymentCount deployments, Combat = $combat (expected $deploymentCount)',
          );
        }
      }

      print('Incorrect Combat values: $incorrectCombat / $testCount');
      expect(
        incorrectCombat,
        0,
        reason: 'Combat experience not matching deployment count',
      );
      print('✅ Combat experience progression validated\n');
    });

    test('Training Skill - Promotion Bonuses', () async {
      const testCount = 200;
      final uuid = const Uuid();
      var promotionCount = 0;
      var correctTraining = 0;

      print('\n=== TRAINING SKILL PROGRESSION ===');

      for (int i = 0; i < testCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(characterId, 'Canada', 'Test $i');
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        final training = character.skills['Training'] ?? 0;
        final rank = character.enlistment['rank']?.toString() ?? '';

        // Check for promotions (Sergeant E-5 or Officer)
        final hasSergeant =
            rank.contains('Sergeant') ||
            rank.contains('E-5') ||
            rank.contains('E-6');
        final hasOfficer =
            rank.contains('Lieutenant') ||
            rank.contains('Captain') ||
            rank.contains('O-');

        if (hasSergeant || hasOfficer) {
          promotionCount++;

          // Promotions should add Training +1
          if (training >= 1) {
            correctTraining++;
          } else {
            print(
              '  ⚠️ Character $i ($rank): Training = $training (expected ≥1)',
            );
          }
        }
      }

      print('Promoted characters: $promotionCount / $testCount');
      print('Correct Training bonuses: $correctTraining / $promotionCount');
      if (promotionCount > 0) {
        expect(
          correctTraining,
          equals(promotionCount),
          reason: 'Training bonuses not applying to promotions',
        );
      }
      print('✅ Training progression validated\n');
    });

    test('SOF Highest Skill Bonus - +1 To Best Skill', () async {
      const testCount = 50;
      final uuid = const Uuid();
      var correctBonuses = 0;

      print('\n=== SOF HIGHEST SKILL BONUS VALIDATION ===');

      for (int i = 0; i < testCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(characterId, 'US', 'SOF Test $i');
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'SOF',
          baseChar,
        );

        // SOF gets +1 to highest skill
        // Find highest skill value
        var highestValue = 0;
        character.skills.forEach((key, value) {
          if (key != 'Combat' && key != 'Training' && value > highestValue) {
            highestValue = value;
          }
        });

        // For SOF, expect at least one skill to be boosted
        // (difficult to verify exact bonus without base skills, but check magnitude)
        if (highestValue >= 4) {
          // SOF initial specialty gives 3-4, +1 bonus = 4-5 minimum
          correctBonuses++;
        } else {
          print(
            '  ⚠️ SOF $i: Highest skill = $highestValue (expected ≥4 for boosted skill)',
          );
        }
      }

      print(
        'SOF characters with high skill values: $correctBonuses / $testCount',
      );
      expect(
        correctBonuses,
        greaterThan(testCount * 0.8),
        reason: 'SOF highest skill bonus may not be applying',
      );
      print('✅ SOF highest skill bonus validated\n');
    });

    test('Ability Calculations - Knowledge→Tactics, Wisdom→Instincts', () async {
      const testCount = 100;
      final uuid = const Uuid();
      var tacticsErrors = 0;
      var instinctsErrors = 0;

      print('\n=== ABILITY CALCULATION VERIFICATION ===');
      print('  Testing: Combat Knowledge → Tactics ability');
      print('  Testing: Combat Wisdom → Instincts ability\n');

      for (int i = 0; i < testCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(characterId, 'US', 'Test $i');
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        // Get abilities from character
        final abilities =
            character.enlistment['abilities'] as Map<String, dynamic>? ?? {};
        final tacticsAbility = abilities['Tactics'] as int? ?? 0;
        final instinctsAbility = abilities['Instincts'] as int? ?? 0;

        // Get source attributes and skills
        final knowledge = character.attributes['Combat Knowledge'] ?? 0;
        final wisdom = character.attributes['Combat Wisdom'] ?? 0;
        final combat = character.skills['Combat'] ?? 0;
        final training = character.skills['Training'] ?? 0;

        // Calculate expected values based on formula:
        // Tactics = Knowledge + Combat + Training (+ Rifleman bonus if applicable)
        final specialty = character.enlistment['specialty']?.toString() ?? '';
        final riflemanBonus = specialty.contains('Rifleman') ? 1 : 0;
        final expectedTactics = knowledge + combat + training + riflemanBonus;

        // Instincts = Wisdom + Training + Combat
        final expectedInstincts = wisdom + training + combat;

        // Verify Tactics calculation
        if (tacticsAbility != expectedTactics) {
          tacticsErrors++;
          if (i < 5) {
            // Only print first 5 errors to avoid spam
            print('  ⚠️ Tactics mismatch on Character $i:');
            print(
              '     Expected: $expectedTactics (Knowledge:$knowledge + Combat:$combat + Training:$training + Rifleman:$riflemanBonus)',
            );
            print('     Actual: $tacticsAbility');
          }
        }

        // Verify Instincts calculation
        if (instinctsAbility != expectedInstincts) {
          instinctsErrors++;
          if (i < 5) {
            // Only print first 5 errors to avoid spam
            print('  ⚠️ Instincts mismatch on Character $i:');
            print(
              '     Expected: $expectedInstincts (Wisdom:$wisdom + Training:$training + Combat:$combat)',
            );
            print('     Actual: $instinctsAbility');
          }
        }
      }

      print('Tactics calculation errors: $tacticsErrors / $testCount');
      print('Instincts calculation errors: $instinctsErrors / $testCount');

      expect(
        tacticsErrors,
        0,
        reason: 'Tactics ability not correctly calculated from Knowledge',
      );
      expect(
        instinctsErrors,
        0,
        reason: 'Instincts ability not correctly calculated from Wisdom',
      );

      print('✅ Knowledge → Tactics relationship verified');
      print('✅ Wisdom → Instincts relationship verified\n');
    });
  });

  group('Character Stats Validation - Edge Cases & Stacking', () {
    test('No Stat Stacking - Multiple Characters Same Seed', () async {
      print('\n=== STAT STACKING PREVENTION ===');

      final characterId = const Uuid().v4();
      final baseChar = _createBaseCharacter(characterId, 'US', 'Stacking Test');

      // Generate same character multiple times (simulating re-generation)
      final character1 = await QuickBuildService.generateQuickCharacter(
        '${characterId}_1',
        'Rifleman',
        baseChar,
      );

      final character2 = await QuickBuildService.generateQuickCharacter(
        '${characterId}_2',
        'Rifleman',
        baseChar,
      );

      // Both should have similar stat distributions (within random variance)
      final avgStrength =
          (character1.attributes['Strength']! +
              character2.attributes['Strength']!) /
          2;
      final avgSmallArms =
          (character1.skills['Small Arms']! +
              character2.skills['Small Arms']!) /
          2;

      print(
        '  Character 1: Strength=${character1.attributes['Strength']}, Small Arms=${character1.skills['Small Arms']}',
      );
      print(
        '  Character 2: Strength=${character2.attributes['Strength']}, Small Arms=${character2.skills['Small Arms']}',
      );
      print(
        '  Averages: Strength=${avgStrength.toStringAsFixed(1)}, Small Arms=${avgSmallArms.toStringAsFixed(1)}',
      );

      // Values should be within reasonable range (not doubling)
      expect(
        character1.attributes['Strength'],
        lessThan(20),
        reason: 'Strength stacking detected',
      );
      expect(
        character2.attributes['Strength'],
        lessThan(20),
        reason: 'Strength stacking detected',
      );
      expect(
        character1.skills['Small Arms'],
        lessThan(15),
        reason: 'Small Arms stacking detected',
      );
      expect(
        character2.skills['Small Arms'],
        lessThan(15),
        reason: 'Small Arms stacking detected',
      );

      print('✅ No stat stacking detected\n');
    });

    test('Base vs Final Stats - Deployment Bonuses Only', () async {
      const testCount = 100;
      final uuid = const Uuid();
      var baseCheckErrors = 0;

      print('\n=== BASE VS FINAL STATS VALIDATION ===');

      for (int i = 0; i < testCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(
          characterId,
          'Germany',
          'Test $i',
        );
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        final baseAttributes = character.enlistment['baseAttributes'];
        final baseSkills = character.enlistment['baseSkills'];

        if (baseAttributes != null && baseSkills != null) {
          // Base attributes should be within initial roll range (3-10 before bonuses)
          final baseStrength = (baseAttributes as Map)['Strength'] ?? 0;
          if (baseStrength < 3 || baseStrength > 15) {
            baseCheckErrors++;
            print(
              '  ⚠️ Character $i: Base Strength out of range: $baseStrength',
            );
          }

          // Final attributes should be >= base (never decrease)
          final finalStrength = character.attributes['Strength'] ?? 0;
          if (finalStrength < baseStrength) {
            baseCheckErrors++;
            print(
              '  ⚠️ Character $i: Final Strength ($finalStrength) < Base Strength ($baseStrength)',
            );
          }

          // Final skills should be >= base (never decrease)
          (baseSkills as Map).forEach((key, value) {
            final finalValue = character.skills[key] ?? 0;
            if (finalValue < value) {
              baseCheckErrors++;
              print(
                '  ⚠️ Character $i: Final $key ($finalValue) < Base $key ($value)',
              );
            }
          });
        }
      }

      print('Base/Final stat errors: $baseCheckErrors / $testCount');
      expect(
        baseCheckErrors,
        0,
        reason: 'Base vs Final stat validation failed',
      );
      print('✅ Base vs Final stats validated\n');
    });

    test('All Specialties - Stat Consistency Check', () async {
      final specialties = [
        'Rifleman',
        'Heavy Weapons',
        'Sniper',
        'Medical',
        'EOD',
        'JTAC',
        'SOF',
        'Agent',
      ];
      print('\n=== ALL SPECIALTIES STAT CONSISTENCY ===');

      for (final specialty in specialties) {
        final characterId = const Uuid().v4();
        final baseChar = _createBaseCharacter(
          characterId,
          'US',
          '$specialty Test',
        );
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          specialty,
          baseChar,
        );

        // Verify all core attributes exist
        expect(
          character.attributes['Strength'],
          greaterThan(0),
          reason: '$specialty missing Strength',
        );
        expect(
          character.attributes['Agility'],
          greaterThan(0),
          reason: '$specialty missing Agility',
        );
        expect(
          character.attributes['Combat Wisdom'],
          greaterThan(0),
          reason: '$specialty missing Combat Wisdom',
        );
        expect(
          character.attributes['Combat Knowledge'],
          greaterThan(0),
          reason: '$specialty missing Combat Knowledge',
        );

        // Verify core skills exist
        expect(
          character.skills.containsKey('Small Arms'),
          true,
          reason: '$specialty missing Small Arms skill',
        );
        expect(
          character.skills.containsKey('Combat'),
          true,
          reason: '$specialty missing Combat skill',
        );

        // Verify specialty-specific skills
        if (specialty == 'EOD') {
          expect(
            character.skills['Explosives'],
            greaterThanOrEqualTo(3),
            reason: 'EOD missing Explosives bonus',
          );
        } else if (specialty == 'JTAC') {
          expect(
            character.skills['Fires'],
            greaterThanOrEqualTo(3),
            reason: 'JTAC missing Fires bonus',
          );
        } else if (specialty == 'Agent') {
          expect(
            character.skills['Spying'],
            greaterThanOrEqualTo(3),
            reason: 'Agent missing Spying bonus',
          );
        } else if (specialty == 'SOF') {
          expect(
            character.skills['Training'],
            greaterThanOrEqualTo(1),
            reason: 'SOF missing Training bonus',
          );
        }

        print('  $specialty: ✓ All stats present and valid');
      }

      print('✅ All specialties validated\n');
    });

    test('Extreme Case - Multiple High Bonuses (SOF Agent)', () async {
      print('\n=== EXTREME CASE - AGENT (SOF + AGENT TRAINING) ===');

      final agentId = const Uuid().v4();
      final agentChar = _createBaseCharacter(agentId, 'US', 'Agent Test');
      final agent = await QuickBuildService.generateQuickCharacter(
        agentId,
        'Agent',
        agentChar,
      );

      // Agent = SOF + Agent training
      // Expected bonuses:
      // - Ranger school: Strength +1, Knowledge +1, Training +1, highest skill +1
      // - SOF school: Strength +1 (if physical school)
      // - Agent training: Spying +3, Training +1
      // - Multiple deployments: Combat +3-5, Strength +3-5 (schools), possible Knowledge bonuses (awards)

      final strength = agent.attributes['Strength'] ?? 0;
      final knowledge = agent.attributes['Combat Knowledge'] ?? 0;
      final spying = agent.skills['Spying'] ?? 0;
      final training = agent.skills['Training'] ?? 0;
      final combat = agent.skills['Combat'] ?? 0;

      print('  Agent Stats:');
      print('    Strength: $strength (expected ~8-16 with all bonuses)');
      print('    Knowledge: $knowledge (expected ~6-14 with awards)');
      print('    Spying: $spying (expected ≥3 from Agent training)');
      print('    Training: $training (expected ≥2 from SOF + Agent)');
      print('    Combat: $combat (expected 4-6 deployments)');

      expect(
        strength,
        inInclusiveRange(6, 20),
        reason: 'Agent Strength out of expected range',
      );
      expect(
        knowledge,
        inInclusiveRange(4, 18),
        reason: 'Agent Knowledge out of expected range',
      );
      expect(
        spying,
        greaterThanOrEqualTo(3),
        reason: 'Agent should have Spying ≥3',
      );
      expect(
        training,
        greaterThanOrEqualTo(2),
        reason: 'Agent should have Training ≥2',
      );
      expect(
        combat,
        inInclusiveRange(4, 7),
        reason: 'Agent should have 4-6 deployments (Combat)',
      );

      print('✅ Extreme case (Agent) validated\n');
    });

    test('Rapid Generation - 500 Characters With Stat Verification', () async {
      const testCount = 500;
      final uuid = const Uuid();
      final stopwatch = Stopwatch()..start();
      var statErrors = 0;

      print('\n=== RAPID GENERATION STAT VERIFICATION ===');

      for (int i = 0; i < testCount; i++) {
        final characterId = uuid.v4();
        final baseChar = _createBaseCharacter(characterId, 'UK', 'Rapid $i');
        final character = await QuickBuildService.generateQuickCharacter(
          characterId,
          'Rifleman',
          baseChar,
        );

        // Quick sanity checks
        if (character.attributes['Strength']! < 3 ||
            character.attributes['Strength']! > 20) {
          statErrors++;
        }
        if (character.skills['Small Arms']! < 3 ||
            character.skills['Small Arms']! > 15) {
          statErrors++;
        }
        if (character.skills['Combat']! < 0 ||
            character.skills['Combat']! > 10) {
          statErrors++;
        }
      }

      stopwatch.stop();
      final avgTime = stopwatch.elapsedMilliseconds / testCount;

      print(
        'Generated $testCount characters in ${stopwatch.elapsedMilliseconds}ms',
      );
      print('Average: ${avgTime.toStringAsFixed(2)}ms per character');
      print('Stat errors: $statErrors / $testCount');

      expect(statErrors, 0, reason: 'Stat errors detected in rapid generation');
      print('✅ Rapid generation validated\n');
    });
  });
}

// Helper function to create base character
Character _createBaseCharacter(
  String id,
  String nationality,
  String name, {
  int age = 21,
}) {
  return Character(
    id: id,
    name: name,
    nationality: nationality,
    age: age,
    userId: 'test-user',
    modifiedAt: DateTime.now(),
  );
}
