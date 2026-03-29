import 'package:flutter/material.dart';

enum SuitType { red, blue, green, yellow, purple, black }

class SuitDefinition {
  const SuitDefinition({
    required this.type,
    required this.label,
    required this.color,
    required this.durationSeconds,
    required this.cooldownSeconds,
    required this.unlockCost,
    required this.vfxLabel,
    required this.balanceNote,
  });

  final SuitType type;
  final String label;
  final Color color;
  final double durationSeconds;
  final double cooldownSeconds;
  final int unlockCost;
  final String vfxLabel;
  final String balanceNote;
}

const Map<SuitType, SuitDefinition> suitCatalog = {
  SuitType.red: SuitDefinition(
    type: SuitType.red,
    label: 'Red Burst',
    color: Color(0xFFEF4444),
    durationSeconds: 2.2,
    cooldownSeconds: 8,
    unlockCost: 0,
    vfxLabel: 'Flame trail + speed lines',
    balanceNote: 'High burst but steeper control drift while active.',
  ),
  SuitType.blue: SuitDefinition(
    type: SuitType.blue,
    label: 'Blue Slowmo',
    color: Color(0xFF2563EB),
    durationSeconds: 3.5,
    cooldownSeconds: 10,
    unlockCost: 250,
    vfxLabel: 'Ripple pulse + desaturated obstacles',
    balanceNote: 'World slows, but score gain rate is slightly reduced.',
  ),
  SuitType.green: SuitDefinition(
    type: SuitType.green,
    label: 'Green Shield',
    color: Color(0xFF22C55E),
    durationSeconds: 6,
    cooldownSeconds: 12,
    unlockCost: 350,
    vfxLabel: 'Glowing ring around the bird',
    balanceNote: 'Absorbs only one collision then expires instantly.',
  ),
  SuitType.yellow: SuitDefinition(
    type: SuitType.yellow,
    label: 'Yellow Multiplier',
    color: Color(0xFFEAB308),
    durationSeconds: 5,
    cooldownSeconds: 12,
    unlockCost: 500,
    vfxLabel: 'Spark particles + score popups',
    balanceNote: 'Double score only, no safety benefits.',
  ),
  SuitType.purple: SuitDefinition(
    type: SuitType.purple,
    label: 'Purple Blink',
    color: Color(0xFFA855F7),
    durationSeconds: 1.4,
    cooldownSeconds: 9,
    unlockCost: 650,
    vfxLabel: 'Afterimage ghost + short warp flash',
    balanceNote: 'Teleport is short; mistimed use can still hit pipe edge.',
  ),
  SuitType.black: SuitDefinition(
    type: SuitType.black,
    label: 'Black Phase',
    color: Color(0xFF111827),
    durationSeconds: 2.8,
    cooldownSeconds: 14,
    unlockCost: 900,
    vfxLabel: 'Shadow overlay + obstacle fade-through',
    balanceNote: 'Brief invulnerability, longest cooldown in game.',
  ),
};
