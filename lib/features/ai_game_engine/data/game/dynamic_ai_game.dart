// 🎮 DYNAMIC AI GAME ENGINE
// AI tarafından üretilen oyun config'inden runtime'da oyun oluşturur

import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import '../../domain/entities/game_template.dart';

/// 🎮 Dinamik AI Oyun Motoru
class DynamicAIGame extends FlameGame
    with HasCollisionDetection, TapCallbacks {
  // ========== CONFIG ==========
  final AIGameConfig config;
  final Function(int score)? onScoreChanged;
  final Function()? onGameWin;
  final Function()? onGameOver;
  final Function(Question question)? onQuestionAppear;

  // ========== GAME STATE ==========
  AIGameState gameState = AIGameState.playing;
  int currentScore = 0;
  int currentLives = 3;
  double elapsedTime = 0;
  int currentQuestionIndex = 0;
  bool waitingForAnswer = false;

  // ========== GAME OBJECTS ==========
  late DynamicPlayer player;
  final List<DynamicCollectible> collectibles = [];
  final List<DynamicEnemy> enemies = [];
  final List<DynamicObstacle> obstacles = [];

  // ========== TIMERS ==========
  double spawnTimer = 0;
  final double spawnInterval = 2.0; // Her 2 saniyede obje spawn

  DynamicAIGame({
    required this.config,
    this.onScoreChanged,
    this.onGameWin,
    this.onGameOver,
    this.onQuestionAppear,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    print('🎮 ========== DYNAMIC AI GAME LOADING ==========');
    print('📋 Oyun: ${config.title}');
    print('🎯 Şablon: ${config.template.name}');
    print('⚙️ Mekanikler: Gravity=${config.mechanics.hasGravity}, Jump=${config.mechanics.hasJump}');

    // Kamera ayarları
    camera.viewfinder.anchor = Anchor.topLeft;

    // Oyuncu oluştur
    _createPlayer();

    // İlk objeleri oluştur
    _spawnInitialObjects();

    // Oyunu başlat
    gameState = AIGameState.playing;
    currentLives = config.rules.maxLives;

    print('✅ Dynamic AI Game loaded successfully!');
  }

  /// 🟢 Oyuncu oluştur
  void _createPlayer() {
    player = DynamicPlayer(
      color: config.visualTheme.playerColor,
      speed: config.mechanics.playerSpeed,
      jumpHeight: config.mechanics.jumpHeight,
      hasGravity: config.mechanics.hasGravity,
      hasJump: config.mechanics.hasJump,
      gameSize: size,
    );

    add(player);
    print('✅ Player created');
  }

  /// 🎯 İlk objeleri oluştur
  void _spawnInitialObjects() {
    // Eğer collectible varsa bazılarını başta oluştur
    if (config.mechanics.hasCollectibles) {
      for (int i = 0; i < 3; i++) {
        _spawnCollectible();
      }
    }

    // Eğer enemy varsa bazılarını oluştur
    if (config.mechanics.hasEnemies) {
      _spawnEnemy();
    }
  }

  /// ⭐ Toplanabilir obje oluştur
  void _spawnCollectible() {
    final random = Random();
    final x = size.x * (0.3 + random.nextDouble() * 0.6);
    final y = size.y * (0.2 + random.nextDouble() * 0.5);

    final collectible = DynamicCollectible(
      position: Vector2(x, y),
      color: config.visualTheme.collectibleColor,
      hasQuestion: config.educationalContent != null,
    );

    collectibles.add(collectible);
    add(collectible);
  }

  /// 👾 Düşman oluştur
  void _spawnEnemy() {
    final random = Random();
    final x = size.x + 50; // Sağdan başla
    final y = size.y * (0.3 + random.nextDouble() * 0.4);

    final enemy = DynamicEnemy(
      position: Vector2(x, y),
      color: config.visualTheme.enemyColor,
      speed: 100 + random.nextDouble() * 100,
    );

    enemies.add(enemy);
    add(enemy);
  }

  /// 🚧 Engel oluştur
  void _spawnObstacle() {
    final random = Random();
    final x = size.x + 50;
    final y = size.y - 100;

    final obstacle = DynamicObstacle(
      position: Vector2(x, y),
      color: config.visualTheme.enemyColor,
      speed: 150,
    );

    obstacles.add(obstacle);
    add(obstacle);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState != AIGameState.playing) return;

    elapsedTime += dt;

    // Spawn timer
    spawnTimer += dt;
    if (spawnTimer >= spawnInterval) {
      spawnTimer = 0;

      // Random spawn
      final random = Random();
      if (config.mechanics.hasCollectibles && random.nextDouble() > 0.5) {
        _spawnCollectible();
      }
      if (config.mechanics.hasEnemies && random.nextDouble() > 0.7) {
        _spawnEnemy();
      }
    }

    // Zaman limiti kontrolü
    if (config.rules.timeLimit > 0 && elapsedTime >= config.rules.timeLimit) {
      _gameOver();
    }

    // Kazanma koşulu kontrolü
    if (currentScore >= config.rules.winConditionScore) {
      _gameWin();
    }

    // Ekran dışı objeleri temizle
    _cleanupOffscreenObjects();
  }

  /// 🎯 Toplanabilir toplandı
  void onCollectibleCollected(DynamicCollectible collectible) {
    // Eğer soru varsa göster
    if (config.educationalContent != null &&
        currentQuestionIndex < config.educationalContent!.questions.length) {
      final question =
          config.educationalContent!.questions[currentQuestionIndex];
      waitingForAnswer = true;
      gameState = AIGameState.paused;
      onQuestionAppear?.call(question);
    } else {
      // Direkt puan ver
      _addScore(10);
    }

    collectibles.remove(collectible);
    collectible.removeFromParent();
  }

  /// ✅ Soru cevaplandı
  void answerQuestion(int answerIndex) {
    if (!waitingForAnswer) return;

    final question =
        config.educationalContent!.questions[currentQuestionIndex];
    final isCorrect = answerIndex == question.correctIndex;

    if (isCorrect) {
      _addScore(20);
      print('✅ Doğru cevap! +20 puan');
    } else {
      _loseLife();
      print('❌ Yanlış cevap! -1 can');
    }

    currentQuestionIndex++;
    waitingForAnswer = false;
    gameState = AIGameState.playing;
  }

  /// 💀 Düşman / Engelle çarpışma
  void onEnemyHit() {
    _loseLife();
  }

  /// ⭐ Puan ekle
  void _addScore(int points) {
    currentScore += points;
    onScoreChanged?.call(currentScore);
  }

  /// 💔 Can kaybet
  void _loseLife() {
    currentLives--;
    print('💔 Can kaybedildi! Kalan: $currentLives');

    if (currentLives <= 0) {
      _gameOver();
    }
  }

  /// 🎉 Oyun kazanıldı
  void _gameWin() {
    if (gameState == AIGameState.won) return;
    gameState = AIGameState.won;
    print('🎉 OYUN KAZANILDI!');
    onGameWin?.call();
  }

  /// 💀 Oyun bitti
  void _gameOver() {
    if (gameState == AIGameState.gameOver) return;
    gameState = AIGameState.gameOver;
    print('💀 OYUN BİTTİ!');
    onGameOver?.call();
  }

  /// 🧹 Ekran dışı objeleri temizle
  void _cleanupOffscreenObjects() {
    collectibles.removeWhere((c) {
      if (c.position.x < -100 || c.position.y > size.y + 100) {
        c.removeFromParent();
        return true;
      }
      return false;
    });

    enemies.removeWhere((e) {
      if (e.position.x < -100) {
        e.removeFromParent();
        return true;
      }
      return false;
    });

    obstacles.removeWhere((o) {
      if (o.position.x < -100) {
        o.removeFromParent();
        return true;
      }
      return false;
    });
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameState != AIGameState.playing) return;

    // Zıplama
    if (config.mechanics.hasJump) {
      player.jump();
    }
  }

  /// ♻️ Oyunu yeniden başlat
  void restart() {
    currentScore = 0;
    currentLives = config.rules.maxLives;
    elapsedTime = 0;
    currentQuestionIndex = 0;
    waitingForAnswer = false;
    gameState = AIGameState.playing;

    // Tüm objeleri temizle
    for (var c in collectibles) {
      c.removeFromParent();
    }
    for (var e in enemies) {
      e.removeFromParent();
    }
    for (var o in obstacles) {
      o.removeFromParent();
    }

    collectibles.clear();
    enemies.clear();
    obstacles.clear();

    // Player'ı resetle
    player.reset();

    // İlk objeleri yeniden oluştur
    _spawnInitialObjects();
  }
}

