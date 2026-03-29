import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class ObstaclePairComponent extends PositionComponent {
  ObstaclePairComponent({
    required this.startX,
    required this.gapCenterY,
    required this.gapHeight,
    required this.worldHeight,
    required this.speedProvider,
    required this.onPassed,
  }) : super(position: Vector2(startX, 0), anchor: Anchor.topLeft);

  final double startX;
  final double gapCenterY;
  final double gapHeight;
  final double worldHeight;
  final double Function() speedProvider;
  final void Function() onPassed;

  static const obstacleWidth = 72.0;
  bool _scored = false;

  @override
  Future<void> onLoad() async {
    size = Vector2(obstacleWidth, worldHeight);

    final topHeight = gapCenterY - (gapHeight / 2);
    final bottomY = gapCenterY + (gapHeight / 2);
    final bottomHeight = worldHeight - bottomY;

    final top = RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(obstacleWidth, topHeight),
      paint: Paint()..color = const Color(0xFF0F172A),
    )..add(RectangleHitbox());

    final bottom = RectangleComponent(
      position: Vector2(0, bottomY),
      size: Vector2(obstacleWidth, bottomHeight),
      paint: Paint()..color = const Color(0xFF0F172A),
    )..add(RectangleHitbox());

    addAll([top, bottom]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speedProvider() * dt;
    if (!_scored && position.x + obstacleWidth < 120) {
      _scored = true;
      onPassed();
    }

    if (position.x + obstacleWidth < -8) {
      removeFromParent();
    }
  }
}
