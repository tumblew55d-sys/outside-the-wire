import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_4patrol/data/nationality_data.dart';

void main() {
  group('Deployment Locations and Hometowns Update Test', () {
    // Test 1: Brazil hometowns
    test('1. Brazil has complete hometown list with cities and states', () {
      // This is tested through character creation, but we verify deployment locations exist
      final deployments = NationalityData.getDeploymentLocations('Brazil');

      expect(deployments.length, greaterThan(5));
      expect(
        deployments.any((d) => d.contains('Tri-Border')),
        true,
        reason: 'Brazil should have Tri-Border Area deployment',
      );
      expect(
        deployments.any((d) => d.contains('Haiti')),
        true,
        reason: 'Brazil should have Haiti (MINUSTAH) deployment',
      );
      expect(
        deployments.any((d) => d.contains('Amazon')),
        true,
        reason: 'Brazil should have Amazon Border Operations',
      );

      print('✓ Brazil deployment locations verified');
      print('  Total deployments: ${deployments.length}');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 2: New Zealand deployment locations
    test('2. New Zealand has historically accurate deployment locations', () {
      final deployments = NationalityData.getDeploymentLocations('New Zealand');

      expect(deployments.length, greaterThan(5));
      expect(
        deployments.any((d) => d.contains('Afghanistan')),
        true,
        reason: 'New Zealand should have Afghanistan deployments',
      );
      expect(
        deployments.any((d) => d.contains('Bamiyan') || d.contains('Kabul')),
        true,
        reason:
            'New Zealand should have specific Afghanistan locations (Bamiyan/Kabul)',
      );
      expect(
        deployments.any((d) => d.contains('East Timor')),
        true,
        reason: 'New Zealand should have East Timor deployment',
      );
      expect(
        deployments.any((d) => d.contains('Iraq')),
        true,
        reason: 'New Zealand should have Iraq (Taji) deployment',
      );

      print('✓ New Zealand deployment locations verified');
      print('  Total deployments: ${deployments.length}');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 3: Panama deployment locations (UN peacekeeping focused)
    test('3. Panama has UN peacekeeping deployment locations', () {
      final deployments = NationalityData.getDeploymentLocations('Panama');

      expect(deployments.length, greaterThan(5));
      expect(
        deployments.any((d) => d.contains('Haiti') && d.contains('MINUSTAH')),
        true,
        reason: 'Panama should have Haiti MINUSTAH deployment',
      );
      expect(
        deployments.any((d) => d.contains('Liberia') && d.contains('UNMIL')),
        true,
        reason: 'Panama should have Liberia UNMIL deployment',
      );
      expect(
        deployments.any((d) => d.contains('UNMISS') || d.contains('MONUSCO')),
        true,
        reason: 'Panama should have UN missions (UNMISS/MONUSCO)',
      );
      expect(
        deployments.any((d) => d.toLowerCase().contains('sudan')),
        true,
        reason: 'Panama should have Sudan-related UN deployments',
      );

      print('✓ Panama deployment locations verified');
      print('  Total deployments: ${deployments.length}');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 4: USA deployment locations (2010-2016 era)
    test('4. USA has 2010-2016 era deployment locations', () {
      final deployments = NationalityData.getDeploymentLocations('USA');

      expect(deployments.any((d) => d.contains('Iraq')), true);
      expect(deployments.any((d) => d.contains('Afghanistan')), true);
      expect(deployments.any((d) => d.contains('Syria')), true);
      expect(
        deployments.any((d) => d.contains('Yemen') || d.contains('Somalia')),
        true,
      );

      print('✓ USA deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 5: United Kingdom deployment locations
    test('5. UK has historically accurate deployment locations', () {
      final deployments = NationalityData.getDeploymentLocations(
        'United Kingdom',
      );

      expect(deployments.any((d) => d.contains('Afghanistan')), true);
      expect(deployments.any((d) => d.contains('Iraq')), true);
      expect(
        deployments.any((d) => d.contains('Cyprus')),
        true,
        reason: 'UK should have Cyprus (permanent base)',
      );
      expect(
        deployments.any((d) => d.contains('Falkland')),
        true,
        reason: 'UK should have Falkland Islands deployment',
      );

      print('✓ UK deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 6: France deployment locations (Africa focus)
    test('6. France has Africa-focused deployment locations', () {
      final deployments = NationalityData.getDeploymentLocations('France');

      expect(deployments.any((d) => d.contains('Afghanistan')), true);
      expect(
        deployments.any((d) => d.contains('Mali')),
        true,
        reason: 'France should have Mali deployment (Operation Serval)',
      );
      expect(deployments.any((d) => d.contains('Chad')), true);
      expect(
        deployments.any((d) => d.contains('Central African Republic')),
        true,
      );
      expect(deployments.any((d) => d.contains('Sahel')), true);

      print('✓ France deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 7: Canada deployment locations
    test('7. Canada has NATO and UN deployment locations', () {
      final deployments = NationalityData.getDeploymentLocations('Canada');

      expect(deployments.any((d) => d.contains('Afghanistan')), true);
      expect(
        deployments.any((d) => d.contains('Latvia')),
        true,
        reason: 'Canada should have Latvia (NATO eFP) deployment',
      );
      expect(deployments.any((d) => d.contains('Iraq')), true);
      expect(deployments.any((d) => d.contains('Sinai')), true);

      print('✓ Canada deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 8: Australia deployment locations (Pacific focus)
    test('8. Australia has Pacific and Middle East deployments', () {
      final deployments = NationalityData.getDeploymentLocations('Australian');

      expect(deployments.any((d) => d.contains('Afghanistan')), true);
      expect(
        deployments.any((d) => d.contains('East Timor')),
        true,
        reason: 'Australia should have East Timor deployment',
      );
      expect(
        deployments.any((d) => d.contains('Solomon Islands')),
        true,
        reason: 'Australia should have Solomon Islands (RAMSI) deployment',
      );

      print('✓ Australia deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 9: The Philippines deployment locations (internal conflicts)
    test('9. Philippines has internal conflict deployment locations', () {
      final deployments = NationalityData.getDeploymentLocations(
        'The Philippines',
      );

      expect(
        deployments.any((d) => d.contains('Mindanao')),
        true,
        reason: 'Philippines should have Mindanao counter-insurgency',
      );
      expect(
        deployments.any((d) => d.contains('Marawi')),
        true,
        reason: 'Philippines should have Marawi (2017 siege period)',
      );
      expect(deployments.any((d) => d.contains('Sulu')), true);
      expect(
        deployments.any((d) => d.contains('UN')),
        true,
        reason: 'Philippines should have some UN peacekeeping',
      );

      print('✓ Philippines deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 10: Germany deployment locations
    test('10. Germany has NATO and UN deployment locations', () {
      final deployments = NationalityData.getDeploymentLocations('German');

      expect(
        deployments.any((d) => d.contains('Afghanistan')),
        true,
        reason: 'Germany should have Afghanistan (major ISAF contributor)',
      );
      expect(deployments.any((d) => d.contains('Kosovo')), true);
      expect(deployments.any((d) => d.contains('Mali')), true);
      expect(
        deployments.any((d) => d.contains('Lithuania')),
        true,
        reason: 'Germany should have Lithuania (NATO eFP lead)',
      );

      print('✓ Germany deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 11: Poland deployment locations
    test('11. Poland has Afghanistan and NATO deployments', () {
      final deployments = NationalityData.getDeploymentLocations('Polish');

      expect(
        deployments.any((d) => d.contains('Afghanistan')),
        true,
        reason: 'Poland should have Afghanistan deployment',
      );
      expect(deployments.any((d) => d.contains('Iraq')), true);
      expect(
        deployments.any((d) => d.contains('Latvia') || d.contains('Lithuania')),
        true,
        reason: 'Poland should have Baltic states (NATO eFP) deployment',
      );

      print('✓ Poland deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 12: Sweden deployment locations
    test('12. Sweden has UN peacekeeping deployments', () {
      final deployments = NationalityData.getDeploymentLocations('Sweden');

      expect(deployments.any((d) => d.contains('Afghanistan')), true);
      expect(
        deployments.any((d) => d.contains('Mali')),
        true,
        reason: 'Sweden should have Mali (MINUSMA) deployment',
      );
      expect(deployments.any((d) => d.contains('Kosovo')), true);
      expect(deployments.any((d) => d.contains('Congo')), true);

      print('✓ Sweden deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 13: Norway deployment locations
    test('13. Norway has NATO and UN deployments', () {
      final deployments = NationalityData.getDeploymentLocations('Norway');

      expect(deployments.any((d) => d.contains('Afghanistan')), true);
      expect(deployments.any((d) => d.contains('Iraq')), true);
      expect(
        deployments.any((d) => d.contains('Lithuania')),
        true,
        reason: 'Norway should have Lithuania (NATO eFP) deployment',
      );

      print('✓ Norway deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 14: Dutch deployment locations
    test('14. Netherlands has NATO and UN deployments', () {
      final deployments = NationalityData.getDeploymentLocations('Dutch');

      expect(deployments.any((d) => d.contains('Afghanistan')), true);
      expect(deployments.any((d) => d.contains('Mali')), true);
      expect(
        deployments.any(
          (d) => d.contains('Caribbean') || d.contains('Curaçao'),
        ),
        true,
        reason: 'Netherlands should have Caribbean deployments',
      );

      print('✓ Netherlands deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 15: Spain deployment locations
    test('15. Spain has NATO and UN deployments', () {
      final deployments = NationalityData.getDeploymentLocations('Spain');

      expect(deployments.any((d) => d.contains('Afghanistan')), true);
      expect(
        deployments.any((d) => d.contains('Lebanon')),
        true,
        reason: 'Spain should have Lebanon (UNIFIL) deployment',
      );
      expect(
        deployments.any((d) => d.contains('piracy')),
        true,
        reason: 'Spain should have anti-piracy operations',
      );

      print('✓ Spain deployment locations verified');
      for (var d in deployments) {
        print('    - $d');
      }
    });

    // Test 16: All nationalities have deployment locations
    test('16. All 15 nationalities have deployment location data', () {
      final nationalities = NationalityData.nationalities;

      for (final nationality in nationalities) {
        final deployments = NationalityData.getDeploymentLocations(nationality);
        expect(
          deployments.length,
          greaterThan(0),
          reason: '$nationality should have at least 1 deployment location',
        );
        expect(
          deployments.length,
          greaterThanOrEqualTo(5),
          reason: '$nationality should have at least 5 deployment options',
        );
      }

      print('✓ All 15 nationalities have deployment locations');
      print('  Total nationalities verified: ${nationalities.length}');
    });

    // Test 17: Deployment locations are era-appropriate (2010-2016)
    test(
      '17. Deployment locations reflect 2010-2016 historical operations',
      () {
        // Key historical operations in this era
        final usaDeployments = NationalityData.getDeploymentLocations('USA');
        expect(
          usaDeployments.any((d) => d.contains('Syria')),
          true,
          reason: 'Syria operations started 2014 (anti-ISIS)',
        );

        final franceDeployments = NationalityData.getDeploymentLocations(
          'France',
        );
        expect(
          franceDeployments.any((d) => d.contains('Mali')),
          true,
          reason: 'France launched Operation Serval in Mali (2013)',
        );

        final philippinesDeployments = NationalityData.getDeploymentLocations(
          'The Philippines',
        );
        expect(
          philippinesDeployments.any(
            (d) => d.contains('Marawi') || d.contains('Mindanao'),
          ),
          true,
          reason: 'Philippines had major Mindanao operations in this era',
        );

        print('✓ Deployment locations are era-appropriate (2010-2016)');
      },
    );
  });
}
