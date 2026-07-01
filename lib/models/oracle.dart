/// Oracle resolution results for contact determination
class OracleResult {
  final String
  outcome; // 'No Contact', 'Environmental Threat', 'Full Engagement'
  final String description;
  final EnemyAIResult? enemyAI;
  final Map<String, dynamic> metadata;

  OracleResult({
    required this.outcome,
    this.description = '',
    this.enemyAI,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? {};

  Map<String, dynamic> toJson() => {
    'outcome': outcome,
    'description': description,
    'enemyAI': enemyAI?.toJson(),
    'metadata': metadata,
  };

  factory OracleResult.fromJson(Map<String, dynamic> json) => OracleResult(
    outcome: json['outcome'] ?? 'No Contact',
    description: json['description'] ?? '',
    enemyAI: json['enemyAI'] != null
        ? EnemyAIResult.fromJson(json['enemyAI'])
        : null,
    metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
  );
}

/// Enemy AI behavior resolution
class EnemyAIResult {
  final String enemyType; // Fighter, Cell, Heavy Weapons, Sniper, etc.
  final int numBlips; // Number of enemy contacts
  final String stance; // Passive, Alert, Aggressive
  final String behavior; // Primary tactical behavior
  final String sop; // Standard Operating Procedure
  final List<String> tacticalInstructions; // Step-by-step for player
  final PlacementGuide placement;
  final Map<String, dynamic> reactionData;

  EnemyAIResult({
    required this.enemyType,
    required this.numBlips,
    required this.stance,
    required this.behavior,
    this.sop = 'Standard',
    List<String>? tacticalInstructions,
    PlacementGuide? placement,
    Map<String, dynamic>? reactionData,
  }) : tacticalInstructions = tacticalInstructions ?? [],
       placement = placement ?? PlacementGuide(),
       reactionData = reactionData ?? {};

  Map<String, dynamic> toJson() => {
    'enemyType': enemyType,
    'numBlips': numBlips,
    'stance': stance,
    'behavior': behavior,
    'sop': sop,
    'tacticalInstructions': tacticalInstructions,
    'placement': placement.toJson(),
    'reactionData': reactionData,
  };

  factory EnemyAIResult.fromJson(Map<String, dynamic> json) => EnemyAIResult(
    enemyType: json['enemyType'] ?? 'Fighter',
    numBlips: json['numBlips'] ?? 1,
    stance: json['stance'] ?? 'Alert',
    behavior: json['behavior'] ?? 'Defend',
    sop: json['sop'] ?? 'Standard',
    tacticalInstructions: List<String>.from(json['tacticalInstructions'] ?? []),
    placement: json['placement'] != null
        ? PlacementGuide.fromJson(json['placement'])
        : PlacementGuide(),
    reactionData: Map<String, dynamic>.from(json['reactionData'] ?? {}),
  );
}

/// Placement guidance for enemy forces on the map
class PlacementGuide {
  final List<String> suggestedHexes; // Hex coordinates or descriptions
  final String direction; // North, South, Flanking, etc.
  final String terrain; // Cover type or terrain preference
  final int range; // Engagement range in hexes
  final String notes;

  PlacementGuide({
    List<String>? suggestedHexes,
    this.direction = 'Front',
    this.terrain = 'Cover',
    this.range = 3,
    this.notes = '',
  }) : suggestedHexes = suggestedHexes ?? [];

  Map<String, dynamic> toJson() => {
    'suggestedHexes': suggestedHexes,
    'direction': direction,
    'terrain': terrain,
    'range': range,
    'notes': notes,
  };

  factory PlacementGuide.fromJson(Map<String, dynamic> json) => PlacementGuide(
    suggestedHexes: List<String>.from(json['suggestedHexes'] ?? []),
    direction: json['direction'] ?? 'Front',
    terrain: json['terrain'] ?? 'Cover',
    range: json['range'] ?? 3,
    notes: json['notes'] ?? '',
  );
}

/// Enemy type definition for AI behavior
class EnemyType {
  final String id;
  final String name;
  final String description;
  final Map<String, int> stanceWeights; // Stance -> probability weight
  final Map<String, int> behaviorWeights; // Behavior -> probability weight
  final int minBlips;
  final int maxBlips;
  final String preferredTerrain;
  final List<String> traits;

  EnemyType({
    required this.id,
    required this.name,
    this.description = '',
    Map<String, int>? stanceWeights,
    Map<String, int>? behaviorWeights,
    this.minBlips = 1,
    this.maxBlips = 4,
    this.preferredTerrain = 'Any',
    List<String>? traits,
  }) : stanceWeights =
           stanceWeights ?? {'Passive': 1, 'Alert': 2, 'Aggressive': 1},
       behaviorWeights =
           behaviorWeights ??
           {'Defend': 2, 'Ambush': 1, 'Hit-and-Run': 1, 'Flank': 1},
       traits = traits ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'stanceWeights': stanceWeights,
    'behaviorWeights': behaviorWeights,
    'minBlips': minBlips,
    'maxBlips': maxBlips,
    'preferredTerrain': preferredTerrain,
    'traits': traits,
  };

  factory EnemyType.fromJson(Map<String, dynamic> json) => EnemyType(
    id: json['id'] ?? '',
    name: json['name'] ?? 'Unknown',
    description: json['description'] ?? '',
    stanceWeights: Map<String, int>.from(json['stanceWeights'] ?? {}),
    behaviorWeights: Map<String, int>.from(json['behaviorWeights'] ?? {}),
    minBlips: json['minBlips'] ?? 1,
    maxBlips: json['maxBlips'] ?? 4,
    preferredTerrain: json['preferredTerrain'] ?? 'Any',
    traits: List<String>.from(json['traits'] ?? []),
  );
}

/// Tactical behavior definition
class TacticalBehavior {
  final String id;
  final String name;
  final String description;
  final List<String> instructions; // Step-by-step player instructions
  final Map<String, dynamic> modifiers; // Game effects

