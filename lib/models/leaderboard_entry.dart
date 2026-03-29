class LeaderboardEntry {
  const LeaderboardEntry({
    required this.playerId,
    required this.score,
    required this.updatedAt,
  });

  final String playerId;
  final int score;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'score': score,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    final rawUpdatedAt = json['updatedAt'];
    final parsedUpdatedAt = rawUpdatedAt is String
        ? DateTime.tryParse(rawUpdatedAt)
        : DateTime.tryParse(rawUpdatedAt?.toString() ?? '');
    return LeaderboardEntry(
      playerId: json['playerId'] as String? ?? 'unknown',
      score: (json['score'] as num?)?.toInt() ?? 0,
      updatedAt: parsedUpdatedAt ?? DateTime.now(),
    );
  }
}
