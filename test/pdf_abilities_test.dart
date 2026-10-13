import 'dart:convert';

import 'package:flutter_application_4patrol/models/character.dart';
import 'package:flutter_application_4patrol/services/abilities_resolver.dart';
import 'package:flutter_application_4patrol/services/pdf_character_sheet_service.dart';
import 'package:flutter_test/flutter_test.dart';

Character _character({Map<String, dynamic>? enlistment}) => Character(
  id: 'pdf-test',
  name: 'Test Soldier',
  nationality: 'American',
  languages: ['English', 'Arabic', 'Pashto'],
  attributes: {
    'Strength': 3,
    'Agility': 2,
    'Combat Knowledge': 2,
    'Combat Wisdom': 1,
  },
  skills: {'Combat': 2, 'Training': 1, 'Small Arms': 2, 'First Aid': 1},
  enlistment: {
    'service': 'Army',
    'rank': 'SGT',
    'specialty': 'Rifleman',
    'narrative': List.filled(
      40,
      'Long narrative sentence for layout.',
    ).join(' '),
    ...?enlistment,
  },
);

/// Uncompressed PDF text; the pdf package emits one string per word.
Future<String> _pdfText(Character c) async {
  final bytes = await PdfCharacterSheetService.buildDocument(
    c,
    compress: false,
  ).save();
  return latin1.decode(bytes);
}

void expectLabels(String text, List<String> labels) {
  for (final l in labels) {
    for (final w in l.split(' ')) {
      expect(text, contains('($w'), reason: '$l missing');
    }
  }
}

void main() {
  const labels = [
    'ABILITIES',
    'Prowess',
    'Instincts',
    'Tactics',
    'Small Arms',
    'Heavy Weapons',
    'First Aid',
    'Communication',
    'Civil Affairs',
    'Fires',
    'Spying',
    'Explosives',
    'Signals Intel',
  ];

  test('abilities appear in PDF when stored (typed map)', () async {
    final c = _character();
    c.enlistment['abilities'] = AbilitiesResolver.calculate(c);
    final text = await _pdfText(c);
    expectLabels(text, labels);
  });

  test('abilities appear in PDF when missing from data', () async {
    final text = await _pdfText(_character());
    expectLabels(text, labels);
  });

  test('abilities appear when stored map is Map<dynamic,dynamic>', () async {
    final c = _character(
      enlistment: {
        'abilities': <dynamic, dynamic>{'Prowess': 9},
      },
    );
    final text = await _pdfText(c);
    expectLabels(text, labels);
    expect(AbilitiesResolver.resolve(c)['Prowess'], 9);
    expect(AbilitiesResolver.resolve(c)['Tactics'], isNonZero);
  });

  test('resolver matches expected formulas', () {
    final r = AbilitiesResolver.resolve(_character());
    expect(r['Prowess'], 3 + 2 + 1);
    expect(r['Tactics'], 2 + 2 + 1 + 1); // Rifleman bonus
    expect(r['Small Arms'], 2 + 2 + 2);
    expect(r['Heavy Weapons'], (0 + 2 + 2) ~/ 2); // unearned, halved
  });

  test('abilities render with maximum content on page one', () async {
    final c = _character(
      enlistment: {
        'narrative': List.filled(
          400,
          'Very long narrative sentence.',
        ).join(' '),
      },
    );
    c.medals = List.filled(12, 'Bronze Star Medal with Valor Device');
    final text = await _pdfText(c);
    expect(text, contains('ABILITIES'));
  });

  test('field log page with fillable fields is included', () async {
    final text = await _pdfText(_character());
    expectLabels(text, ['FIELD LOG', 'AFTER ACTION REPORT']);
    for (final n in ['log1_dtg', 'log2_grid', 'log3_details']) {
      expect(text, contains(n));
    }
    expect(text, contains('/AcroForm'));
  });

  test('sheet fits one page before equipment and field log', () async {
    final c = _character(
      enlistment: {
        'narrative':
            '${List.filled(
              6,
              'Mitchell is a rangy Australian Army Rifleman Sergeant motivated by Career Ambition.',
            ).join(' ')}\n\nDeployment History: Solomon Islands.',
      },
    );
    c.background = 'EMT / Medical Volunteer (First Aid +1)';
    c.specialtyHook =
        'Feels guilty when aircraft cannot respond due to weather or rules of engagement and the ground force pays for it.';
    c.personalConflict =
        'You are questioning the mission legitimacy and your role in it.';
    c.trademark = 'Photo of loved ones';
    final text = await _pdfText(c);
    final pages = RegExp(r'/Type\s*/Page(?!s)').allMatches(text).length;
    expect(pages, 3);
    expect(
      '(Generated:'.allMatches(text).length,
      2,
      reason: 'footer on pages 1 and 2',
    );
    expectLabels(text, ['SKILLS', 'EQUIPMENT', 'EQUIPMENT']);
  });
}
