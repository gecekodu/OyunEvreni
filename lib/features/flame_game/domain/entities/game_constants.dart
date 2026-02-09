// 🎮 FLAME GAME CONSTANTS - Oyun Parametreleri

import 'package:flutter/material.dart';

/// 🎮 Oyun dünyasının genel ayarları
class GameConstants {
  // ========== SCREEN / WORLD ==========
  static const double screenWidth = 400;
  static const double screenHeight = 800;

  // ========== PLAYER PROPERTIES ==========
  static const double playerWidth = 40;
  static const double playerHeight = 40;
  static const Color playerColor = Color(0xFF4CAF50); // Yeşil
  static const double playerStartX = 50;
  static const double playerStartY = 700;

  // ========== PHYSICS ==========
  static const double gravity = 800; // pixels/sec²
  static const double jumpForce = 500; // impulse (pixels/sec)
  static const double jumpDuration = 0.6; // seconds
  static const double maxFallSpeed = 600; // terminal velocity

  // ========== OBSTACLES ==========
  static const double obstacleWidth = 80;
  static const double obstacleHeight = 100;
  static const Color obstacleColor = Color(0xFFFF6B6B); // Kırmızı
  static const double obstacleSpeed = 300; // pixels/sec (sağdan sola)
  static const double obstacleSpawn = 2.0; // seconds between spawns

  // ========== COLLISION ==========
  static const String playerCollisionGroup = 'player';
  static const String obstacleCollisionGroup = 'obstacle';

  // ========== GAME STATE ==========
  static const Duration slowMotionDuration = Duration(milliseconds: 500);
  static const double slowMotionScale = 0.3;
}

/// 🔴 Oyun Durumları
enum GameState {
  playing, // Oyun devam ediyor
  paused, // Oyun durduruldu
  gameOver, // Oyun Bitti
  idle, // İlk state
}

/// 📊 Oyun İstatistikleri
class GameStats {
  int score = 0;
  int obstaclesPassed = 0;
  int collisionsHad = 0;
  DateTime? gameStartTime;
  Duration? gameDuration;

  void reset() {
    score = 0;
    obstaclesPassed = 0;
    collisionsHad = 0;
    gameStartTime = null;
    gameDuration = null;
  }

  Duration get playTime =>
      gameDuration ??
      DateTime.now().difference(gameStartTime ?? DateTime.now());
}