/// 🎮 Oyun Durumu
enum AIGameState {
  playing,
  paused,
  won,
  gameOver,
}

/// 🟢 Dinamik Player Component
class DynamicPlayer extends PositionComponent
    with CollisionCallbacks, HasGameRef<DynamicAIGame> {
  final Color color;
  final double speed;
  final double jumpHeight;
  final bool hasGravity;
  final bool hasJump;
  final Vector2 gameSize;

  // Physics
  double velocityY = 0;
  bool isJumping = false;
  bool isGrounded = false;
  final double gravity = 800;

  DynamicPlayer({
    required this.color,
    required this.speed,
    required this.jumpHeight,
    required this.hasGravity,
    required this.hasJump,
    required this.gameSize,
  }) : super(
          position: Vector2(50, 600),
          size: Vector2(40, 40),
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Gravity uygula
    if (hasGravity) {
      isGrounded = position.y >= gameSize.y - size.y - 10;

      if (!isGrounded) {
        velocityY += gravity * dt;
      } else {
        velocityY = 0;
        isJumping = false;
        position.y = gameSize.y - size.y - 10;
      }

      position.y += velocityY * dt;
    }

    // Sınırları Kontrol et
    if (position.x < 0) position.x = 0;
    if (position.x > gameSize.x - size.x) {
      position.x = gameSize.x - size.x;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = color;
    canvas.drawRect(size.toRect(), paint);
  }

  void jump() {
    if (hasJump && isGrounded && !isJumping) {
      velocityY = -jumpHeight;
      isJumping = true;
      print('🦘 Player jumped!');
    }
  }

  void moveLeft() {
    position.x -= speed * 0.016; // Approximate dt
  }

  void moveRight() {
    position.x += speed * 0.016;
  }

  void reset() {
    position = Vector2(50, 600);
    velocityY = 0;
    isJumping = false;
    isGrounded = false;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is DynamicCollectible) {
      gameRef.onCollectibleCollected(other);
    } else if (other is DynamicEnemy || other is DynamicObstacle) {
      gameRef.onEnemyHit();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}

/// ⭐ Toplanabilir Obje
class DynamicCollectible extends PositionComponent with CollisionCallbacks {
  final Color color;
  final bool hasQuestion;

  DynamicCollectible({
    required Vector2 position,
    required this.color,
    this.hasQuestion = false,
  }) : super(position: position, size: Vector2(30, 30));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(CircleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = color;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );

    // Soru işareti çiz (varsa)
    if (hasQuestion) {
      final textPaint = Paint()..color = Colors.white;
      final textStyle = TextStyle(color: Colors.white, fontSize: 20);
      final textSpan = TextSpan(text: '?', style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          size.x / 2 - textPainter.width / 2,
          size.y / 2 - textPainter.height / 2,
        ),
      );
    }
  }
}

/// 👾 Düşman
class DynamicEnemy extends PositionComponent with CollisionCallbacks {
  final Color color;
  final double speed;

  DynamicEnemy({
    required Vector2 position,
    required this.color,
    required this.speed,
  }) : super(position: position, size: Vector2(40, 40));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt; // Sola hareket
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = color;
    canvas.drawRect(size.toRect(), paint);

    // X işareti çiz
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawLine(Offset(5, 5), Offset(size.x - 5, size.y - 5), linePaint);
    canvas.drawLine(Offset(size.x - 5, 5), Offset(5, size.y - 5), linePaint);
  }
}

/// 🚧 Engel
class DynamicObstacle extends PositionComponent with CollisionCallbacks {
  final Color color;
  final double speed;

  DynamicObstacle({
    required Vector2 position,
    required this.color,
    required this.speed,
  }) : super(position: position, size: Vector2(50, 80));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = color;
    canvas.drawRect(size.toRect(), paint);
  }
}
