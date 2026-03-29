import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superbird/models/leaderboard_entry.dart';
import 'package:superbird/models/power_suit.dart';
import 'package:superbird/services/leaderboard_service.dart';

class GameSessionController extends ChangeNotifier {
  static const _coinsKey = 'coins';
  static const _bestScoreKey = 'best_score';
  static const _selectedSuitKey = 'selected_suit';
  static const _unlockedSuitsKey = 'unlocked_suits';
  static const _lastDailyClaimKey = 'last_daily_claim';

  int coins = 0;
  int runCoins = 0;
  int score = 0;
  int bestScore = 0;
  SuitType selectedSuit = SuitType.red;
  Set<SuitType> unlockedSuits = {SuitType.red};
  SuitType? activePower;
  double powerRemaining = 0;
  bool shieldAvailable = false;
  bool phaseActive = false;
  DateTime? lastDailyClaim;
  final LeaderboardService leaderboardService = LeaderboardService();
  List<LeaderboardEntry> leaderboard = const [];
  bool cloudSyncEnabled = true;

  Future<void> load() async {
    await leaderboardService.init();
    cloudSyncEnabled = leaderboardService.cloudEnabled;

    final prefs = await SharedPreferences.getInstance();
    coins = prefs.getInt(_coinsKey) ?? 0;
    bestScore = prefs.getInt(_bestScoreKey) ?? 0;

    final rawSuit = prefs.getString(_selectedSuitKey);
    selectedSuit = SuitType.values.firstWhere(
      (s) => s.name == rawSuit,
      orElse: () => SuitType.red,
    );

    final unlockedRaw = prefs.getStringList(_unlockedSuitsKey) ?? <String>['red'];
    unlockedSuits = unlockedRaw
        .map(
          (name) => SuitType.values.firstWhere(
            (s) => s.name == name,
            orElse: () => SuitType.red,
          ),
        )
        .toSet();
    unlockedSuits.add(SuitType.red);

    final rawDaily = prefs.getString(_lastDailyClaimKey);
    if (rawDaily != null) {
      lastDailyClaim = DateTime.tryParse(rawDaily);
    }

    leaderboard = await leaderboardService.fetchTopScores();
    notifyListeners();
  }

  Future<void> refreshLeaderboard() async {
    leaderboard = await leaderboardService.fetchTopScores();
    notifyListeners();
  }

  Future<void> setCloudSync(bool enabled) async {
    cloudSyncEnabled = enabled;
    await leaderboardService.setCloudEnabled(enabled);
    await refreshLeaderboard();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
    await prefs.setInt(_bestScoreKey, bestScore);
    await prefs.setString(_selectedSuitKey, selectedSuit.name);
    await prefs.setStringList(
      _unlockedSuitsKey,
      unlockedSuits.map((s) => s.name).toList(),
    );
    if (lastDailyClaim != null) {
      await prefs.setString(_lastDailyClaimKey, lastDailyClaim!.toIso8601String());
    }
  }

  bool get canClaimDaily {
    if (lastDailyClaim == null) return true;
    return DateTime.now().difference(lastDailyClaim!).inHours >= 24;
  }

  Future<int> claimDailyReward() async {
    if (!canClaimDaily) return 0;
    const reward = 100;
    coins += reward;
    lastDailyClaim = DateTime.now();
    await _save();
    notifyListeners();
    return reward;
  }

  Future<bool> unlockSuit(SuitType suit) async {
    if (unlockedSuits.contains(suit)) return true;
    final definition = suitCatalog[suit]!;
    if (coins < definition.unlockCost) return false;
    coins -= definition.unlockCost;
    unlockedSuits.add(suit);
    await _save();
    notifyListeners();
    return true;
  }

  Future<void> setSelectedSuit(SuitType suit) async {
    if (!unlockedSuits.contains(suit)) return;
    selectedSuit = suit;
    await _save();
    notifyListeners();
  }

  void startRun() {
    score = 0;
    runCoins = 0;
    activePower = null;
    powerRemaining = 0;
    shieldAvailable = false;
    phaseActive = false;
    notifyListeners();
  }

  void setScore(int value) {
    score = value;
    if (score > bestScore) {
      bestScore = score;
    }
    notifyListeners();
  }

  void addCoinsInRun(int amount) {
    runCoins += amount;
    notifyListeners();
  }

  void setPowerState({
    required SuitType? active,
    required double remaining,
    required bool shield,
    required bool phase,
  }) {
    activePower = active;
    powerRemaining = remaining;
    shieldAvailable = shield;
    phaseActive = phase;
    notifyListeners();
  }

  Future<void> completeRun() async {
    coins += runCoins;
    if (score > bestScore) {
      bestScore = score;
    }
    await leaderboardService.submitScore(score);
    leaderboard = await leaderboardService.fetchTopScores();
    await _save();
    notifyListeners();
  }
}
