import '../models/character.dart';

/// Resolves the 12 derived abilities for PDF export, tolerating loosely typed stored data.
class AbilitiesResolver {
  static const List<String> abilityNames = [
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

  /// Stored values win; any missing/invalid ability is computed from attributes and skills.
  static Map<String, int> resolve(Character character) {
    final computed = calculate(character);
    final stored = character.enlistment['abilities'];
    final result = <String, int>{};

    for (final name in abilityNames) {
      int? value;
      if (stored is Map) {
        final raw = stored[name];
        if (raw is num) {
          value = raw.toInt();
        } else if (raw is String) {
          value = int.tryParse(raw);
        }
      }
      result[name] = value ?? computed[name]!;
    }
    return result;
  }

  /// Mirrors the formulas in screen_d_abilities.dart.
  static Map<String, int> calculate(Character character) {
    final a = character.attributes;
    final s = character.skills;

    int val(Map<String, int> map, String key) => map[key] ?? 0;
    int penalize(int base, bool earned) => earned ? base : (base ~/ 2);
    int skillBased(String skill, String attrKey) => penalize(
      val(s, skill) + val(a, attrKey) + val(s, 'Combat'),
      val(s, skill) > 0,
    );

    final specialty = character.enlistment['specialty']?.toString() ?? '';
    var tactics =
        val(a, 'Combat Knowledge') + val(s, 'Combat') + val(s, 'Training');
    if (specialty.contains('Rifleman')) tactics += 1;

    return {
      'Prowess': val(a, 'Strength') + val(s, 'Combat') + val(s, 'Training'),
      'Instincts':
          val(a, 'Combat Wisdom') + val(s, 'Training') + val(s, 'Combat'),
      'Tactics': tactics,
      'Small Arms': skillBased('Small Arms', 'Agility'),
      'Heavy Weapons': skillBased('Heavy Weapons', 'Agility'),
      'First Aid': skillBased('First Aid', 'Combat Wisdom'),
      'Communication': skillBased('Radio Ops', 'Combat Wisdom'),
      'Civil Affairs': skillBased('Civil Affairs', 'Combat Wisdom'),
      'Fires': skillBased('Fires', 'Combat Wisdom'),
      'Spying': skillBased('Spying', 'Combat Wisdom'),
      'Explosives': skillBased('Explosives', 'Combat Wisdom'),
      'Signals Intel': skillBased('Signals Intel', 'Combat Wisdom'),
    };
  }
}
