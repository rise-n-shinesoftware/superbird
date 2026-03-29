import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superbird/game/superbird_game.dart';
import 'package:superbird/models/power_suit.dart';
import 'package:superbird/services/ad_service.dart';
import 'package:superbird/state/game_session_controller.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  static const _adService = AdService();
  SuperbirdGame? _game;
  bool _showGameOver = false;
  bool _showReviveOverlay = false;
  bool _adLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _game ??= SuperbirdGame(
      controller: context.read<GameSessionController>(),
      onGameOver: () {
        if (!mounted) return;
        setState(() {
          _showReviveOverlay = false;
          _showGameOver = true;
        });
      },
      onReviveOffered: () {
        if (!mounted) return;
        setState(() {
          _showReviveOverlay = true;
          _adLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSessionController>();
    final activeSuit = session.activePower;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: GameWidget(game: _game!)),
            Positioned(
              top: 8,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDCEBFF)),
                ),
                child: Row(
                  children: [
                    Text(
                      'Score ${session.score}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    Text('Coins +${session.runCoins}'),
                    const SizedBox(width: 12),
                    if (activeSuit != null) ...[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: suitCatalog[activeSuit]!.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('${suitCatalog[activeSuit]!.label} ${session.powerRemaining.toStringAsFixed(1)}s'),
                    ] else
                      const Text('No power'),
                  ],
                ),
              ),
            ),
            if (_showGameOver)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.45),
                  child: Center(
                    child: Container(
                      width: 280,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Run Complete',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          Text('Score: ${session.score}'),
                          Text('Coins Earned: ${session.runCoins}'),
                          Text('Best: ${session.bestScore}'),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const GameplayScreen()),
                                );
                              },
                              child: const Text('Play Again'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Back to Home'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_showReviveOverlay)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.35),
                  child: Center(
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Second Chance',
                            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Watch a rewarded ad to revive once and continue this run.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF334155)),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _adLoading
                                  ? null
                                  : () async {
                                      setState(() => _adLoading = true);
                                      final rewarded = await _adService.showRewardedReviveAd();
                                      if (!mounted) return;
                                      if (rewarded) {
                                        _game?.reviveAfterAd();
                                        setState(() {
                                          _showReviveOverlay = false;
                                          _adLoading = false;
                                        });
                                      } else {
                                        _game?.finalizeRun();
                                      }
                                    },
                              child: Text(_adLoading ? 'Loading Ad...' : 'Watch Ad & Revive'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _game?.finalizeRun();
                              },
                              child: const Text('No Thanks'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
