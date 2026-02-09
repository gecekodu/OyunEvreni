// 🎮 AI GAME ENGINE - GAME TEMPLATES
// Gemini tarafından üretilen oyun şablonları

import 'package:flutter/material.dart';

/// 🎮 Oyun Şablonu Türleri
enum GameTemplate {
  platformer, // Platform oyunu (Mario benzeri)
  collector, // Koleksiyon oyunu (Pac-Man benzeri)
  puzzle, // Puzzle oyunu (Sokoban, Tetris)
  educational, // Eğitim oyunu (Matematik, kelime)
  runner, // Endless runner
  shooter, // Space shooter
}

/// 🎮 Oyun Konfigürasyonu (JSON'dan parse edilir)
class AIGameConfig {
  // ========== TEMEL BİLGİLER ==========
  final String gameId;
  final String title;
  final String description;
  final GameTemplate template;
  final String difficulty; // easy, medium, hard
  final int targetAge;

  // ========== OYUN MEKANİKLERİ ==========
  final GameMechanics mechanics;

  // ========== EĞİTİM İÇERİĞİ ==========
  final EducationalContent? educationalContent;

  // ========== GÖRSEL TASARIM ==========
  final VisualTheme visualTheme;

  // ========== OYUN KURALLARI ==========
  final GameRules rules;

  AIGameConfig({
    required this.gameId,
    required this.title,
    required this.description,
    required this.template,
    required this.difficulty,
    required this.targetAge,
    required this.mechanics,
    this.educationalContent,
    required this.visualTheme,
    required this.rules,
  });

