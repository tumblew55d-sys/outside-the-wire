import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_application_4patrol/data/nationality_data.dart';
import 'package:flutter_application_4patrol/models/character.dart';
import 'package:flutter_application_4patrol/screens/dashboard.dart';
import 'package:flutter_application_4patrol/screens/screen_b_enlistment.dart';
import 'package:flutter_application_4patrol/services/promotion_service.dart';
import 'package:flutter_application_4patrol/services/quick_build_service.dart';

const _nationalities = [
  'USA',
  'United Kingdom',
  'France',
  'Canada',
  'Norway',
  'Dutch',
  'Australian',
  'German',
  'Spain',
  'The Philippines',
  'Polish',
  'Sweden',
  'Brazil',
  'New Zealand',
  'Panama',
];

/// Career roll table from DeploymentsScreen._processCareerRoll.
const _rollTable = <int, ({bool officer, bool sergeant})>{
  1: (officer: true, sergeant: false),
  2: (officer: false, sergeant: true),
  3: (officer: false, sergeant: true),
  4: (officer: false, sergeant: true),
  5: (officer: false, sergeant: false),
  6: (officer: false, sergeant: true),
  7: (officer: false, sergeant: true),
  8: (officer: false, sergeant: true),
  9: (officer: false, sergeant: true),
  10: (officer: false, sergeant: true),
};

/// Mirrors the rank handling in DeploymentsScreen._saveDeployments.
String? _deploymentRound(
  Map<String, dynamic> enlistment,
  String nationality,
  int roll,
) {
  final rollFlags = _rollTable[roll]!;
  final rankType = (enlistment['rankType'] ?? 'Enlisted').toString();
  final n = PromotionService.normalizeCareerPromotion(
    officerPromotion: rollFlags.officer,
    sergeantPromotion: rollFlags.sergeant,
    rankType: rankType,
  );
  final current = enlistment['rank'].toString();
  final next = PromotionService.promotedRank(
    currentRank: current,
    rankType: rankType,
    service: (enlistment['service'] ?? 'Army').toString(),
    nationality: nationality,
    officerPromotion: n.officer,
    sergeantPromotion: n.sergeant,
  );
  if (n.officer || n.sergeant) {
    enlistment['rank'] = next;
    if (n.officer) enlistment['rankType'] = 'Officer';
  }
  return next != current ? next : null;
}

