import 'dart:math';
import '../models/oracle.dart';

/// Oracle service for resolving encounters and contacts
class OracleService {
  final Random _random = Random();

  /// Perform an Oracle check to determine if contact occurs
  OracleResult performOracleCheck(OracleCheck check) {
    // Calculate contact probability based on campaign state
    final baseProbability = _calculateBaseProbability(check);
    final roll = _random.nextInt(100) + 1;

    if (roll > baseProbability) {
      return OracleResult(
        outcome: 'No Contact',
        description: 'Patrol completes without incident. Area appears quiet.',
        metadata: {
          'roll': roll,
          'threshold': baseProbability,
          'insurgentActivity': check.insurgentActivity,
        },
      );
    }

    // Contact occurs - determine type
    final contactType = _determineContactType(check);

    if (contactType == 'Environmental Threat') {
      final threat = _generateEnvironmentalThreat(check);
      return OracleResult(
        outcome: 'Environmental Threat',
        description: threat.description,
        metadata: {
          'roll': roll,
          'threshold': baseProbability,
          'threat': threat.toJson(),
        },
      );
    }

    // Full engagement - generate enemy AI
    final enemyAI = _generateEnemyAI(check);
    return OracleResult(
      outcome: 'Full Engagement',
      description: 'Contact! Enemy forces detected in the area.',
      enemyAI: enemyAI,
      metadata: {
        'roll': roll,
        'threshold': baseProbability,
        'insurgentActivity': check.insurgentActivity,
      },
    );
  }

  /// Calculate base contact probability (0-100)
  int _calculateBaseProbability(OracleCheck check) {
    double probability = 30.0; // Base 30% chance

    // Insurgent activity modifier: higher activity = more contact
    probability += (check.insurgentActivity - 50) * 0.4; // ±20%

    // Local trust modifier: lower trust = more contact
    probability += (50 - check.localTrust) * 0.2; // ±10%

    // Intel-driven operations are more likely to find enemy
    if (check.hasIntel) {
      probability += 25.0;
    }

    // Mission type modifiers
    switch (check.missionType) {
      case 'Raid':
        probability += 30.0;
        break;
      case 'Patrol':
        probability += 10.0;
        break;
      case 'Presence':
        probability -= 10.0;
        break;
      case 'Recon':
        probability += 15.0;
        break;
    }

    // Team size: larger teams are more visible
    if (check.teamSize > 6) {
      probability += 5.0;
    } else if (check.teamSize <= 3) {
      probability -= 5.0;
    }

    // Apply custom modifiers
    for (var modifier in check.modifiers.values) {
      if (modifier is num) {
        probability += modifier.toDouble();
      }
    }

    return probability.clamp(5, 95).toInt();
  }

  /// Determine if contact is environmental threat or full engagement
  String _determineContactType(OracleCheck check) {
    // High insurgent activity favors full engagement
    if (check.insurgentActivity > 70) {
      return _random.nextInt(100) < 80
          ? 'Full Engagement'
          : 'Environmental Threat';
    }

    // Medium activity - balanced
    if (check.insurgentActivity > 40) {
      return _random.nextInt(100) < 60
          ? 'Full Engagement'
          : 'Environmental Threat';
    }

    // Low activity favors environmental threats
    return _random.nextInt(100) < 40
        ? 'Full Engagement'
        : 'Environmental Threat';
  }

  /// Generate environmental threat
  EnvironmentalThreat _generateEnvironmentalThreat(OracleCheck check) {
    final threats = [
      EnvironmentalThreat(
        type: 'IED',
        description: 'Suspicious object spotted on the route. Possible IED.',
        severity: 'Severe',
        responseOptions: [
          'Call EOD',
          'Mark and bypass',
          'Investigate with robot',
          'Withdrawal and report',
        ],
        effects: {'stress': 5, 'fatigue': 2},
      ),
      EnvironmentalThreat(
        type: 'Sniper Fire',
        description: 'Single shot from unknown position. Team takes cover.',
        severity: 'Moderate',
        responseOptions: [
          'Return fire',
          'Suppress and maneuver',
          'Call for support',
          'Withdraw under smoke',
        ],
        effects: {'stress': 8, 'morale': -5},
      ),
      EnvironmentalThreat(
        type: 'Hostile Crowd',
        description: 'Locals gather and become agitated. Tensions rising.',
        severity: 'Moderate',
        responseOptions: [
          'De-escalate through interpreter',
          'Display non-lethal deterrents',
          'Request QRF',
          'Withdraw calmly',
        ],
        effects: {'localTrust': -3, 'stress': 3},
      ),
      EnvironmentalThreat(
        type: 'Vehicle Checkpoint',
        description:
            'Suspicious vehicle approaching checkpoint refuses to stop.',
        severity: 'Severe',
        responseOptions: [
          'Escalation of force procedures',
          'Disable vehicle',
          'Take cover and engage',
          'Allow through and report',
        ],
        effects: {'stress': 10, 'commandConfidence': -5},
      ),
      EnvironmentalThreat(
        type: 'Weather/Terrain',
        description: 'Severe weather or terrain hazard impedes movement.',
        severity: 'Minor',
        responseOptions: [
          'Wait it out',
          'Find alternate route',
          'Push through',
          'Return to base',
        ],
        effects: {'fatigue': 10, 'timeDelay': 2},
      ),
    ];

    // Weight selection by insurgent activity
    if (check.insurgentActivity > 60 && _random.nextInt(100) < 70) {
      // Favor IED or Sniper in high-threat areas
      return threats[_random.nextInt(2)];
    }

    return threats[_random.nextInt(threats.length)];
  }

