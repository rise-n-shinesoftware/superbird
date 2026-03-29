import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:superbird/game/components/bird_component.dart';
import 'package:superbird/game/components/obstacle_pair_component.dart';
import 'package:superbird/game/components/power_pickup_component.dart';
import 'package:superbird/models/power_suit.dart';
import 'package:superbird/state/game_session_controller.dart';

class SuperbirdGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  SuperbirdGame({
    required this.controller,
    required this.onGameOver,
    required this.onReviveOffered,
  });

  final GameSessionController controller;
  final VoidCallback onGameOver;
  final VoidCallback onReviveOffered;
  final Random _random = Random();

  late BirdComponent bird;
  double scoreValue = 0;
  double baseObstacleSpeed = 180;
  double baseGapHeight = 210;
  double spawnTimer = 0;
  bool running = true;
  bool reviveUsed = false;
  double _vfxTimer = 0;

  SuitType? activeSuit;
  double activePowerRemaining = 0;
  bool shieldActive = false;
  bool phaseActive = false;
  final Map<SuitType, double> _cooldownRemaining = {
    for (final suit in SuitType.values) suit: 0,
  };

  double get worldSpeedFactor {
    if (activeSuit == SuitType.blue) return 0.58;
    if (activeSuit == SuitType.red) return 1.45;
    return 1;
  }

  double get scoreFactor {
    if (activeSuit == SuitType.yellow) return 2;
    if (activeSuit == SuitType.blue) return 0.85;
    return 1;
  }

  double get obstacleSpeed => (baseObstacleSpeed + (scoreValue * 0.25)) * worldSpeedFactor;

  @override
  Color backgroundColor() => const Color(0xFFEFF6FF);

  @override
  Future<void> onLoad() async {
    controller.startRun();

    add(
      RectangleComponent(
        position: Vector2(0, size.y - 38),
        size: Vector2(size.x, 38),
        paint: Paint()..color = const Color(0xFFBFDBFE),
      ),
    );

    bird = BirdComponent(
      position: Vector2(120, size.y * 0.45),
      onObstacleCollision: _handleBirdCollision,
      onPowerPickup: _applyPowerPickup,
    );
    await add(bird);
    _spawnObstacleCluster();
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (running) {
      bird.flap();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!running) return;

    scoreValue += dt * 10 * scoreFactor;
    controller.setScore(scoreValue.floor());

    spawnTimer -= dt;
    if (spawnTimer <= 0) {
      _spawnObstacleCluster();
    }

    if (bird.position.y < -10 || bird.position.y > size.y - 40) {
      _handleBirdCollision();
    }

    _updatePowerState(dt);
    _emitPowerVfx(dt);
    controller.setPowerState(
      active: activeSuit,
      remaining: activePowerRemaining,
      shield: shieldActive,
      phase: phaseActive,
    );
  }

  void _emitPowerVfx(double dt) {
    _vfxTimer -= dt;
    if (_vfxTimer > 0) return;
    _vfxTimer = 0.08;
    if (activeSuit == null) return;

    final definition = suitCatalog[activeSuit]!;
    final color = definition.color.withOpacity(0.75);
    final count = activeSuit == SuitType.black ? 10 : 6;
    final velocityScale = activeSuit == SuitType.red ? 120.0 : 70.0;

    add(
      ParticleSystemComponent(
        position: bird.position.clone(),
        particle: Particle.generate(
          count: count,
          lifespan: 0.42,
          generator: (index) {
            final angle = _random.nextDouble() * pi * 2;
            final speed = 20 + _random.nextDouble() * velocityScale;
            return AcceleratedParticle(
              acceleration: Vector2(0, 25),
              speed: Vector2(cos(angle) * speed, sin(angle) * speed),
              child: CircleParticle(
                radius: activeSuit == SuitType.black ? 2.2 : 1.7,
                paint: Paint()..color = color,
              ),
            );
          },
        ),
      ),
    );
  }

  void _updatePowerState(double dt) {
    for (final suit in SuitType.values) {
      final remaining = (_cooldownRemaining[suit] ?? 0) - dt;
      _cooldownRemaining[suit] = remaining > 0 ? remaining : 0;
    }

    if (activeSuit != null) {
      activePowerRemaining -= dt;
      if (activePowerRemaining <= 0) {
        activePowerRemaining = 0;
        activeSuit = null;
        shieldActive = false;
        phaseActive = false;
      }
    }
  }

  void _spawnObstacleCluster() {
    final difficulty = min(scoreValue / 220, 1.0);
    final gapHeight = baseGapHeight - (difficulty * 42);
    final safeTop = 90.0;
    final safeBottom = size.y - 140;
    final gapCenter = safeTop + _random.nextDouble() * (safeBottom - safeTop);
    final x = size.x + 30;

    add(
      ObstaclePairComponent(
        startX: x,
        gapCenterY: gapCenter,
        gapHeight: gapHeight,
        worldHeight: size.y - 38,
        speedProvider: () => obstacleSpeed,
        onPassed: () {
          controller.addCoinsInRun(1);
        },
      ),
    );

    final spawnChance = 0.35 + (difficulty * 0.2);
    if (_random.nextDouble() < spawnChance) {
      final suitPool = controller.unlockedSuits.toList();
      final suit = suitPool[_random.nextInt(suitPool.length)];
      final pickupY = gapCenter + ((_random.nextDouble() - 0.5) * min(80, gapHeight - 50));
      add(
        PowerPickupComponent(
          suitType: suit,
          position: Vector2(x + 90, pickupY),
          speedProvider: () => obstacleSpeed,
        ),
      );
    }

    spawnTimer = max(1.05, 1.55 - (difficulty * 0.3));
  }

  void _applyPowerPickup(PowerPickupComponent pickup) {
    if (!running) return;
    final suit = pickup.suitType;
    final def = suitCatalog[suit]!;

    if ((_cooldownRemaining[suit] ?? 0) > 0) {
      controller.addCoinsInRun(2);
      pickup.removeFromParent();
      return;
    }

    activeSuit = suit;
    activePowerRemaining = def.durationSeconds;
    _cooldownRemaining[suit] = def.cooldownSeconds;

    shieldActive = suit == SuitType.green;
    phaseActive = suit == SuitType.black;

    if (suit == SuitType.purple) {
      bird.position.y = max(60, bird.position.y - 70);
      bird.position.x = min(size.x * 0.45, bird.position.x + 38);
    }

    if (suit == SuitType.red) {
      bird.position.x = min(size.x * 0.5, bird.position.x + 24);
    }

    pickup.removeFromParent();
  }

  void _handleBirdCollision() {
    if (!running) return;

    if (phaseActive) {
      return;
    }

    if (shieldActive) {
      shieldActive = false;
      activeSuit = null;
      activePowerRemaining = 0;
      return;
    }

    if (!reviveUsed) {
      running = false;
      pauseEngine();
      onReviveOffered();
      return;
    }

    running = false;
    pauseEngine();
    controller.completeRun();
    onGameOver();
  }

  void reviveAfterAd() {
    if (running || reviveUsed) return;
    reviveUsed = true;
    activeSuit = null;
    activePowerRemaining = 0;
    shieldActive = false;
    phaseActive = false;
    bird.reset(Vector2(120, size.y * 0.45));

    final obstacles = children.whereType<ObstaclePairComponent>().toList();
    for (final obstacle in obstacles) {
      obstacle.removeFromParent();
    }
    final pickups = children.whereType<PowerPickupComponent>().toList();
    for (final pickup in pickups) {
      pickup.removeFromParent();
    }

    spawnTimer = 0.4;
    running = true;
    resumeEngine();
  }

  void finalizeRun() {
    if (running) return;
    controller.completeRun();
    onGameOver();
  }
}
