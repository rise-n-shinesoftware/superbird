import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superbird/models/power_suit.dart';
import 'package:superbird/state/game_session_controller.dart';
import 'package:superbird/ui/screens/gameplay_screen.dart';
import 'package:superbird/ui/widgets/stat_chip.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSessionController>();
    final selected = suitCatalog[session.selectedSuit]!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Superbird',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Flap through pipes and chain suit powers for high scores.',
                style: TextStyle(fontSize: 15, color: Color(0xFF334155)),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: StatChip(label: 'Coins', value: '${session.coins}')),
                  const SizedBox(width: 10),
                  Expanded(child: StatChip(label: 'Best Score', value: '${session.bestScore}')),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCEBFF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Equipped Suit: ${selected.label}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Power: ${selected.vfxLabel}',
                      style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duration ${selected.durationSeconds}s | Cooldown ${selected.cooldownSeconds}s',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GameplayScreen()),
                    );
                  },
                  child: const Text('Start Run'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () => Navigator.of(context).pushNamed('/shop'),
                  child: const Text('Suit Shop'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: session.canClaimDaily
                      ? () async {
                          final reward = await session.claimDailyReward();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Daily reward claimed: +$reward coins')),
                          );
                        }
                      : null,
                  child: Text(session.canClaimDaily ? 'Claim Daily Reward' : 'Daily Reward Claimed'),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDCEBFF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Leaderboard',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        const Spacer(),
                        const Text(
                          'Cloud Sync',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        Switch(
                          value: session.cloudSyncEnabled,
                          onChanged: (v) => session.setCloudSync(v),
                        ),
                      ],
                    ),
                    if (session.leaderboard.isEmpty)
                      const Text(
                        'No scores yet. Start a run to create the first record.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      )
                    else
                      ...session.leaderboard.take(5).toList().asMap().entries.map((entry) {
                        final rank = entry.key + 1;
                        final scoreEntry = entry.value;
                        final isSelf = scoreEntry.playerId == session.leaderboardService.playerId;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 26,
                                child: Text(
                                  '#$rank',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  isSelf ? 'You' : scoreEntry.playerId,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                '${scoreEntry.score}',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                        );
                      }),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => session.refreshLeaderboard(),
                        child: const Text('Refresh'),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Tip: Collect powers in risky pipe gaps to maximize score and coins.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