  /// Generate enemy AI behavior
  EnemyAIResult _generateEnemyAI(OracleCheck check) {
    final enemyType = _selectEnemyType(check);
    final stance = _determineStance(check, enemyType);
    final behavior = _determineBehavior(check, enemyType, stance);
    final numBlips = _determineBlipCount(enemyType, check);
    final placement = _determinePlacement(behavior, check);
    final instructions = _generateTacticalInstructions(
      enemyType,
      behavior,
      stance,
      numBlips,
    );

    return EnemyAIResult(
      enemyType: enemyType.name,
      numBlips: numBlips,
      stance: stance,
      behavior: behavior.name,
      sop: _determineSOP(enemyType, stance),
      tacticalInstructions: instructions,
      placement: placement,
      reactionData: {
        'aggressionLevel': _calculateAggressionLevel(stance, check),
        'cohesion': _determineCohesion(enemyType),
        'firepower': _determineFirepower(enemyType),
      },
    );
  }

  /// Select enemy type based on check parameters
  EnemyType _selectEnemyType(OracleCheck check) {
    final types = _getEnemyTypes();

    // Weight selection by insurgent activity and intel
    if (check.hasIntel) {
      // Intel operations more likely to find cells or leadership
      final priority = types
          .where(
            (t) => t.name == 'Fighter Cell' || t.name == 'Heavy Weapons Team',
          )
          .toList();
      if (priority.isNotEmpty && _random.nextInt(100) < 60) {
        return priority[_random.nextInt(priority.length)];
      }
    }

    if (check.insurgentActivity > 70) {
      // High activity: more organized fighters
      final priority = types
          .where((t) => t.name != 'Lone Fighter' && t.name != 'Opportunist')
          .toList();
      return priority[_random.nextInt(priority.length)];
    }

    return types[_random.nextInt(types.length)];
  }

  /// Determine enemy stance
  String _determineStance(OracleCheck check, EnemyType enemyType) {
    final stances = ['Passive', 'Alert', 'Aggressive'];
    final weights = enemyType.stanceWeights;

    // Modify weights based on local trust and activity
    final adjustedWeights = Map<String, int>.from(weights);

    if (check.localTrust < 30) {
      adjustedWeights['Aggressive'] = (adjustedWeights['Aggressive'] ?? 1) + 2;
    }
    if (check.insurgentActivity > 70) {
      adjustedWeights['Aggressive'] = (adjustedWeights['Aggressive'] ?? 1) + 2;
    }
    if (check.teamSize > 8) {
      adjustedWeights['Passive'] = (adjustedWeights['Passive'] ?? 1) + 1;
    }

    return _weightedRandomSelection(adjustedWeights);
  }

  /// Determine tactical behavior
  TacticalBehavior _determineBehavior(
    OracleCheck check,
    EnemyType enemyType,
    String stance,
  ) {
    final behaviors = _getTacticalBehaviors();
    final weights = enemyType.behaviorWeights;

    // Adjust weights based on stance
    final adjustedWeights = Map<String, int>.from(weights);

    if (stance == 'Aggressive') {
      adjustedWeights['Ambush'] = (adjustedWeights['Ambush'] ?? 1) + 2;
      adjustedWeights['Flank'] = (adjustedWeights['Flank'] ?? 1) + 1;
    } else if (stance == 'Passive') {
      adjustedWeights['Withdraw'] = (adjustedWeights['Withdraw'] ?? 0) + 3;
      adjustedWeights['Defend'] = (adjustedWeights['Defend'] ?? 1) + 1;
    }

    final selectedName = _weightedRandomSelection(adjustedWeights);
    return behaviors.firstWhere(
      (b) => b.name == selectedName,
      orElse: () => behaviors[0],
    );
  }

