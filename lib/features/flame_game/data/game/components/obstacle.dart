// 🚧 OBSTACLE COMPONENT - Engel Bileşeni
// Sağdan sola doğru hareket eden kırmızı kutular

import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../../../domain/entities/game_constants.dart';
import 'player.dart';

class Obstacle extends RectangleComponent with CollisionCallbacks, HasGameRef {
  // ========== MOVEMENT STATE ==========
  bool isPassed = false; // Oyuncuyu geçip geçmediğini izle (score için)

  Obstacle({required Vector2 position})
    : super(
        position: position,
        size: Vector2(
          GameConstants.obstacleWidth,
          GameConstants.obstacleHeight,
        ),
        paint: Paint()..color = GameConstants.obstacleColor,
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 🚨 Collision detection ekle
    add(RectangleHitbox(size: size, collisionType: CollisionType.passive));

    print('✅ Obstacle spawned at x=${position.x}');
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ⬅️ Sağdan sola hareket
    position.x -= GameConstants.obstacleSpeed * dt;

    // 🗑️ Ekrandan çıkıp giterse kaldır
    if (position.x + width < 0) {
      removeFromParent();
      print('🗑️ Obstacle removed (off-screen)');
    }

    // ✅ Oyuncuyu geçip geçmediğini kontrol et (score artırma)
    if (!isPassed) {
      final playerRef = gameRef.children.whereType<Player>().firstOrNull;

      if (playerRef != null && position.x < playerRef.position.x) {
        isPassed = true;
        print('📊 Obstacle passed! Score +1');

        // Score event'i gönder (main_game.dart'tan yakalansın)
        // Later: Event bus kullanabiliriz
      }
    }
  }

  /// 📍 Current Bounding Box
  Rect get bounds => Rect.fromLTWH(position.x, position.y, width, height);

  // ========== COLLISION CALLBACKS ==========

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    print('💥 Obstacle collision start!');
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    print('💥 Obstacle collision end');
    super.onCollisionEnd(other);
  }
}
