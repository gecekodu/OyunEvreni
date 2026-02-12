// 💥 COLLISION SERVICE - Çarpışma Deteksiyonu (Enterprise Pattern)
// Bu servis, basit rectangle-rectangle çarpışmaların ötesine geçer

import 'dart:math';
import 'package:flutter/material.dart';

/// 🎯 Çarpışma Sonucu
class CollisionResult {
  final bool isColliding;
  final Vector2? collisionPoint;
  final String? collidingWith;

  CollisionResult({
    required this.isColliding,
    this.collisionPoint,
    this.collidingWith,
  });
}

/// 💥 Collision Service
class CollisionService {
  /// Rect-Rect çarpışma kontrolü (AABB - Axis Aligned Bounding Box)
  static bool checkRectCollision(Rect rect1, Rect rect2) {
    return rect1.overlaps(rect2);
  }

  /// Rect-Circle çarpışma (advanced)
  static bool checkCircleRectCollision(
    Offset circleCenter,
    double circleRadius,
    Rect rect,
  ) {
    // En yakın noktayı rect içinde bul
    final closestX = circleCenter.dx.clamp(rect.left, rect.right);
    final closestY = circleCenter.dy.clamp(rect.top, rect.bottom);

    // Mesafeyi hesapla
    final distance = (circleCenter - Offset(closestX, closestY)).distance;

    return distance < circleRadius;
  }

  /// Çarpışmanın derinliğini hesapla (push-back için)
  static double getCollisionDepth(Rect rect1, Rect rect2) {
    final left = rect2.right - rect1.left;
    final right = rect1.right - rect2.left;
    final top = rect2.bottom - rect1.top;
    final bottom = rect1.bottom - rect2.top;

    return [
      left,
      right,
      top,
      bottom,
    ].where((d) => d > 0).reduce((a, b) => a < b ? a : b);
  }

  /// Çarpışmanın yönünü belirle
  static String getCollisionDirection(Rect rect1, Rect rect2) {
    final overlapLeft = rect2.right - rect1.left;
    final overlapRight = rect1.right - rect2.left;
    final overlapTop = rect2.bottom - rect1.top;
    final overlapBottom = rect1.bottom - rect2.top;

    final minOverlap = [
      overlapLeft,
      overlapRight,
      overlapTop,
      overlapBottom,
    ].reduce((a, b) => a < b ? a : b);

    if (minOverlap == overlapTop) return 'TOP';
    if (minOverlap == overlapBottom) return 'BOTTOM';
    if (minOverlap == overlapLeft) return 'LEFT';
    return 'RIGHT';
  }

  /// Debug çarpışması görselleştir (console)
  static void debugDrawCollision(Rect rect1, Rect rect2) {
    print('''
╔════ COLLISION DEBUG ════╗
║ Rect1: (${rect1.left}, ${rect1.top}) - ${rect1.width}x${rect1.height}
║ Rect2: (${rect2.left}, ${rect2.top}) - ${rect2.width}x${rect2.height}
║ Direction: ${getCollisionDirection(rect1, rect2)}
║ Depth: ${getCollisionDepth(rect1, rect2).toStringAsFixed(2)}px
╚════════════════════════╝
''');
  }
}

// Vector2 helper (basit 2D vector)
class Vector2 {
  double x;
  double y;

  Vector2(this.x, this.y);

  operator +(Vector2 other) => Vector2(x + other.x, y + other.y);
  operator -(Vector2 other) => Vector2(x - other.x, y - other.y);
  operator *(double scalar) => Vector2(x * scalar, y * scalar);

  double get length => sqrt(x * x + y * y);
  Vector2 get normalized {
    final l = length;
    return l == 0 ? Vector2(0, 0) : Vector2(x / l, y / l);
  }

  double dot(Vector2 other) => x * other.x + y * other.y;
}
