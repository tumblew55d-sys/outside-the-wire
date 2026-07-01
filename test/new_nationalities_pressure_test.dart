import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_4patrol/data/nationality_data.dart';
import 'package:flutter_application_4patrol/models/character.dart';

void main() {
  group('New Nationalities Pressure Test - Brazil, New Zealand, Panama', () {
    // Test 1: Verify nationalities list includes new nations
    test('1. Nationalities list includes Brazil, New Zealand, and Panama', () {
      final nationalities = NationalityData.nationalities;

      expect(
        nationalities.contains('Brazil'),
        true,
        reason: 'Brazil should be in nationalities list',
      );
      expect(
        nationalities.contains('New Zealand'),
        true,
        reason: 'New Zealand should be in nationalities list',
      );
      expect(
        nationalities.contains('Panama'),
        true,
        reason: 'Panama should be in nationalities list',
      );

      print('✓ All three new nationalities found in list');
      print('  Total nationalities: ${nationalities.length}');
    });

    // Test 2: Brazil enlisted ranks
    test('2. Brazil has complete enlisted ranks structure', () {
      final ranks = NationalityData.getEnlistedRanks('Brazil');

      expect(ranks['ranks'], isNotNull);
      expect(ranks['ranks']!.length, greaterThan(4));
      expect(ranks['ranks']!.contains('Soldado'), true);
      expect(ranks['ranks']!.contains('Cabo'), true);
      expect(ranks['ranks']!.contains('Terceiro-Sargento'), true);
      expect(ranks['ranks']!.contains('Subtenente'), true);

      print('✓ Brazil enlisted ranks verified');
      print('  Ranks: ${ranks['ranks']!.join(', ')}');
    });

    // Test 3: Brazil officer ranks
    test('3. Brazil has complete officer ranks structure', () {
      final ranks = NationalityData.getOfficerRanks('Brazil');

      expect(ranks['ranks'], isNotNull);
      expect(ranks['ranks']!.length, greaterThan(4));
      expect(ranks['ranks']!.contains('Aspirante-a-Oficial'), true);
      expect(ranks['ranks']!.contains('Segundo-Tenente'), true);
      expect(ranks['ranks']!.contains('Capitão'), true);
      expect(ranks['ranks']!.contains('Coronel'), true);

      print('✓ Brazil officer ranks verified');
      print('  Ranks: ${ranks['ranks']!.join(', ')}');
    });

    // Test 4: Brazil Navy ranks
    test('4. Brazil has Navy ranks (Marines)', () {
      final enlisted = NationalityData.getNavyEnlistedRanks('Brazil');
      final officer = NationalityData.getNavyOfficerRanks('Brazil');

      expect(enlisted['ranks'], isNotNull);
      expect(enlisted['ranks']!.contains('Marinheiro-Recruta'), true);
      expect(enlisted['ranks']!.contains('Grumete'), true);
      expect(enlisted['ranks']!.contains('Suboficial'), true);

      expect(officer['ranks'], isNotNull);
      expect(officer['ranks']!.contains('Guarda-Marinha'), true);
      expect(officer['ranks']!.contains('Capitão de Mar e Guerra'), true);

      print('✓ Brazil Navy ranks verified');
      print('  Navy enlisted: ${enlisted['ranks']!.length} ranks');
      print('  Navy officer: ${officer['ranks']!.length} ranks');
    });

    // Test 5: Brazil weapons locker
    test('5. Brazil has era-appropriate weapons (2010-2016)', () {
      final weapons = NationalityData.getWeaponsLocker('Brazil');

      expect(weapons.length, greaterThan(5));
      expect(
        weapons.any((w) => w.contains('IMBEL IA2')),
        true,
        reason: 'Should have IMBEL IA2 rifle',
      );
      expect(
        weapons.any((w) => w.contains('FAL')),
        true,
        reason: 'Should have FN FAL rifle',
      );
      expect(
        weapons.any((w) => w.contains('Taurus')),
        true,
        reason: 'Should have Taurus pistols',
      );
      expect(
        weapons.any((w) => w.contains('SAW') || w.contains('Minimi')),
        true,
        reason: 'Should have SAW/light machine gun',
      );

      print('✓ Brazil weapons locker verified');
      print('  Total weapons: ${weapons.length}');
      for (var w in weapons) {
        print('    - $w');
      }
    });

    // Test 6: Brazil surnames with indigenous names
    test('6. Brazil has surnames including indigenous variations', () {
      final surnames = NationalityData.getNames('Brazil');

      expect(surnames.length, greaterThan(20));
      expect(
        surnames.any((s) => s.contains('Silva') || s.contains('Santos')),
        true,
        reason: 'Should have Portuguese surnames',
      );
      expect(
        surnames.any((s) => s == 'Tupã' || s == 'Guarani' || s == 'Tupi'),
        true,
        reason: 'Should have indigenous surnames',
      );

      print('✓ Brazil surnames verified');
      print('  Total surnames: ${surnames.length}');
      print('  Sample Portuguese: Silva, Santos, Oliveira');
      print('  Sample Indigenous: Tupã, Guarani, Tupi, Iracema');
    });

    // Test 7: New Zealand ranks
    test('7. New Zealand has NZDF rank structure', () {
      final enlisted = NationalityData.getEnlistedRanks('New Zealand');
      final officer = NationalityData.getOfficerRanks('New Zealand');

      expect(enlisted['ranks']!.contains('Private'), true);
      expect(enlisted['ranks']!.contains('Lance Corporal'), true);
      expect(enlisted['ranks']!.contains('Warrant Officer Class 1'), true);

      expect(officer['ranks']!.contains('Second Lieutenant'), true);
      expect(officer['ranks']!.contains('Captain'), true);
      expect(officer['ranks']!.contains('Colonel'), true);

      print('✓ New Zealand NZDF ranks verified');
      print('  Enlisted: ${enlisted['ranks']!.join(', ')}');
      print('  Officer: ${officer['ranks']!.join(', ')}');
    });

    // Test 8: New Zealand weapons
    test('8. New Zealand has Steyr AUG and appropriate weapons', () {
      final weapons = NationalityData.getWeaponsLocker('New Zealand');

      expect(
        weapons.any((w) => w.contains('Steyr AUG')),
        true,
        reason: 'Should have Steyr AUG rifle',
      );
      expect(
        weapons.any((w) => w.contains('IW Steyr')),
        true,
        reason: 'Should have IW Steyr',
      );
      expect(
        weapons.any((w) => w.contains('Browning HP')),
        true,
        reason: 'Should have Browning Hi-Power pistol',
      );
      expect(
        weapons.any((w) => w.contains('Glock')),
        true,
        reason: 'Should have Glock pistol',
      );

      print('✓ New Zealand weapons verified');
      for (var w in weapons) {
        print('    - $w');
      }
    });

    // Test 9: New Zealand surnames with Māori names
    test('9. New Zealand has surnames including Māori variations', () {
      final surnames = NationalityData.getNames('New Zealand');

      expect(surnames.length, greaterThan(20));
      expect(
        surnames.any((s) => s == 'Smith' || s == 'Jones'),
        true,
        reason: 'Should have English surnames',
      );
      expect(
        surnames.any((s) => s.contains('Te ') || s == 'Parata' || s == 'Ngata'),
        true,
        reason: 'Should have Māori surnames',
      );

      print('✓ New Zealand surnames verified');
      print('  Total surnames: ${surnames.length}');
      print('  Sample English: Smith, Jones, Williams');
      print('  Sample Māori: Te Kanawa, Parata, Ngata, Wiremu');
    });

    // Test 10: New Zealand NZSAS schools
    test('10. New Zealand has NZSAS-specific schools', () {
      final schools = NationalityData.getSchools('New Zealand');
      final sofSchools = NationalityData.getSOFSchools('New Zealand');

      expect(
        schools.any((s) => s.contains('NZSAS')),
        true,
        reason: 'Regular schools should include NZSAS Selection',
      );
      expect(
        sofSchools.any((s) => s.contains('NZSAS') || s.contains('Māori')),
        true,
        reason: 'SOF schools should include NZSAS training',
      );

      print('✓ New Zealand schools verified');
      print('  Schools: ${schools.join(', ')}');
      print('  SOF Schools include NZSAS training');
    });

    // Test 11: Panama Public Forces ranks (not military)
    test('11. Panama has Public Forces rank structure', () {
      final enlisted = NationalityData.getEnlistedRanks('Panama');
      final officer = NationalityData.getOfficerRanks('Panama');

      expect(
        enlisted['ranks']!.contains('Agente'),
        true,
        reason: 'Should have Agente rank',
      );
      expect(enlisted['ranks']!.contains('Cabo'), true);
      expect(enlisted['ranks']!.contains('Suboficial Mayor'), true);

      expect(officer['ranks']!.contains('Subteniente'), true);
      expect(officer['ranks']!.contains('Capitán'), true);
      expect(
        officer['ranks']!.contains('Comisionado'),
        true,
        reason: 'Should have Comisionado (highest rank in Public Forces)',
      );

      print('✓ Panama Public Forces ranks verified');
      print('  Enlisted: ${enlisted['ranks']!.join(', ')}');
      print('  Officer: ${officer['ranks']!.join(', ')}');
    });

    // Test 12: Panama weapons (M16/M4/Galil)
    test('12. Panama has appropriate weapons for Public Forces', () {
      final weapons = NationalityData.getWeaponsLocker('Panama');

      expect(
        weapons.any((w) => w.contains('M16A2')),
        true,
        reason: 'Should have M16A2',
      );
      expect(
        weapons.any((w) => w.contains('M4')),
        true,
        reason: 'Should have M4 Carbine',
      );
      expect(
        weapons.any((w) => w.contains('Galil')),
        true,
        reason: 'Should have Galil ACE',
      );
      expect(
        weapons.any((w) => w.contains('SAW') || w.contains('M240')),
        true,
        reason: 'Should have machine guns',
      );

      print('✓ Panama weapons verified');
      for (var w in weapons) {
        print('    - $w');
      }
    });

    // Test 13: Panama surnames with indigenous names
    test('13. Panama has Spanish and indigenous surnames', () {
      final surnames = NationalityData.getNames('Panama');

      expect(surnames.length, greaterThan(20));
      expect(
        surnames.any((s) => s.contains('Rodriguez') || s.contains('Gonzalez')),
        true,
        reason: 'Should have Spanish surnames',
      );
      expect(
        surnames.any((s) => s == 'Ngäbe' || s == 'Emberá' || s == 'Kuna'),
        true,
        reason: 'Should have indigenous surnames',
      );

      print('✓ Panama surnames verified');
      print('  Total surnames: ${surnames.length}');
      print('  Sample Spanish: Rodriguez, Martinez, Gonzalez');
      print('  Sample Indigenous: Ngäbe, Emberá, Kuna, Wounaan');
    });

    // Test 14: Panama UN peacekeeping schools
    test('14. Panama has UN peacekeeping training courses', () {
      final schools = NationalityData.getSchools('Panama');
      final sofSchools = NationalityData.getSOFSchools('Panama');

      expect(
        schools.any((s) => s.contains('UN Peacekeeping')),
        true,
        reason: 'Should have UN Peacekeeping course',
      );
      expect(
        schools.any((s) => s.contains('Jungle')),
        true,
        reason: 'Should have Jungle Warfare',
      );

      print('✓ Panama schools verified');
      print('  Schools: ${schools.join(', ')}');
    });

    // Test 15: Awards and medals for all three nations
    test('15. All three nations have deployment awards and medals', () {
      final brazilAwards = NationalityData.getDeploymentAwards('Brazil');
      final nzAwards = NationalityData.getDeploymentAwards('New Zealand');
      final panamaAwards = NationalityData.getDeploymentAwards('Panama');

      expect(brazilAwards['awards'], isNotNull);
      expect(brazilAwards['awards']!.length, greaterThan(3));
      expect(brazilAwards['wound'], 'Ferido em Combate');

      expect(nzAwards['awards'], isNotNull);
      expect(nzAwards['awards']!.length, greaterThan(3));
      expect(nzAwards['wound'], 'Wound Stripe');

      expect(panamaAwards['awards'], isNotNull);
      expect(panamaAwards['awards']!.length, greaterThan(3));
      expect(panamaAwards['wound'], 'Herido en Servicio');

      print('✓ Deployment awards verified for all three nations');
      print('  Brazil awards: ${brazilAwards['awards']!.length}');
      print('  New Zealand awards: ${nzAwards['awards']!.length}');
      print('  Panama awards: ${panamaAwards['awards']!.length}');
    });

    // Test 16: Medals for all three nations
    test('16. All three nations have complete medal lists', () {
      final brazilMedals = NationalityData.getMedals('Brazil');
      final nzMedals = NationalityData.getMedals('New Zealand');
      final panamaMedals = NationalityData.getMedals('Panama');

      expect(brazilMedals.length, greaterThanOrEqualTo(5));
      expect(brazilMedals.any((m) => m.contains('Pacificador')), true);

      expect(nzMedals.length, greaterThanOrEqualTo(5));
      expect(nzMedals.any((m) => m.contains('Victoria Cross')), true);

      expect(panamaMedals.length, greaterThanOrEqualTo(5));
      expect(
        panamaMedals.any((m) => m.contains('Vasco Núñez de Balboa')),
        true,
      );

      print('✓ Medals verified for all three nations');
      print('  Brazil medals: ${brazilMedals.length}');
      print('  New Zealand medals: ${nzMedals.length}');
      print('  Panama medals: ${panamaMedals.length}');
    });

    // Test 17: Initial ranks for character creation
    test('17. Initial ranks available for all three nations', () {
      final brazilEnlisted = NationalityData.getInitialEnlistedRanks('Brazil');
      final brazilOfficer = NationalityData.getInitialOfficerRanks('Brazil');

      final nzEnlisted = NationalityData.getInitialEnlistedRanks('New Zealand');
      final nzOfficer = NationalityData.getInitialOfficerRanks('New Zealand');

      final panamaEnlisted = NationalityData.getInitialEnlistedRanks('Panama');
      final panamaOfficer = NationalityData.getInitialOfficerRanks('Panama');

      // Brazil
      expect(brazilEnlisted['ranks']!.length, greaterThanOrEqualTo(2));
      expect(brazilOfficer['ranks']!.length, greaterThanOrEqualTo(2));

      // New Zealand
      expect(nzEnlisted['ranks']!.length, greaterThanOrEqualTo(2));
      expect(nzOfficer['ranks']!.length, greaterThanOrEqualTo(2));

      // Panama
      expect(panamaEnlisted['ranks']!.length, greaterThanOrEqualTo(2));
      expect(panamaOfficer['ranks']!.length, greaterThanOrEqualTo(2));

      print('✓ Initial ranks verified for character creation');
      print(
        '  Brazil: ${brazilEnlisted['ranks']!.length} enlisted, ${brazilOfficer['ranks']!.length} officer',
      );
      print(
        '  New Zealand: ${nzEnlisted['ranks']!.length} enlisted, ${nzOfficer['ranks']!.length} officer',
      );
      print(
        '  Panama: ${panamaEnlisted['ranks']!.length} enlisted, ${panamaOfficer['ranks']!.length} officer',
      );
    });

    // Test 18: Navy initial ranks
    test('18. Navy initial ranks available for Brazil and New Zealand', () {
      final brazilNavyEnlisted = NationalityData.getInitialNavyEnlistedRanks(
        'Brazil',
      );
      final brazilNavyOfficer = NationalityData.getInitialNavyOfficerRanks(
        'Brazil',
      );

      final nzNavyEnlisted = NationalityData.getInitialNavyEnlistedRanks(
        'New Zealand',
      );
      final nzNavyOfficer = NationalityData.getInitialNavyOfficerRanks(
        'New Zealand',
      );

      final panamaNavyEnlisted = NationalityData.getInitialNavyEnlistedRanks(
        'Panama',
      );
      final panamaNavyOfficer = NationalityData.getInitialNavyOfficerRanks(
        'Panama',
      );

      expect(brazilNavyEnlisted['ranks']!.length, greaterThanOrEqualTo(2));
      expect(brazilNavyOfficer['ranks']!.length, greaterThanOrEqualTo(2));

      expect(nzNavyEnlisted['ranks']!.length, greaterThanOrEqualTo(2));
      expect(nzNavyOfficer['ranks']!.length, greaterThanOrEqualTo(2));

      expect(panamaNavyEnlisted['ranks']!.length, greaterThanOrEqualTo(2));
      expect(panamaNavyOfficer['ranks']!.length, greaterThanOrEqualTo(2));

      print('✓ Navy initial ranks verified');
      print('  Brazil Navy: ${brazilNavyEnlisted['ranks']!.join(', ')}');
      print('  NZ Navy: ${nzNavyEnlisted['ranks']!.join(', ')}');
      print('  Panama Navy: ${panamaNavyEnlisted['ranks']!.join(', ')}');
    });

    // Test 19: Weapon filtering functions
    test('19. Weapon filtering works for new nationalities', () {
      // Test rifles
      final brazilRifles = NationalityData.getRifles('Brazil');
      expect(
        brazilRifles.any((r) => r.contains('IA2') || r.contains('FAL')),
        true,
      );

      final nzRifles = NationalityData.getRifles('New Zealand');
      expect(nzRifles.any((r) => r.contains('Steyr')), true);

      final panamaRifles = NationalityData.getRifles('Panama');
      expect(
        panamaRifles.any(
          (r) => r.contains('M16') || r.contains('M4') || r.contains('Galil'),
        ),
        true,
      );

      // Test pistols
      final brazilPistols = NationalityData.getPistols('Brazil');
      expect(brazilPistols.any((p) => p.contains('Taurus')), true);

      final nzPistols = NationalityData.getPistols('New Zealand');
      expect(
        nzPistols.any((p) => p.contains('Browning') || p.contains('Glock')),
        true,
      );

      final panamaPistols = NationalityData.getPistols('Panama');
      expect(
        panamaPistols.any((p) => p.contains('Beretta') || p.contains('Glock')),
        true,
      );

      print('✓ Weapon filtering verified for all nationalities');
      print(
        '  Brazil rifles: ${brazilRifles.length}, pistols: ${brazilPistols.length}',
      );
      print('  NZ rifles: ${nzRifles.length}, pistols: ${nzPistols.length}');
      print(
        '  Panama rifles: ${panamaRifles.length}, pistols: ${panamaPistols.length}',
      );
    });

    // Test 20: End-to-end character creation simulation
    test('20. Character creation works with all three new nationalities', () {
      final nationalities = ['Brazil', 'New Zealand', 'Panama'];

      for (final nationality in nationalities) {
        // Simulate creating an enlisted character
        final enlistedRanks = NationalityData.getInitialEnlistedRanks(
          nationality,
        );
        final weapons = NationalityData.getWeaponsLocker(nationality);
        final surnames = NationalityData.getNames(nationality);
        final schools = NationalityData.getSchools(nationality);
        final awards = NationalityData.getDeploymentAwards(nationality);

        expect(
          enlistedRanks['ranks']!.isNotEmpty,
          true,
          reason: '$nationality should have enlisted ranks',
        );
        expect(
          weapons.isNotEmpty,
          true,
          reason: '$nationality should have weapons',
        );
        expect(
          surnames.isNotEmpty,
          true,
          reason: '$nationality should have surnames',
        );
        expect(
          schools.isNotEmpty,
          true,
          reason: '$nationality should have schools',
        );
        expect(
          awards['awards']!.isNotEmpty,
          true,
          reason: '$nationality should have awards',
        );

        // Simulate creating an officer character
        final officerRanks = NationalityData.getInitialOfficerRanks(
          nationality,
        );
        expect(
          officerRanks['ranks']!.isNotEmpty,
          true,
          reason: '$nationality should have officer ranks',
        );

        print('✓ $nationality: Character creation validated');
        print('    Enlisted: ${enlistedRanks['ranks']!.first}');
        print('    Officer: ${officerRanks['ranks']!.first}');
        print('    Weapons: ${weapons.length} available');
        print('    Surnames: ${surnames.length} available');
        print('    Schools: ${schools.length} available');
      }
    });

    // Test 21: Verify tooltips exist for new nation content
    test('21. Tooltips available for new nation awards and schools', () {
      // Brazil tooltips
      expect(
        NationalityData.getAwardTooltip('Medalha do Pacificador'),
        isNotNull,
      );
      expect(NationalityData.getAwardTooltip('Ferido em Combate'), isNotNull);
      expect(NationalityData.getSchoolTooltip('GRUMEC Training'), isNotNull);

      // New Zealand tooltips
      expect(
        NationalityData.getAwardTooltip('Victoria Cross for New Zealand'),
        isNotNull,
      );
      expect(NationalityData.getSchoolTooltip('NZSAS Selection'), isNotNull);

      // Panama tooltips
      expect(NationalityData.getAwardTooltip('Medalla al Valor'), isNotNull);
      expect(
        NationalityData.getSchoolTooltip('UN Peacekeeping Course'),
        isNotNull,
      );

      // Weapon tooltips
      expect(
        NationalityData.getWeaponTooltip('IMBEL IA2 Rifle (5.56mm)'),
        isNotNull,
      );
      expect(NationalityData.getWeaponTooltip('Steyr AUG A1 Rifle'), isNotNull);
      expect(NationalityData.getWeaponTooltip('Galil ACE Rifle'), isNotNull);

      print('✓ Tooltips verified for all new nation content');
      print(
        '  Sample Brazil tooltip: ${NationalityData.getAwardTooltip('Medalha do Pacificador')}',
      );
      print(
        '  Sample NZ tooltip: ${NationalityData.getSchoolTooltip('NZSAS Selection')}',
      );
      print(
        '  Sample Panama weapon: ${NationalityData.getWeaponTooltip('Galil ACE Rifle')}',
      );
    });

    // Test 22: Stress test - rapid switching between nationalities
    test('22. Rapid nationality switching works without errors', () {
      final testNationalities = [
        'Brazil',
        'New Zealand',
        'Panama',
        'USA',
        'Brazil',
        'Panama',
        'New Zealand',
      ];

      for (final nationality in testNationalities) {
        final ranks = NationalityData.getEnlistedRanks(nationality);
        final weapons = NationalityData.getWeaponsLocker(nationality);
        final surnames = NationalityData.getNames(nationality);

        expect(ranks['ranks']!.isNotEmpty, true);
        expect(weapons.isNotEmpty, true);
        expect(surnames.isNotEmpty, true);
      }

      print('✓ Rapid nationality switching validated');
      print('  Tested ${testNationalities.length} switches without errors');
    });
  });
}
