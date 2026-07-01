/// Model for tracking progress through weekly turn phases
class WeeklyTurnPhaseData {
  int currentPhase; // 1-5
  int currentStep; // 1-12
  Map<String, dynamic> phaseResults;
  DateTime startedAt;

  // Phase 1: Briefing & Preparation
  int? allocatedSupportPoints;
  List<String>? assignedCharacterIds;

  // Phase 2: Mission Planning
  String? selectedDistrict;
  String? location;
  String? missionType;
  int? teamSize;

  // Phase 3: Encounter Resolution
  String? contactId;
  String? oracleOutcome;
  Map<String, dynamic>? enemyForce;

  // Phase 4: AAR
  String? outcome;
  int? enemyCasualties;
  int? friendlyCasualties;
  Map<String, double>? trackChanges;
  List<String>? lessonsLearned;

  // Phase 5: Week Wrap-up
  bool? weekAdvanced;

  WeeklyTurnPhaseData({
    this.currentPhase = 1,
    this.currentStep = 1,
    Map<String, dynamic>? phaseResults,
    DateTime? startedAt,
    this.allocatedSupportPoints,
    this.assignedCharacterIds,
    this.selectedDistrict,
    this.location,
    this.missionType,
    this.teamSize,
    this.contactId,
    this.oracleOutcome,
    this.enemyForce,
    this.outcome,
    this.enemyCasualties,
    this.friendlyCasualties,
    this.trackChanges,
    this.lessonsLearned,
    this.weekAdvanced,
  }) : phaseResults = phaseResults ?? {},
       startedAt = startedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'currentPhase': currentPhase,
    'currentStep': currentStep,
    'phaseResults': phaseResults,
    'startedAt': startedAt.toIso8601String(),
    'allocatedSupportPoints': allocatedSupportPoints,
    'assignedCharacterIds': assignedCharacterIds,
    'selectedDistrict': selectedDistrict,
    'location': location,
    'missionType': missionType,
    'teamSize': teamSize,
    'contactId': contactId,
    'oracleOutcome': oracleOutcome,
    'enemyForce': enemyForce,
    'outcome': outcome,
    'enemyCasualties': enemyCasualties,
    'friendlyCasualties': friendlyCasualties,
    'trackChanges': trackChanges,
    'lessonsLearned': lessonsLearned,
    'weekAdvanced': weekAdvanced,
  };

  factory WeeklyTurnPhaseData.fromJson(Map<String, dynamic> json) =>
      WeeklyTurnPhaseData(
        currentPhase: json['currentPhase'] ?? 1,
        currentStep: json['currentStep'] ?? 1,
        phaseResults: json['phaseResults'] ?? {},
        startedAt: DateTime.parse(
          json['startedAt'] ?? DateTime.now().toIso8601String(),
        ),
        allocatedSupportPoints: json['allocatedSupportPoints'],
        assignedCharacterIds: json['assignedCharacterIds'] != null
            ? List<String>.from(json['assignedCharacterIds'])
            : null,
        selectedDistrict: json['selectedDistrict'],
        location: json['location'],
        missionType: json['missionType'],
        teamSize: json['teamSize'],
        contactId: json['contactId'],
        oracleOutcome: json['oracleOutcome'],
        enemyForce: json['enemyForce'],
        outcome: json['outcome'],
        enemyCasualties: json['enemyCasualties'],
        friendlyCasualties: json['friendlyCasualties'],
        trackChanges: json['trackChanges'] != null
            ? Map<String, double>.from(json['trackChanges'])
            : null,
        lessonsLearned: json['lessonsLearned'] != null
            ? List<String>.from(json['lessonsLearned'])
            : null,
        weekAdvanced: json['weekAdvanced'],
      );

  String getPhaseTitle() {
    switch (currentPhase) {
      case 1:
        return 'PHASE 1: BRIEFING & PREPARATION';
      case 2:
        return 'PHASE 2: MISSION PLANNING';
      case 3:
        return 'PHASE 3: ENCOUNTER RESOLUTION';
      case 4:
        return 'PHASE 4: AFTER ACTION REVIEW';
      case 5:
        return 'PHASE 5: WEEK WRAP-UP';
      default:
        return 'UNKNOWN PHASE';
    }
  }

  String getStepDescription() {
    switch (currentStep) {
      case 1:
        return 'Week Summary Review';
      case 2:
        return 'District Assessment';
      case 3:
        return 'Intel Lead Display';
      case 4:
        return 'Mission Setup';
      case 5:
        return 'District Selection';
      case 6:
        return 'Location Assignment';
      case 7:
        return 'Mission Type Choice';
      case 8:
        return 'Team Composition';
      case 9:
        return 'Oracle Trigger';
      case 10:
        return 'Contact Resolution';
      case 11:
        return 'AAR Documentation';
      case 12:
        return 'State Persistence';
      default:
        return 'Unknown Step';
    }
  }

  bool isPhaseComplete(int phase) {
    switch (phase) {
      case 1:
        return allocatedSupportPoints != null && assignedCharacterIds != null;
      case 2:
        return selectedDistrict != null &&
            missionType != null &&
            teamSize != null;
      case 3:
        return contactId != null && oracleOutcome != null;
      case 4:
        return outcome != null && trackChanges != null;
      case 5:
        return weekAdvanced == true;
      default:
        return false;
    }
  }
}
