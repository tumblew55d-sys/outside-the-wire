// lib/models/rank_ladder.dart

// 1. Define the Services (Branches)
enum ServiceType {
  army,
  navy,
  marines,
}

// 2. Define the Rank Tracks
enum RankTrack {
  enlisted,
  officer,
}

// 3. Data Class to hold Rank Details
class RankDefinition {
  final String title;
  final String abbreviation;
  final int gradeIndex; // 0 = E1/O1, 1 = E2/O2, etc.
  final RankTrack track;

  const RankDefinition({
    required this.title,
    required this.abbreviation,
    required this.gradeIndex,
    required this.track,
  });
}

class RankLadder {
  static const List<RankDefinition> _armyEnlisted = [
    RankDefinition(title: "Private", abbreviation: "PVT", gradeIndex: 0, track: RankTrack.enlisted),
    RankDefinition(title: "Sergeant", abbreviation: "SGT", gradeIndex: 1, track: RankTrack.enlisted),
    RankDefinition(title: "Staff Sergeant", abbreviation: "SSG", gradeIndex: 2, track: RankTrack.enlisted),
    RankDefinition(title: "Sergeant First Class", abbreviation: "SFC", gradeIndex: 3, track: RankTrack.enlisted),
    RankDefinition(title: "Master Sergeant", abbreviation: "MSG", gradeIndex: 4, track: RankTrack.enlisted),
  ];

  static const List<RankDefinition> _armyOfficer = [
    RankDefinition(title: "2nd Lieutenant", abbreviation: "2LT", gradeIndex: 0, track: RankTrack.officer),
    RankDefinition(title: "1st Lieutenant", abbreviation: "1LT", gradeIndex: 1, track: RankTrack.officer),
    RankDefinition(title: "Captain", abbreviation: "CPT", gradeIndex: 2, track: RankTrack.officer),
  ];

  static const List<RankDefinition> _marineEnlisted = [
    RankDefinition(title: "Private", abbreviation: "Pvt", gradeIndex: 0, track: RankTrack.enlisted),
    RankDefinition(title: "Sergeant", abbreviation: "Sgt", gradeIndex: 1, track: RankTrack.enlisted),
    RankDefinition(title: "Staff Sergeant", abbreviation: "SSgt", gradeIndex: 2, track: RankTrack.enlisted),
    RankDefinition(title: "Gunnery Sergeant", abbreviation: "GySgt", gradeIndex: 3, track: RankTrack.enlisted),
    RankDefinition(title: "Master Sergeant", abbreviation: "MSgt", gradeIndex: 4, track: RankTrack.enlisted),
  ];

  static const List<RankDefinition> _marineOfficer = [
    RankDefinition(title: "2nd Lieutenant", abbreviation: "2ndLt", gradeIndex: 0, track: RankTrack.officer),
    RankDefinition(title: "1st Lieutenant", abbreviation: "1stLt", gradeIndex: 1, track: RankTrack.officer),
    RankDefinition(title: "Captain", abbreviation: "Capt", gradeIndex: 2, track: RankTrack.officer),
  ];

  static const List<RankDefinition> _navyEnlisted = [
    RankDefinition(title: "Seaman Recruit", abbreviation: "SR", gradeIndex: 0, track: RankTrack.enlisted),
    RankDefinition(title: "Petty Officer 3rd Class", abbreviation: "PO3", gradeIndex: 1, track: RankTrack.enlisted),
    RankDefinition(title: "Petty Officer 2nd Class", abbreviation: "PO2", gradeIndex: 2, track: RankTrack.enlisted),
    RankDefinition(title: "Petty Officer 1st Class", abbreviation: "PO1", gradeIndex: 3, track: RankTrack.enlisted),
    RankDefinition(title: "Chief Petty Officer", abbreviation: "CPO", gradeIndex: 4, track: RankTrack.enlisted),
  ];

  static const List<RankDefinition> _navyOfficer = [
    RankDefinition(title: "Ensign", abbreviation: "ENS", gradeIndex: 0, track: RankTrack.officer),
    RankDefinition(title: "Lieutenant JG", abbreviation: "LTJG", gradeIndex: 1, track: RankTrack.officer),
    RankDefinition(title: "Lieutenant", abbreviation: "LT", gradeIndex: 2, track: RankTrack.officer),
  ];

  static RankDefinition getInitialRank(ServiceType service, bool isOfficer) {
    if (isOfficer) {
      return _getOfficerList(service).first;
    } else {
      return _getEnlistedList(service).first;
    }
  }

  static RankDefinition getNextRank({required RankDefinition currentRank, required ServiceType service, required int rollResult}) {
    bool isOfficerPromotion = (rollResult == 1);
    bool isStandardPromotion = (rollResult >= 2 && rollResult <= 10);
    List<RankDefinition> targetList;
    if (currentRank.track == RankTrack.enlisted && isOfficerPromotion) {
      return _getOfficerList(service).first;
    }
    if (currentRank.track == RankTrack.officer) {
      targetList = _getOfficerList(service);
    } else {
      targetList = _getEnlistedList(service);
    }
    if (isOfficerPromotion || isStandardPromotion) {
      int nextIndex = currentRank.gradeIndex + 1;
      if (nextIndex < targetList.length) {
        return targetList[nextIndex];
      }
    }
    return currentRank;
  }

  static List<RankDefinition> _getEnlistedList(ServiceType service) {
    switch (service) {
      case ServiceType.army:
        return _armyEnlisted;
      case ServiceType.marines:
        return _marineEnlisted;
      case ServiceType.navy:
        return _navyEnlisted;
    }
  }

  static List<RankDefinition> _getOfficerList(ServiceType service) {
    switch (service) {
      case ServiceType.army:
        return _armyOfficer;
      case ServiceType.marines:
        return _marineOfficer;
      case ServiceType.navy:
        return _navyOfficer;
    }
  }
}
