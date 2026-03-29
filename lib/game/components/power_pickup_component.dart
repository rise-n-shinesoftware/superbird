import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:superbird/models/power_suit.dart';

class PowerPickupComponent extends CircleComponent with CollisionCallbacks {
  PowerPickupComponent({
    required this.suitType,
    required Vector2 position,
    required this.speedProvider,
  }) : super(
          radius: 14,
          position: position,
          anchor: Anchor.center,
          paint: Paint()..color = suitCatalog[suitType]!.color,
        );

  final SuitType suitType;
  final double Function() speedProvider;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speedProvider() * dt;
    if (position.x + radius < -10) {
      removeFromParent();
    }
  }
}
