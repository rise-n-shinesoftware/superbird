import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:superbird/game/components/obstacle_pair_component.dart';
import 'package:superbird/game/components/power_pickup_component.dart';

class BirdComponent extends SpriteComponent with CollisionCallbacks {
  BirdComponent({
    required Vector2 position,
    required this.onObstacleCollision,
    required this.onPowerPickup,
  })
      : velocityY = 0,
        super(
          position: position,
          size: Vector2(32, 32), // Adjust size based on your sprite
          anchor: Anchor.center,
        );

  final VoidCallback onObstacleCollision;
  final void Function(PowerPickupComponent pickup) onPowerPickup;
  double velocityY;
  static const gravity = 980.0;
  static const flapVelocity = -300.0;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('bird.png');
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    velocityY += gravity * dt;
    position.y += velocityY * dt;
  }

  void flap() {
    velocityY = flapVelocity;
    // Optional: Switch to flap animation sprite
    // sprite = await Sprite.load('bird_flap.png');
  }

  void reset(Vector2 startPosition) {
    position.setFrom(startPosition);
    velocityY = 0;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other.parent is ObstaclePairComponent || other is RectangleHitbox) {
      onObstacleCollision();
      return;
    }
    if (other.parent is PowerPickupComponent) {
      onPowerPickup(other.parent! as PowerPickupComponent);
    }
  }
}