  /// Determine number of enemy contacts/blips
  int _determineBlipCount(EnemyType enemyType, OracleCheck check) {
    var count =
        enemyType.minBlips +
        _random.nextInt(enemyType.maxBlips - enemyType.minBlips + 1);

    // Scale with insurgent activity
    if (check.insurgentActivity > 70) {
      count = (count * 1.5).toInt();
    } else if (check.insurgentActivity < 30) {
      count = (count * 0.7).toInt();
    }

    return count.clamp(enemyType.minBlips, enemyType.maxBlips + 2);
  }

  /// Determine enemy placement guidance
  PlacementGuide _determinePlacement(
    TacticalBehavior behavior,
    OracleCheck check,
  ) {
    final directions = [
      'Front',
      'Flank Left',
      'Flank Right',
      'Rear',
      'Elevated',
    ];
    final terrains = [
      'Hard Cover',
      'Soft Cover',
      'Concealment',
      'Building',
      'Rooftop',
    ];

    String direction;
    String terrain;
    int range;

    switch (behavior.id) {
      case 'ambush':
        direction = _random.nextBool() ? 'Flank Left' : 'Flank Right';
        terrain = 'Hard Cover';
        range = 2;
        break;
      case 'defend':
        direction = 'Front';
        terrain = 'Building';
        range = 4;
        break;
      case 'hit_and_run':
        direction = 'Elevated';
        terrain = 'Rooftop';
        range = 5;
        break;
      case 'flank':
        direction = _random.nextBool() ? 'Flank Left' : 'Flank Right';
        terrain = 'Soft Cover';
        range = 3;
        break;
      default:
        direction = directions[_random.nextInt(directions.length)];
        terrain = terrains[_random.nextInt(terrains.length)];
        range = 3;
    }

    return PlacementGuide(
      direction: direction,
      terrain: terrain,
      range: range,
      notes:
          'Enemy likely positioned in $terrain to the $direction at approximately $range hexes.',
    );
  }

  /// Generate tactical instructions for player
  List<String> _generateTacticalInstructions(
    EnemyType enemyType,
    TacticalBehavior behavior,
    String stance,
    int numBlips,
  ) {
    final instructions = <String>[
      'CONTACT: ${enemyType.name} detected',
      'ENEMY COUNT: $numBlips blip(s)',
      'STANCE: $stance',
      'BEHAVIOR: ${behavior.name}',
      '',
      'TACTICAL RESPONSE:',
    ];

    instructions.addAll(behavior.instructions);

    // Add stance-specific guidance
    if (stance == 'Aggressive') {
      instructions.add(
        '• Enemy is AGGRESSIVE - expect immediate and sustained fire',
      );
      instructions.add(
        '• Enemy will likely attempt to close distance or flank',
      );
    } else if (stance == 'Passive') {
      instructions.add('• Enemy is PASSIVE - may withdraw if pressured');
      instructions.add('• Opportunity for de-escalation or quiet success');
    } else {
      instructions.add('• Enemy is ALERT - will react to your movements');
      instructions.add('• Maintain initiative and dictate engagement terms');
    }

    return instructions;
  }

  /// Determine Standard Operating Procedure
  String _determineSOP(EnemyType enemyType, String stance) {
    if (stance == 'Aggressive') {
      return 'Offensive - Engage and pursue';
    } else if (stance == 'Passive') {
      return 'Defensive - Hold fire unless engaged';
    }
    return 'Standard - React to contact';
  }

  /// Calculate aggression level (0-100)
  int _calculateAggressionLevel(String stance, OracleCheck check) {
    var level = 50;

    switch (stance) {
      case 'Aggressive':
        level = 80;
        break;
      case 'Alert':
        level = 50;
        break;
      case 'Passive':
        level = 20;
        break;
    }

    // Modify by insurgent activity
    level += ((check.insurgentActivity - 50) * 0.3).toInt();

    return level.clamp(0, 100);
  }

  /// Determine enemy cohesion (how organized they are)
  String _determineCohesion(EnemyType enemyType) {
    if (enemyType.name.contains('Cell') || enemyType.name.contains('Team')) {
      return 'High';
    } else if (enemyType.name.contains('Mob') ||
        enemyType.name.contains('Militia')) {
      return 'Low';
    }
    return 'Medium';
  }

  /// Determine enemy firepower level
  String _determineFirepower(EnemyType enemyType) {
    if (enemyType.name.contains('Heavy') ||
        enemyType.name.contains('Weapons')) {
      return 'Heavy';
    } else if (enemyType.name.contains('Lone') ||
        enemyType.name.contains('Opportunist')) {
      return 'Light';
    }
    return 'Medium';
  }

  /// Weighted random selection helper
  String _weightedRandomSelection(Map<String, int> weights) {
    final totalWeight = weights.values.reduce((a, b) => a + b);
    var roll = _random.nextInt(totalWeight);

    for (var entry in weights.entries) {
      roll -= entry.value;
      if (roll < 0) {
        return entry.key;
      }
    }

    return weights.keys.first;
  }