void main() {
  group('Concern 2: promotion pressure test (normal build)', () {
    test('German officer never gets the same promotion rank twice', () {
      for (final start in ['Leutnant', 'Oberleutnant']) {
        for (var r1 = 1; r1 <= 10; r1++) {
          for (var r2 = 1; r2 <= 10; r2++) {
            for (var r3 = 1; r3 <= 10; r3++) {
              final en = <String, dynamic>{
                'service': 'Army',
                'rankType': 'Officer',
                'rank': start,
              };
              final promos = [
                _deploymentRound(en, 'German', r1),
                _deploymentRound(en, 'German', r2),
                _deploymentRound(en, 'German', r3),
              ].whereType<String>().toList();
              expect(
                promos.toSet().length,
                promos.length,
                reason: 'start=$start rolls=$r1,$r2,$r3 promos=$promos',
              );
            }
          }
        }
      }
    });

    test('officer rolling a commission is promoted one rank, not repeated', () {
      final en = <String, dynamic>{
        'service': 'Army',
        'rankType': 'Officer',
        'rank': 'Oberleutnant',
      };
      expect(_deploymentRound(en, 'German', 1), 'Hauptmann');
      expect(_deploymentRound(en, 'German', 1), 'Major');
    });

    test('enlisted commission switches to officer ladder for re-enlistment', () {
      final en = <String, dynamic>{
        'service': 'Army',
        'rankType': 'Enlisted',
        'rank': 'Obergefreiter',
      };
      expect(_deploymentRound(en, 'German', 1), 'Leutnant');
      expect(en['rankType'], 'Officer');
      expect(_deploymentRound(en, 'German', 2), 'Oberleutnant');
      expect(_deploymentRound(en, 'German', 2), 'Hauptmann');
      expect(_deploymentRound(en, 'German', 1), 'Major');
    });

    test('top of the ladder produces no phantom promotion records', () {
      final ranks = PromotionService.rankLadder('German', 'Army', true);
      final en = <String, dynamic>{
        'service': 'Army',
        'rankType': 'Officer',
        'rank': ranks.last,
      };
      expect(_deploymentRound(en, 'German', 2), isNull);
      expect(en['rank'], ranks.last);
    });

    test('all nationalities, start ranks, services: ranks only move up, '
        'promotion records are unique', () {
      for (final nat in _nationalities) {
        for (final service in ['Army', 'Navy']) {
          final starts = <String, List<String>>{
            'Enlisted': service == 'Navy'
                ? NationalityData.getInitialNavyEnlistedRanks(nat)['ranks']!
                : NationalityData.getInitialEnlistedRanks(nat)['ranks']!,
            'Officer': service == 'Navy'
                ? NationalityData.getInitialNavyOfficerRanks(nat)['ranks']!
                : NationalityData.getInitialOfficerRanks(nat)['ranks']!,
          };
          starts.forEach((rankType, startRanks) {
            for (final start in startRanks) {
              for (final seq in [
                [1, 1, 1],
                [2, 2, 2],
                [1, 2, 8],
                [5, 1, 5],
                [10, 1, 9],
                [8, 8, 8, 8, 8, 8, 8],
              ]) {
                final en = <String, dynamic>{
                  'service': service,
                  'rankType': rankType,
                  'rank': start,
                };
                final promos = <String>[];
                for (final roll in seq) {
                  final before = en['rank'] as String;
                  final rec = _deploymentRound(en, nat, roll);
                  if (rec != null) {
                    promos.add(rec);
                    expect(rec, isNot(before));
                  }
                  final ladder = PromotionService.rankLadder(
                    nat,
                    service,
                    en['rankType'] == 'Officer',
                  );
                  expect(
                    ladder,
                    contains(en['rank']),
                    reason: '$nat/$service/$rankType/$start seq=$seq',
                  );
                }
                expect(
                  promos.toSet().length,
                  promos.length,
                  reason: '$nat/$service/$rankType/$start seq=$seq $promos',
                );
              }
            }
          });
        }
      }
    });
  });

  group('Concern 2: promotion pressure test (quick build)', () {
    final specialties = [
      'Rifleman',
      'Heavy Weapons',
      'Sniper',
      'Radio Operator',
      'Medic',
      'EOD',
      'JTAC',
      'SOF',
      'Agent',
    ];

    for (final nat in _nationalities) {
      test('quick build $nat: always enlisted, no repeated promotions', () async {
        final enlistedLadder = PromotionService.rankLadder(nat, 'Army', false);
        final officerLadder = PromotionService.rankLadder(nat, 'Army', true);

        for (final specialty in specialties) {
          for (var i = 0; i < 15; i++) {
            final base = Character(
              id: 'qb-$nat-$specialty-$i',
              name: 'Quick $i',
              nationality: nat,
              age: 17,
            );
            final c = await QuickBuildService.generateQuickCharacter(
              base.id,
              specialty,
              base,
            );
            final rank = c.enlistment['rank'].toString();
            final reason = '$nat/$specialty rank=$rank';

            expect(c.enlistment['rankType'], 'Enlisted', reason: reason);
            expect(enlistedLadder, contains(rank), reason: reason);
            expect(officerLadder, isNot(contains(rank)), reason: reason);

            final deployments = (c.enlistment['deployments'] as List)
                .cast<Map>();
            final promos = deployments
                .map((d) => d['promotionRank']?.toString() ?? '')
                .where((p) => p.isNotEmpty)
                .toList();
            expect(promos.toSet().length, promos.length, reason: reason);

            final narrative = c.toJson().toString();
            final matches = RegExp(
              r'promoted to ([^.,]+)',
            ).allMatches(narrative).map((m) => m.group(1)).toList();
            expect(
              matches.toSet().length,
              matches.length,
              reason: '$reason narrative promos=$matches',
            );

            if (specialty == 'EOD' || specialty == 'JTAC') {
              expect(
                enlistedLadder.indexOf(rank),
                greaterThanOrEqualTo(4),
                reason: '$reason must be E-5+',
              );
            }
          }
        }
      });
    }
  });

  group('Concern 1: Edit does not restart the whole process', () {
    late Directory dir;
    late Box box;

    Character built(String id, {bool withEnlistment = true}) => Character(
      id: id,
      name: 'Edit $id',
      nationality: 'German',
      age: 25,
      enlistment: withEnlistment
          ? {
              'service': 'Army',
              'rankType': 'Enlisted',
              'rank': 'Gefreiter',
              'specialty': 'Rifleman',
            }
          : {},
      inventory: {
        'loadoutWeapons': ['G36'],
        'selectedEquipment': ['Helmet'],
      },
    );

    setUpAll(() async {
      dir = Directory.systemTemp.createTempSync('hive_edit_ui_');
      Hive.init(dir.path);
      box = await Hive.openBox('characters');
    });

    tearDownAll(() async {
      await box.close();
      await Hive.close();
      dir.deleteSync(recursive: true);
    });

    Future<Character> seed(WidgetTester tester, Character c) async {
      await tester.runAsync(() async {
        await box.clear();
        await box.put(c.id, c.toJson());
      });
      return c;
    }

    Future<void> openDashboard(WidgetTester tester, Character c) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen(sampleRoster: [c])),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 600));
    }

    Future<void> openEditChooser(WidgetTester tester) async {
      await tester.tap(find.byIcon(Icons.more_vert).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
    }

    testWidgets('menu Edit shows the section chooser, not enlistment', (
      tester,
    ) async {
      final c = await seed(tester, built('ui-1'));
      await openDashboard(tester, c);
      await openEditChooser(tester);

      expect(find.text('Edit character:'), findsOneWidget);
      expect(find.text('Basic Info'), findsOneWidget);
      expect(find.text('Deployments'), findsOneWidget);
      expect(find.text('Abilities & Narrative'), findsOneWidget);
      expect(find.text('Inventory & Equipment'), findsOneWidget);
      expect(find.byType(EnlistmentScreen), findsNothing);
    });

    testWidgets('long press also shows the chooser', (tester) async {
      final c = await seed(tester, built('ui-2'));
      await openDashboard(tester, c);
      await tester.longPress(find.text('Edit ui-2'));
      await tester.pumpAndSettle();

      expect(find.text('Edit character:'), findsOneWidget);
      expect(find.byType(EnlistmentScreen), findsNothing);
    });

    testWidgets('Enlistment on a built character asks before restarting', (
      tester,
    ) async {
      final c = await seed(tester, built('ui-3'));
      await openDashboard(tester, c);
      await openEditChooser(tester);

      await tester.tap(find.text('Enlistment'));
      await tester.pumpAndSettle();
      expect(find.text('Redo Enlistment?'), findsOneWidget);
      expect(find.byType(EnlistmentScreen), findsNothing);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(EnlistmentScreen), findsNothing);

      final stored = Character.fromJson(
        Map<String, dynamic>.from(box.get('ui-3')),
      );
      expect(stored.enlistment['rank'], 'Gefreiter');
      expect(stored.inventory['loadoutWeapons'], ['G36']);
    });

    testWidgets('confirming restart opens enlistment', (tester) async {
      final c = await seed(tester, built('ui-4'));
      await openDashboard(tester, c);
      await openEditChooser(tester);

      await tester.tap(find.text('Enlistment'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restart Enlistment'));
      await tester.pumpAndSettle();
      expect(find.byType(EnlistmentScreen), findsOneWidget);
    });

    testWidgets('new character without enlistment goes straight to it', (
      tester,
    ) async {
      final c = await seed(tester, built('ui-5', withEnlistment: false));
      await openDashboard(tester, c);
      await openEditChooser(tester);

      await tester.tap(find.text('Enlistment'));
      await tester.pumpAndSettle();
      expect(find.text('Redo Enlistment?'), findsNothing);
      expect(find.byType(EnlistmentScreen), findsOneWidget);
    });

    testWidgets('later sections are disabled until enlistment exists', (
      tester,
    ) async {
      final c = await seed(tester, built('ui-6', withEnlistment: false));
      await openDashboard(tester, c);
      await openEditChooser(tester);

      final deployments = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Deployments'),
      );
      expect(deployments.onPressed, isNull);
    });

    testWidgets('repeated open/cancel cycles never lose data', (tester) async {
      final c = await seed(tester, built('ui-7'));
      await openDashboard(tester, c);
      for (var i = 0; i < 10; i++) {
        await openEditChooser(tester);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      }
      final stored = Character.fromJson(
        Map<String, dynamic>.from(box.get('ui-7')),
      );
      expect(stored.inventory['selectedEquipment'], ['Helmet']);
      expect(stored.enlistment['specialty'], 'Rifleman');
    });
  });
}
