import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:superbird/models/power_suit.dart';

class PowerPickupComponent extends SpriteComponent with CollisionCallbacks {
  PowerPickupComponent({
    required this.suitType,
    required Vector2 position,
    required this.speedProvider,
  }) : super(
          position: position,
          size: Vector2(28, 28), // Adjust size based on your sprite
          anchor: Anchor.center,
        );

  final SuitType suitType;
  final double Function() speedProvider;

  @override
  Future<void> onLoad() async {
    final spriteName = _getSpriteName(suitType);
    sprite = await Sprite.load(spriteName);
    add(RectangleHitbox());
  }

  String _getSpriteName(SuitType suitType) {
    switch (suitType) {
      case SuitType.red:
        return 'power_red.png';
      case SuitType.blue:
        return 'power_blue.png';
      case SuitType.green:
        return 'power_green.png';
      case SuitType.yellow:
        return 'power_yellow.png';
      case SuitType.purple:
        return 'power_purple.png';
      case SuitType.black:
        return 'power_black.png';
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speedProvider() * dt;
    if (position.x + size.x / 2 < -10) {
      removeFromParent();
    }
  }
}