  TacticalBehavior({
    required this.id,
    required this.name,
    this.description = '',
    List<String>? instructions,
    Map<String, dynamic>? modifiers,
  }) : instructions = instructions ?? [],
       modifiers = modifiers ?? {};

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'instructions': instructions,
    'modifiers': modifiers,
  };

  factory TacticalBehavior.fromJson(Map<String, dynamic> json) =>
      TacticalBehavior(
        id: json['id'] ?? '',
        name: json['name'] ?? 'Unknown',
        description: json['description'] ?? '',
        instructions: List<String>.from(json['instructions'] ?? []),
        modifiers: Map<String, dynamic>.from(json['modifiers'] ?? {}),
      );
}

/// Oracle check parameters
class OracleCheck {
  final String location; // Hex or area
  final String? districtId;
  final double insurgentActivity; // Current threat level
  final double localTrust; // Current trust level
  final bool hasIntel; // Intel-driven operation
  final String missionType; // Patrol, Raid, Presence, etc.
  final int teamSize;
  final Map<String, dynamic> modifiers;

  OracleCheck({
    required this.location,
    this.districtId,
    this.insurgentActivity = 50.0,
    this.localTrust = 50.0,
    this.hasIntel = false,
    this.missionType = 'Patrol',
    this.teamSize = 4,
    Map<String, dynamic>? modifiers,
  }) : modifiers = modifiers ?? {};

  Map<String, dynamic> toJson() => {
    'location': location,
    'districtId': districtId,
    'insurgentActivity': insurgentActivity,
    'localTrust': localTrust,
    'hasIntel': hasIntel,
    'missionType': missionType,
    'teamSize': teamSize,
    'modifiers': modifiers,
  };

  factory OracleCheck.fromJson(Map<String, dynamic> json) => OracleCheck(
    location: json['location'] ?? '',
    districtId: json['districtId'],
    insurgentActivity: (json['insurgentActivity'] ?? 50.0).toDouble(),
    localTrust: (json['localTrust'] ?? 50.0).toDouble(),
    hasIntel: json['hasIntel'] ?? false,
    missionType: json['missionType'] ?? 'Patrol',
    teamSize: json['teamSize'] ?? 4,
    modifiers: Map<String, dynamic>.from(json['modifiers'] ?? {}),
  );
}

/// Environmental threat result
class EnvironmentalThreat {
  final String type; // IED, Sniper, Natural Hazard, etc.
  final String description;
  final String severity; // Minor, Moderate, Severe
  final List<String> responseOptions;
  final Map<String, dynamic> effects;

  EnvironmentalThreat({
    required this.type,
    this.description = '',
    this.severity = 'Moderate',
    List<String>? responseOptions,
    Map<String, dynamic>? effects,
  }) : responseOptions = responseOptions ?? [],
       effects = effects ?? {};

  Map<String, dynamic> toJson() => {
    'type': type,
    'description': description,
    'severity': severity,
    'responseOptions': responseOptions,
    'effects': effects,
  };

  factory EnvironmentalThreat.fromJson(Map<String, dynamic> json) =>
      EnvironmentalThreat(
        type: json['type'] ?? 'Unknown',
        description: json['description'] ?? '',
        severity: json['severity'] ?? 'Moderate',
        responseOptions: List<String>.from(json['responseOptions'] ?? []),
        effects: Map<String, dynamic>.from(json['effects'] ?? {}),
      );
}
