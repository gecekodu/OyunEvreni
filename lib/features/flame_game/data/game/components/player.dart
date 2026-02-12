// 🟢 PLAYER COMPONENT - Karakter Bileşeni
// Gravity, Jump, Input'u burada yönetiyoruz

import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../../../domain/entities/game_constants.dart';

class Player extends RectangleComponent with CollisionCallbacks, HasGameRef {
  // ========== PHYSICS STATE ==========
  late double velocityY = 0; // Dikey hız (pixel/sec)
  bool isJumping = false; // Şu anda zıplıyor mu?
  bool isGrounded = false; // Yerde duruyor mu?

  // ========== JUMP TIMING ==========
  double jumpElapsedTime = 0;
  static const double jumpDuration = 0.5; // Zıplamayı gerçekleştirme süresi

  Player()
    : super(
        position: Vector2(
          GameConstants.playerStartX,
          GameConstants.playerStartY,
        ),
        size: Vector2(GameConstants.playerWidth, GameConstants.playerHeight),
        paint: Paint()..color = GameConstants.playerColor,
      );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 🚨 Collision detection ekle
    add(RectangleHitbox(size: size, collisionType: CollisionType.active));

    print('✅ Player loaded: $position');
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 👇 Yerçekimi uygulaması
    _applyGravity(dt);

    // 🎯 Zıplama mekaniklerini güncelle
    _updateJump(dt);

    // 🔒 Sınırları kontrol et
    _clampPosition();
  }

  /// 🌍 Yerçekimi Fiziği
  void _applyGravity(double dt) {
    // Zemin kontrolü: çarpışma olmadığını varsay
    isGrounded = position.y >= gameRef.size.y - GameConstants.playerHeight - 10;

    if (!isJumping) {
      if (!isGrounded) {
        // Havada → gravity uygula
        velocityY += GameConstants.gravity * dt; // v += g * dt
      } else {
        // Yerde → hız sıfırla
        velocityY = 0;
      }
    }

    // Terminal velocity kontrolü
    if (velocityY > GameConstants.maxFallSpeed) {
      velocityY = GameConstants.maxFallSpeed;
    }

    // Konumu güncelle
    position.y += velocityY * dt; // s = v*t
  }

  /// ⬆️ Zıplama Fiziği
  void _updateJump(double dt) {
    if (isJumping) {
      jumpElapsedTime += dt;

      // Zıplama süresi dolmuşsa
      if (jumpElapsedTime >= jumpDuration) {
        isJumping = false;
        jumpElapsedTime = 0;
      } else {
        // Zıplama devamında: upward acceleration
        // Smooth jump curve: ilk başta hızlı, sonra yavaş (parabolic)
        final progress = jumpElapsedTime / jumpDuration;
        final jumpCurve = 1.0 - (progress * progress); // Quadratic easing out

        velocityY = -(GameConstants.jumpForce * jumpCurve);
      }
    }
  }

  /// 🎮 Zıplamayı Tetikle
  void jump() {
    if (isGrounded && !isJumping) {
      isJumping = true;
      jumpElapsedTime = 0;
      velocityY = 0;
      print('✨ Jump! velocityY=$velocityY');
    }
  }

  /// 🔒 Oyun Dünyasının Sınırları
  void _clampPosition() {
    // Sol-Sağ sınırları
    if (position.x < 0) {
      position.x = 0;
      velocityY = 0;
    }
    if (position.x + width > gameRef.size.x) {
      position.x = gameRef.size.x - width;
      velocityY = 0;
    }

    // Alt sınırı (zemin)
    if (position.y + height >= gameRef.size.y) {
      position.y = gameRef.size.y - height;
      velocityY = 0;
      isGrounded = true;
    }

    // Üst sınırı
    if (position.y < 0) {
      position.y = 0;
      velocityY = 0;
    }
  }

  /// 📍 Current Bounding Box (collision içinleri)
  Rect get bounds => Rect.fromLTWH(position.x, position.y, width, height);

  /// 🎨 Debug bilgisi (console)
  void debugPrint() {
    print('''
╔════ PLAYER STATE ════╗
║ Position: (${position.x.toStringAsFixed(1)}, ${position.y.toStringAsFixed(1)})
║ VelocityY: ${velocityY.toStringAsFixed(1)} px/s
║ IsGrounded: $isGrounded
║ IsJumping: $isJumping
║ JumpTime: ${jumpElapsedTime.toStringAsFixed(2)}s
╚══════════════════════╝
''');
  }

  // ========== COLLISION CALLBACKS ==========

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    print('💥 Player collision start!');
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    print('💥 Player collision end');
    super.onCollisionEnd(other);
  }
}
