// 🎮 MAIN GAME - Oyun Döngüsü ve Sahnesi Yönetimi
// Bu, FlameGame sınıfından türeyen ana class
// onLoad() → update(dt) → render() şeklinde çalışır

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/game_constants.dart';
import 'components/player.dart';
import 'components/obstacle.dart';

class FlappyGame extends FlameGame {
  // ========== GAME STATE ==========
  late GameState gameState = GameState.idle;
  late GameStats gameStats = GameStats();
  late Player player;

  // ========== TIMERS ==========
  double obstacleSpawnTimer = 0;
  double gameOverTimer = 0;

  // ========== CALLBACKS ==========
  Function()? onGameOver;
  Function(int score)? onScoreChanged;

  FlappyGame({this.onGameOver, this.onScoreChanged});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    print('🎮 ╔════════════════════════════╗');
    print('🎮 ║   FLAPPY GAME INITIALIZING  ║');
    print('🎮 ╚════════════════════════════╝');

    // 🟢 Oyuncu oluştur
    player = Player();
    add(player);
    print('✅ Player added to game');

    // Oyun başlasın
    startGame();
  }

  /// 🎬 Oyun Başlat
  void startGame() {
    gameState = GameState.playing;
    gameStats.reset();
    gameStats.gameStartTime = DateTime.now();
    obstacleSpawnTimer = 0;

    print('🚀 Game started!');
  }

  /// 🔴 Oyun Bitti
  void gameOver() {
    if (gameState == GameState.gameOver) return; // Zaten bitmişse

    gameState = GameState.gameOver;
    gameStats.gameDuration = DateTime.now().difference(
      gameStats.gameStartTime ?? DateTime.now(),
    );
    gameOverTimer = 0;

    print('💀 GAME OVER!');
    print('📊 Final Stats:');
    print('   Score: ${gameStats.score}');
    print('   Obstacles Passed: ${gameStats.obstaclesPassed}');
    print('   Play Time: ${gameStats.playTime.inSeconds}s');

    onGameOver?.call();
  }

  // ========== MAIN GAME LOOP ==========

  /// 🔄 UPDATE - Oyun Mantığı (60 FPS'de çalışır)
  /// dt = delta time (last frame'den bu frame'e geçen zaman)
  @override
  void update(double dt) {
    super.update(dt);

    if (gameState != GameState.playing) {
      return; // Oyun devam etmiyorsa update'i durdur
    }

    // ⏱️ Engel Spawn Zamanlaması
    _updateObstacleSpawning(dt);

    // 🎮 Input'u kontrol et (ekrana dokunma)
    // (onTapDown callback'i handle ediyor)

    player.debugPrint();
  }

  /// ⏱️ Engel Spawn Yönetimi
  void _updateObstacleSpawning(double dt) {
    obstacleSpawnTimer += dt;

    if (obstacleSpawnTimer >= GameConstants.obstacleSpawn) {
      _spawnObstacle();
      obstacleSpawnTimer = 0;
    }
  }

  /// 🚧 Yeni Engel Oluştur
  void _spawnObstacle() {
    // Sağ taraftan başlayarak oluştur
    final randomY =
        (size.y - GameConstants.obstacleHeight) *
        (0.3 + 0.4 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000);

    final obstacle = Obstacle(
      position: Vector2(
        size.x, // Ekranın sağında başla
        randomY,
      ),
    );

    add(obstacle);
    print('🚧 New obstacle spawned at y=${randomY.toStringAsFixed(1)}');
  }

  // ========== INPUT HANDLING ==========

  /// 🎯 Ekrana Dokunma
  void onTapDown(TapDownInfo tapDownInfo) {
    print('👆 Tap detected');

    if (gameState == GameState.playing) {
      player.jump();
    } else if (gameState == GameState.gameOver) {
      // Oyun biterse, restart için dokunma
      startGame();
      removeWhere(
        (component) => component is Obstacle,
      ); // Tüm engelleri temizle
      print('🔄 Game restarted');
    }
  }

  // ========== COLLISION DETECTION ==========

  /// 💥 Çarpışma Kontrolü
  void checkCollisions() {
    final playerBounds = player.bounds;

    for (final obstacle in children.whereType<Obstacle>()) {
      final obstacleBounds = obstacle.bounds;

      if (playerBounds.overlaps(obstacleBounds)) {
        print('💥 COLLISION DETECTED!');
        gameOver();
        break;
      }
    }
  }

  // ========== RENDER / DRAW ==========

  /// 🎨 Render (her frame çizilir - super.render() döngüsü çalışır)
  /// Flame otomatik olarak background + components render eder
  @override
  Color backgroundColor() => const Color(0xFF87CEEB); // Gökyüzü mavisi

  // ========== DEBUG ==========

  void printGameState() {
    print('''
╔════════════════ GAME STATE ════════════════╗
║ State: $gameState
║ Score: ${gameStats.score}
║ Obstacles: ${gameStats.obstaclesPassed}
║ Time: ${gameStats.playTime.inSeconds}s
║ Player Pos: (${player.position.x.toStringAsFixed(1)}, ${player.position.y.toStringAsFixed(1)})
║ Children: ${children.length}
╚════════════════════════════════════════════╝
''');
  }
}