  /// Get enemy type definitions (moved to data in future)
  List<EnemyType> _getEnemyTypes() {
    return [
      EnemyType(
        id: 'fighter',
        name: 'Fighter',
        description: 'Standard insurgent fighter with AK-47',
        stanceWeights: {'Passive': 1, 'Alert': 3, 'Aggressive': 2},
        behaviorWeights: {
          'Defend': 2,
          'Ambush': 2,
          'Hit-and-Run': 1,
          'Flank': 1,
        },
        minBlips: 1,
        maxBlips: 3,
      ),
      EnemyType(
        id: 'cell',
        name: 'Fighter Cell',
        description: 'Organized cell of 3-6 fighters',
        stanceWeights: {'Passive': 1, 'Alert': 2, 'Aggressive': 3},
        behaviorWeights: {
          'Ambush': 3,
          'Flank': 2,
          'Defend': 1,
          'Hit-and-Run': 1,
        },
        minBlips: 2,
        maxBlips: 4,
      ),
      EnemyType(
        id: 'heavy_weapons',
        name: 'Heavy Weapons Team',
        description: 'PKM or RPK team with support',
        stanceWeights: {'Passive': 1, 'Alert': 3, 'Aggressive': 2},
        behaviorWeights: {'Defend': 3, 'Suppress': 2, 'Ambush': 1},
        minBlips: 2,
        maxBlips: 3,
        traits: ['Suppressive Fire', 'Area Denial'],
      ),
      EnemyType(
        id: 'sniper',
        name: 'Sniper',
        description: 'Lone sniper or spotter-shooter pair',
        stanceWeights: {'Passive': 2, 'Alert': 3, 'Aggressive': 1},
        behaviorWeights: {'Hit-and-Run': 4, 'Defend': 1, 'Withdraw': 2},
        minBlips: 1,
        maxBlips: 2,
        preferredTerrain: 'Elevated',
        traits: ['Long Range', 'Elusive'],
      ),
      EnemyType(
        id: 'lone_fighter',
        name: 'Lone Fighter',
        description: 'Single opportunist or lookout',
        stanceWeights: {'Passive': 3, 'Alert': 2, 'Aggressive': 1},
        behaviorWeights: {'Withdraw': 3, 'Hit-and-Run': 2, 'Defend': 1},
        minBlips: 1,
        maxBlips: 1,
      ),
    ];
  }

  /// Get tactical behavior definitions (moved to data in future)
  List<TacticalBehavior> _getTacticalBehaviors() {
    return [
      TacticalBehavior(
        id: 'ambush',
        name: 'Ambush',
        description: 'Enemy initiates from concealed position',
        instructions: [
          '• Enemy opens fire from concealment',
          '• Place enemy in cover with clear fields of fire',
          '• Enemy holds position until suppressed or flanked',
          '• Will attempt to break contact if overwhelmed',
        ],
      ),
      TacticalBehavior(
        id: 'defend',
        name: 'Defend',
        description: 'Enemy holds prepared position',
        instructions: [
          '• Enemy occupies fortified or advantageous position',
          '• Will defend tenaciously but not pursue',
          '• Focuses fire on closest threats',
          '• May withdraw if position becomes untenable',
        ],
      ),
      TacticalBehavior(
        id: 'hit_and_run',
        name: 'Hit-and-Run',
        description: 'Enemy engages briefly then withdraws',
        instructions: [
          '• Enemy fires 1-2 volleys then displaces',
          '• Attempts to break line of sight quickly',
          '• May re-engage from new position',
          '• Difficult to pin down or pursue',
        ],
      ),
      TacticalBehavior(
        id: 'flank',
        name: 'Flank',
        description: 'Enemy attempts to maneuver around your position',
        instructions: [
          '• 1-2 elements provide suppressing fire',
          '• Remaining element(s) maneuver to your flank',
          '• Flanking element will engage from new angle',
          '• Counter by refusing flank or shifting position',
        ],
      ),
      TacticalBehavior(
        id: 'suppress',
        name: 'Suppress',
        description: 'Enemy lays down heavy suppressive fire',
        instructions: [
          '• Enemy seeks to pin you in place',
          '• High volume of fire, may not be accurate',
          '• Enables other elements to maneuver or withdraw',
          '• Counter with fire superiority or smoke',
        ],
      ),
      TacticalBehavior(
        id: 'withdraw',
        name: 'Withdraw',
        description: 'Enemy attempts to break contact',
        instructions: [
          '• Enemy fires and moves toward exit',
          '• May use smoke or concealment',
          '• Will not stand and fight if pressed',
          '• Opportunity for pursuit or letting them go',
        ],
      ),
    ];
  }
}
