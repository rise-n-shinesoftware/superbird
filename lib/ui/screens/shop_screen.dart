import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superbird/models/power_suit.dart';
import 'package:superbird/state/game_session_controller.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<GameSessionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suit Shop'),
        backgroundColor: const Color(0xFFF6FAFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coins: ${session.coins}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: SuitType.values.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final suit = SuitType.values[index];
                  final def = suitCatalog[suit]!;
                  final unlocked = session.unlockedSuits.contains(suit);
                  final equipped = session.selectedSuit == suit;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDCEBFF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: def.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              def.label,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const Spacer(),
                            if (equipped)
                              const Text(
                                'Equipped',
                                style: TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Duration ${def.durationSeconds}s | Cooldown ${def.cooldownSeconds}s',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'VFX: ${def.vfxLabel}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          def.balanceNote,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 10),
                        if (!unlocked)
                          SizedBox(
                            width: 160,
                            child: FilledButton.tonal(
                              onPressed: () async {
                                final ok = await session.unlockSuit(suit);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok
                                          ? '${def.label} unlocked!'
                                          : 'Not enough coins for ${def.label}',
                                    ),
                                  ),
                                );
                              },
                              child: Text('Unlock ${def.unlockCost}'),
                            ),
                          )
                        else if (!equipped)
                          SizedBox(
                            width: 120,
                            child: OutlinedButton(
                              onPressed: () => session.setSelectedSuit(suit),
                              child: const Text('Equip'),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
