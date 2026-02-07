// 🎮 Uygulama Sabitleri

class AppConstants {
  // 🐛 Debug Mode
  static const bool debugMode = true; // Geliştirme sırasında true
  static const bool skipAuth = true; // Auth bypass için
  
  // 🎲 Oyun Türleri
  static const List<GameType> gameTypes = [
    GameType(
      id: 'math',
      name: 'Matematik Oyunu',
      icon: '🔢',
      description: 'Toplama, çıkarma, çarpma, bölme',
      color: 0xFF2196F3,
    ),
    GameType(
      id: 'word',
      name: 'Kelime Oyunu',
      icon: '📝',
      description: 'Harf ve kelime bulma, eşleştirme',
      color: 0xFF4CAF50,
    ),
    GameType(
      id: 'puzzle',
      name: 'Bulmaca',
      icon: '🧩',
      description: 'Mantık ve problem çözme',
      color: 0xFFFF9800,
    ),
    GameType(
      id: 'color',
      name: 'Renk Oyunu',
      icon: '🎨',
      description: 'Renk eşleştirme ve tanıma',
      color: 0xFFE91E63,
    ),
    GameType(
      id: 'memory',
      name: 'Hafıza Oyunu',
      icon: '🧠',
      description: 'Eşleşen kartları bul',
      color: 0xFF9C27B0,
    ),
  ];

  // 📊 Zorluk Seviyeleri
  static const List<DifficultyLevel> difficultyLevels = [
    DifficultyLevel(id: 'easy', name: 'Kolay', emoji: '😊', multiplier: 1.0),
    DifficultyLevel(id: 'medium', name: 'Orta', emoji: '🙂', multiplier: 1.5),
    DifficultyLevel(id: 'hard', name: 'Zor', emoji: '😤', multiplier: 2.0),
  ];

  // 🎯 Kazanım Kategorileri
  static const List<LearningGoal> learningGoals = [
    // Matematik
    LearningGoal(
      id: 'math_addition',
      category: 'math',
      name: 'Toplama İşlemi',
      description: '0-100 arası sayılarla toplama',
    ),
    LearningGoal(
      id: 'math_subtraction',
      category: 'math',
      name: 'Çıkarma İşlemi',
      description: '0-100 arası sayılarla çıkarma',
    ),
    LearningGoal(
      id: 'math_multiplication',
      category: 'math',
      name: 'Çarpma İşlemi',
      description: 'Çarpım tablosu (1-10)',
    ),
    LearningGoal(
      id: 'math_division',
      category: 'math',
      name: 'Bölme İşlemi',
      description: 'Basit bölme işlemleri',
    ),
    
    // Kelime
    LearningGoal(
      id: 'word_spelling',
      category: 'word',
      name: 'Doğru Yazım',
      description: 'Kelimeleri doğru yazma',
    ),
    LearningGoal(
      id: 'word_vocabulary',
      category: 'word',
      name: 'Kelime Dağarcığı',
      description: 'Yeni kelimeler öğrenme',
    ),
    
    // Renk
    LearningGoal(
      id: 'color_recognition',
      category: 'color',
      name: 'Renk Tanıma',
      description: 'Ana renkleri tanıma',
    ),
    LearningGoal(
      id: 'color_matching',
      category: 'color',
      name: 'Renk Eşleştirme',
      description: 'Aynı renkleri eşleştirme',
    ),
  ];

  // 🏆 Ödül Sistemleri
  static const int pointsPerGame = 100;
  static const int pointsPerCorrectAnswer = 10;
  static const Map<String, int> badgeRequirements = {
    'first_game': 1,
    'game_creator': 5,
    'popular_creator': 100, // 100 oynama
    'master_creator': 1000, // 1000 oynama
  };
}

// 🎲 Oyun Türü Model
class GameType {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int color;

  const GameType({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });
}

// 📊 Zorluk Seviyesi Model
class DifficultyLevel {
  final String id;
  final String name;
  final String emoji;
  final double multiplier;

  const DifficultyLevel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.multiplier,
  });
}

// 🎯 Öğrenme Hedefi Model
class LearningGoal {
  final String id;
  final String category;
  final String name;
  final String description;

  const LearningGoal({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
  });
}
