/// Body type descriptors based on height and weight combinations
class BodyTypeDescriptor {
  /// Get weight category from weight value (in lbs)
  static String getWeightCategory(double weight) {
    if (weight < 160) return 'Wiry';
    if (weight < 180) return 'Athletic';
    if (weight < 220) return 'Burly';
    return 'Hulk';
  }

  /// Get the short label for weight category
  static String getWeightLabel(String category) {
    switch (category) {
      case 'Wiry':
        return 'Light';
      case 'Athletic':
        return 'Med';
      case 'Burly':
        return 'Heavy';
      case 'Hulk':
        return 'Massive';
      default:
        return 'Med';
    }
  }

  /// Get height category from height string
  static String getHeightCategory(String height) {
    final lower = height.toLowerCase();
    if (lower.contains('compact') || lower.contains('short')) {
      return 'Compact';
    } else if (lower.contains('rangy') ||
        lower.contains('tall') &&
            !lower.contains('towering') &&
            !lower.contains('very')) {
      return 'Rangy';
    } else if (lower.contains('towering') || lower.contains('very tall')) {
      return 'Towering';
    }
    return 'Standard'; // Default to Standard/Avg
  }

  /// Get body type descriptor based on height and weight
  /// Returns both the archetype name and description
  static Map<String, String> getBodyTypeDescriptor(
    String height,
    double weightInLbs,
  ) {
    final heightCat = getHeightCategory(height);
    final weightCat = getWeightCategory(weightInLbs);

    final descriptors = {
      'Compact-Wiry': {
        'name': 'The Jockey',
        'description': 'Ideal Pilot/Driver',
      },
      'Compact-Athletic': {
        'name': 'The Terrier',
        'description': 'Scrappy CQC fighter',
      },
      'Compact-Burly': {
        'name': 'The Fireplug',
        'description': 'Impossible to knock over',
      },
      'Compact-Hulk': {
        'name': 'The Mini-Tank',
        'description': 'Dense muscle ball',
      },
      'Standard-Wiry': {'name': 'The Sprinter', 'description': 'Fast courier'},
      'Standard-Athletic': {
        'name': 'The Grunt',
        'description': 'Jack of all trades',
      },
      'Standard-Burly': {'name': 'The Linebacker', 'description': 'Breacher'},
      'Standard-Hulk': {
        'name': 'The Brawler',
        'description': 'Bar fight specialist',
      },
      'Rangy-Wiry': {
        'name': 'The Sniper',
        'description': 'Lanky, blends into brush',
      },
      'Rangy-Athletic': {
        'name': 'The Athlete',
        'description': 'Spec-Ops build',
      },
      'Rangy-Burly': {'name': 'The Viking', 'description': 'Axe-handle wide'},
      'Rangy-Hulk': {
        'name': 'The Juggernaut',
        'description': 'Heavy Weapons Guy',
      },
      'Towering-Wiry': {'name': 'The Stork', 'description': 'Reach for days'},
      'Towering-Athletic': {
        'name': 'The Hoopster',
        'description': 'Fast but huge target',
      },
      'Towering-Burly': {
        'name': 'The Sentinel',
        'description': 'Walking cover',
      },
      'Towering-Hulk': {
        'name': 'The Sasquatch',
        'description': 'Uses two-handed guns as pistols',
      },
    };

    final key = '$heightCat-$weightCat';
    return descriptors[key] ??
        {'name': 'The Grunt', 'description': 'Standard build'};
  }

  /// Get a full body type description string
  static String getFullBodyTypeDescription(String height, double weightInLbs) {
    final descriptor = getBodyTypeDescriptor(height, weightInLbs);
    final heightCat = getHeightCategory(height);
    final weightCat = getWeightCategory(weightInLbs);
    final weightLabel = getWeightLabel(weightCat);

    return '${descriptor['name']} ($heightCat, $weightLabel): ${descriptor['description']}';
  }

  /// Get just the archetype name
  static String getArchetypeName(String height, double weightInLbs) {
    final descriptor = getBodyTypeDescriptor(height, weightInLbs);
    return descriptor['name'] ?? 'The Grunt';
  }
}
