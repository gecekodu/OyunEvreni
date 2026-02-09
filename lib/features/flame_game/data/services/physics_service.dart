// ⚙️ PHYSICS SERVICE - Fizik Motoru
// Gravity, velocity, acceleration, momentum gibi kavramları yönetir

import 'dart:math';
import 'package:flutter/material.dart';

/// ⚙️ Physics Service - Tüm Fizik Hesaplamaları
class PhysicsService {
  // ========== KINEMATIC EQUATIONS ==========

  /// 🌍 Yerçekimi altında konumu hesapla
  /// s = s0 + v0*t + 0.5*a*t^2
  static double calculatePosition(
    double initialPosition,
    double initialVelocity,
    double acceleration,
    double timeElapsed,
  ) {
    return initialPosition +
        initialVelocity * timeElapsed +
        0.5 * acceleration * (timeElapsed * timeElapsed);
  }

  /// 📉 Yerçekimi altında hızı hesapla
  /// v = v0 + a*t
  static double calculateVelocity(
    double initialVelocity,
    double acceleration,
    double timeElapsed,
  ) {
    return initialVelocity + acceleration * timeElapsed;
  }

  /// ⬆️ Paraboik hareket (jump trajectory)
  /// t_peak = v0 / g (zıplamada en yüksek noktaya ulaşma süresi)
  static double calculateJumpPeakTime(double initialVelocity, double gravity) {
    return initialVelocity / gravity;
  }

  /// 📏 Zıplamada ulaşılacak maksimum yükseklik
  /// h_max = v0^2 / (2*g)
  static double calculateMaxJumpHeight(double initialVelocity, double gravity) {
    return (initialVelocity * initialVelocity) / (2 * gravity);
  }

  // ========== EASING FUNCTIONS ==========

  /// 🎚️ Ease-In-Out Cubic (smooth animation)
  static double easeInOutCubic(double t) {
    if (t < 0.5) {
      return 4 * t * t * t;
    } else {
      return 1 - pow(-2 * t + 2, 3) / 2;
    }
  }

  /// 🎚️ Ease-Out Quadratic
  static double easeOutQuad(double t) {
    return 1 - (1 - t) * (1 - t);
  }

  /// 🎚️ Ease-In Quad
  static double easeInQuad(double t) {
    return t * t;
  }

  // ========== BOUNCE & COLLISION PHYSICS ==========

  /// 🏀 Bounce (elasticity)
  /// v' = -e * v (e = coefficient of restitution)
  static double calculateBounceVelocity(
    double collisionVelocity,
    double elasticity,
  ) {
    return -elasticity * collisionVelocity;
  }

  /// 💨 Friction (air resistance)
  /// v' = v * (1 - friction_coefficient * dt)
  static double applyFriction(
    double velocity,
    double frictionCoefficient,
    double deltaTime,
  ) {
    return velocity * (1 - frictionCoefficient * deltaTime);
  }

  // ========== DISTANCE & VELOCITY CALCULATIONS ==========

  /// 📏 İki nokta arasındaki mesafe (Euclidean)
  static double distance(Offset p1, Offset p2) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    return sqrt(dx * dx + dy * dy);
  }

  /// 🎯 İki nokta arasındaki açı (degrees)
  static double angleBetweenPoints(Offset p1, Offset p2) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    return atan2(dy, dx) * (180 / pi);
  }

  /// 📌 Verilen açıda ve mesafede yeni nokta
  static Offset pointAtAngleAndDistance(
    Offset from,
    double angleRadians,
    double distance,
  ) {
    return Offset(
      from.dx + distance * cos(angleRadians),
      from.dy + distance * sin(angleRadians),
    );
  }

  // ========== DOT PRODUCT & VECTORS ==========

  /// 🔢 Dot Product (iki vektör arasındaki açı)
  static double dotProduct(Offset v1, Offset v2) {
    return v1.dx * v2.dx + v1.dy * v2.dy;
  }

  /// 🔄 Vector Cross Product (2D)
  static double crossProduct(Offset v1, Offset v2) {
    return v1.dx * v2.dy - v1.dy * v2.dx;
  }

  // ========== INTERPOLATION ==========

  /// 🎬 Linear Interpolation (lerp)
  /// result = a + (b - a) * t, where t in [0, 1]
  static double lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// 🎬 Offset Interpolation
  static Offset lerpOffset(Offset a, Offset b, double t) {
    return Offset(lerp(a.dx, b.dx, t), lerp(a.dy, b.dy, t));
  }

  // ========== DEBUG ==========

  static void printPhysicsState({
    required double position,
    required double velocity,
    required double acceleration,
    required double time,
  }) {
    final nextVelocity = calculateVelocity(velocity, acceleration, time);
    final nextPosition = calculatePosition(
      position,
      velocity,
      acceleration,
      time,
    );

    print('''
╔═══════════ PHYSICS STATE ═══════════╗
║ Position: $position → $nextPosition
║ Velocity: $velocity → $nextVelocity
║ Acceleration: $acceleration
║ Time Step: $time
╚════════════════════════════════════╝
''');
  }
}
