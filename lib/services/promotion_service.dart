import '../data/nationality_data.dart';

/// Rank progression rules shared by the Deployments screen (and tests).
class PromotionService {
  static List<String> rankLadder(
    String nationality,
    String service,
    bool isOfficer,
  ) {
    final isNavy = service == 'Navy';
    if (isOfficer) {
      return (isNavy
          ? NationalityData.getNavyOfficerRanks(nationality)
          : NationalityData.getOfficerRanks(nationality))['ranks']!;
    }
    return (isNavy
        ? NationalityData.getNavyEnlistedRanks(nationality)
        : NationalityData.getEnlistedRanks(nationality))['ranks']!;
  }

  /// A battlefield commission only makes sense for enlisted characters.
  /// An officer who rolls it receives a normal one-rank promotion instead.
  static ({bool officer, bool sergeant}) normalizeCareerPromotion({
    required bool officerPromotion,
    required bool sergeantPromotion,
    required String rankType,
  }) {
    if (officerPromotion && rankType == 'Officer') {
      return (officer: false, sergeant: true);
    }
    return (officer: officerPromotion, sergeant: sergeantPromotion);
  }

  static String promotedRank({
    required String currentRank,
    required String rankType,
    required String service,
    required String nationality,
    bool officerPromotion = false,
    bool sergeantPromotion = false,
    bool sofPromotion = false,
    bool agentPromotion = false,
  }) {
    final isOfficer = rankType == 'Officer';
    final ranks = rankLadder(nationality, service, isOfficer);

    final currentIndex = ranks.indexOf(currentRank);
    if (currentIndex == -1) return currentRank;

    String nextOfficerRank() =>
        currentIndex < ranks.length - 1 ? ranks[currentIndex + 1] : currentRank;

    String enlistedFloor(int floorIndex) {
      final targetIndex = currentIndex < floorIndex
          ? floorIndex
          : currentIndex + 1;
      // At the top of the ladder stay put instead of wrapping back down
      return targetIndex < ranks.length ? ranks[targetIndex] : currentRank;
    }

    if (agentPromotion) {
      return isOfficer ? nextOfficerRank() : enlistedFloor(5);
    }
    if (sofPromotion) {
      return isOfficer ? nextOfficerRank() : enlistedFloor(4);
    }
    if (officerPromotion && !isOfficer) {
      return rankLadder(nationality, service, true).first;
    }
    if (sergeantPromotion) {
      return isOfficer ? nextOfficerRank() : enlistedFloor(4);
    }
    return currentRank;
  }
}