  /// JSON'dan parse et
  factory AIGameConfig.fromJson(Map<String, dynamic> json) {
    return AIGameConfig(
      gameId: json['gameId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      template: GameTemplate.values.firstWhere(
        (e) => e.name == json['template'],
        orElse: () => GameTemplate.educational,
      ),
      difficulty: json['difficulty'] ?? 'medium',
      targetAge: json['targetAge'] ?? 8,
      mechanics: GameMechanics.fromJson(json['mechanics'] ?? {}),
      educationalContent: json['educationalContent'] != null
          ? EducationalContent.fromJson(json['educationalContent'])
          : null,
      visualTheme: VisualTheme.fromJson(json['visualTheme'] ?? {}),
      rules: GameRules.fromJson(json['rules'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'title': title,
      'description': description,
      'template': template.name,
      'difficulty': difficulty,
      'targetAge': targetAge,
      'mechanics': mechanics.toJson(),
      'educationalContent': educationalContent?.toJson(),
      'visualTheme': visualTheme.toJson(),
      'rules': rules.toJson(),
    };
  }
}

/// ⚙️ Oyun Mekaniikleri
class GameMechanics {
  final bool hasGravity;
  final bool hasJump;
  final bool hasCollectibles; // Toplanabilir objeler
  final bool hasEnemies;
  final bool hasTimeLimit;
  final bool hasLives;
  final double playerSpeed;
  final double jumpHeight;

  GameMechanics({
    this.hasGravity = true,
    this.hasJump = true,
    this.hasCollectibles = false,
    this.hasEnemies = false,
    this.hasTimeLimit = false,
    this.hasLives = true,
    this.playerSpeed = 200.0,
    this.jumpHeight = 300.0,
  });

  factory GameMechanics.fromJson(Map<String, dynamic> json) {
    return GameMechanics(
      hasGravity: json['hasGravity'] ?? true,
      hasJump: json['hasJump'] ?? true,
      hasCollectibles: json['hasCollectibles'] ?? false,
      hasEnemies: json['hasEnemies'] ?? false,
      hasTimeLimit: json['hasTimeLimit'] ?? false,
      hasLives: json['hasLives'] ?? true,
      playerSpeed: (json['playerSpeed'] ?? 200.0).toDouble(),
      jumpHeight: (json['jumpHeight'] ?? 300.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasGravity': hasGravity,
      'hasJump': hasJump,
      'hasCollectibles': hasCollectibles,
      'hasEnemies': hasEnemies,
      'hasTimeLimit': hasTimeLimit,
      'hasLives': hasLives,
      'playerSpeed': playerSpeed,
      'jumpHeight': jumpHeight,
    };
  }
}

/// 📚 Eğitim İçeriği
class EducationalContent {
  final String subject; // matematik, kelime, fen, vs.
  final List<Question> questions;
  final bool showFeedback;
  final bool trackProgress;

  EducationalContent({
    required this.subject,
    required this.questions,
    this.showFeedback = true,
    this.trackProgress = true,
  });

  factory EducationalContent.fromJson(Map<String, dynamic> json) {
    return EducationalContent(
      subject: json['subject'] ?? '',
      questions: (json['questions'] as List?)
              ?.map((q) => Question.fromJson(q))
              .toList() ??
          [],
      showFeedback: json['showFeedback'] ?? true,
      trackProgress: json['trackProgress'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'questions': questions.map((q) => q.toJson()).toList(),
      'showFeedback': showFeedback,
      'trackProgress': trackProgress,
    };
  }
}

/// ❓ Eğitim Sorusu
class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? imageDescription; // AI tarafından oluşturulan görsel açıklaması

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.imageDescription,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correctIndex'] ?? 0,
      explanation: json['explanation'] ?? '',
      imageDescription: json['imageDescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'imageDescription': imageDescription,
    };
  }
}

/// 🎨 Görsel Tema
class VisualTheme {
  final Color backgroundColor;
  final Color playerColor;
  final Color enemyColor;
  final Color collectibleColor;
  final Color uiColor;
  final String styleDescription; // AI'ın oluşturduğu stil açıklaması

  VisualTheme({
    required this.backgroundColor,
    required this.playerColor,
    required this.enemyColor,
    required this.collectibleColor,
    required this.uiColor,
    required this.styleDescription,
  });

  factory VisualTheme.fromJson(Map<String, dynamic> json) {
    return VisualTheme(
      backgroundColor: Color(json['backgroundColor'] ?? 0xFF87CEEB),
      playerColor: Color(json['playerColor'] ?? 0xFF4CAF50),
      enemyColor: Color(json['enemyColor'] ?? 0xFFFF6B6B),
      collectibleColor: Color(json['collectibleColor'] ?? 0xFFFFD700),
      uiColor: Color(json['uiColor'] ?? 0xFF2196F3),
      styleDescription: json['styleDescription'] ?? 'Simple and colorful',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': backgroundColor.value,
      'playerColor': playerColor.value,
      'enemyColor': enemyColor.value,
      'collectibleColor': collectibleColor.value,
      'uiColor': uiColor.value,
      'styleDescription': styleDescription,
    };
  }
}

/// 📋 Oyun Kuralları
class GameRules {
  final int winConditionScore; // Kazanmak için gerekli puan
  final int maxLives;
  final int timeLimit; // saniye cinsinden (0 = sınırsız)
  final bool allowPause;
  final List<String> instructions; // Oyun talimatları

  GameRules({
    this.winConditionScore = 100,
    this.maxLives = 3,
    this.timeLimit = 0,
    this.allowPause = true,
    required this.instructions,
  });

  factory GameRules.fromJson(Map<String, dynamic> json) {
    return GameRules(
      winConditionScore: json['winConditionScore'] ?? 100,
      maxLives: json['maxLives'] ?? 3,
      timeLimit: json['timeLimit'] ?? 0,
      allowPause: json['allowPause'] ?? true,
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'winConditionScore': winConditionScore,
      'maxLives': maxLives,
      'timeLimit': timeLimit,
      'allowPause': allowPause,
      'instructions': instructions,
    };
  }
}

/// 🎮 Oyun Objesi (Dinamik olarak oluşturulur)
class GameObject {
  final String id;
  final String type; // player, enemy, collectible, obstacle
  final double x;
  final double y;
  final double width;
  final double height;
  final Color color;
  final Map<String, dynamic>? metadata; // Ekstra veri

  GameObject({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
    this.metadata,
  });

  factory GameObject.fromJson(Map<String, dynamic> json) {
    return GameObject(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      x: (json['x'] ?? 0.0).toDouble(),
      y: (json['y'] ?? 0.0).toDouble(),
      width: (json['width'] ?? 40.0).toDouble(),
      height: (json['height'] ?? 40.0).toDouble(),
      color: Color(json['color'] ?? 0xFFFFFFFF),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'color': color.value,
      'metadata': metadata,
    };
  }
}
