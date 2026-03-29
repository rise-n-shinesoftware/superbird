import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:superbird/models/leaderboard_entry.dart';

class LeaderboardService {
  static const _playerIdKey = 'player_id';
  static const _localLeaderboardKey = 'local_leaderboard';
  static const _enableCloudKey = 'cloud_enabled';

  String? _playerId;
  bool _cloudEnabled = true;

  String get playerId => _playerId ?? 'player-local';
  bool get cloudEnabled => _cloudEnabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _playerId = prefs.getString(_playerIdKey);
    if (_playerId == null) {
      final randomPart = Random().nextInt(999999).toString().padLeft(6, '0');
      _playerId = 'player-$randomPart';
      await prefs.setString(_playerIdKey, _playerId!);
    }
    _cloudEnabled = prefs.getBool(_enableCloudKey) ?? true;
  }

  Future<void> setCloudEnabled(bool enabled) async {
    _cloudEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enableCloudKey, enabled);
  }

  Future<void> submitScore(int score) async {
    final now = DateTime.now();
    final local = await _loadLocal();
    final existingIndex = local.indexWhere((e) => e.playerId == playerId);
    if (existingIndex >= 0) {
      final previous = local[existingIndex];
      if (score > previous.score) {
        local[existingIndex] = LeaderboardEntry(
          playerId: playerId,
          score: score,
          updatedAt: now,
        );
      }
    } else {
      local.add(LeaderboardEntry(playerId: playerId, score: score, updatedAt: now));
    }
    await _saveLocal(local);

    if (!_cloudEnabled) return;
    try {
      await FirebaseFirestore.instance.collection('leaderboard').doc(playerId).set({
        'playerId': playerId,
        'score': score,
        'updatedAt': now.toIso8601String(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Offline/fallback path intentionally ignored.
    }
  }

  Future<List<LeaderboardEntry>> fetchTopScores({int limit = 10}) async {
    final local = await _loadLocal();
    local.sort((a, b) => b.score.compareTo(a.score));
    List<LeaderboardEntry> result = local.take(limit).toList();

    if (_cloudEnabled) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('leaderboard')
            .orderBy('score', descending: true)
            .limit(limit)
            .get();
        final cloud = snapshot.docs
            .map((d) => LeaderboardEntry.fromJson(d.data()))
            .toList();
        if (cloud.isNotEmpty) {
          result = cloud;
        }
      } catch (_) {
        // Falls back to local leaderboard.
      }
    }
    return result;
  }

  Future<List<LeaderboardEntry>> _loadLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localLeaderboardKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List<dynamic>)
        .map((item) => LeaderboardEntry.fromJson(item as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<void> _saveLocal(List<LeaderboardEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = entries.map((entry) => entry.toJson()).toList();
    await prefs.setString(_localLeaderboardKey, jsonEncode(payload));
  }
}
