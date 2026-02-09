import '../../domain/entities/example_game.dart';

abstract class ExampleGamesDatasource {
  Future<List<ExampleGame>> getAllExamples();
  Future<ExampleGame?> getExampleByType(ExampleGameType type);
  Future<List<ExampleGame>> getExamplesByDifficulty(double minDifficulty, double maxDifficulty);
  Future<List<ExampleGame>> getExamplesByAgeRange(int minAge, int maxAge);
}

class ExampleGamesDatasourceImpl implements ExampleGamesDatasource {
  // Hardcoded örnek oyunlar
  static final List<ExampleGame> _exampleGames = [
    ExampleGame(
      id: 'friction-exp-001',
      type: ExampleGameType.friction,
      title: 'Sürtünme Deneyi',
      description: 'Farklı yüzeylerde sürtünme kuvvetini keşfet. Düzgün, pürüzlü, buzlu ve kumlu yüzeylerde topu fırlatarak sürtünme katsayılarını karşılaştır.',
      htmlContent: 'assets/html_games/example_games/friction_experiment.html',
      minAge: 10,
      maxAge: 18,
      category: 'Fizik',
      difficulty: 0.4,
      estimatedDuration: Duration(minutes: 5),
    ),
    ExampleGame(
      id: 'tetris-001',
      type: ExampleGameType.tetris,
      title: 'Tetris - Blok Düzenleme',
      description: 'Klasik Tetris oyunu. Hızlı biçimde düşen blokları döndürerek ve yerleştirerek satırları tamamla. Stratejik düşünme ve hızlı refleks gerektiriyor.',
      htmlContent: 'assets/html_games/08-Tetris-Game/index.html',
      minAge: 6,
      maxAge: 100,
      category: 'Bulmaca',
      difficulty: 0.5,
      estimatedDuration: Duration(minutes: 10),
    ),
    ExampleGame(
      id: 'memory-001',
      type: ExampleGameType.memory,
      title: 'Hafıza Oyunu - Kartları Eşleştir',
      description: 'Kapalı kartları açarak aynı çiftleri bulması. Bellek ve konsantrasyon yeteneklerini geliştir. Zorluk seviyeleri var.',
      htmlContent: 'assets/html_games/10-Memory-Card-Game/index.html',
      minAge: 4,
      maxAge: 100,
      category: 'Bilişsel',
      difficulty: 0.3,
      estimatedDuration: Duration(minutes: 5),
    ),
    ExampleGame(
      id: 'color-match-001',
      type: ExampleGameType.colorMatch,
      title: 'Renk Eşleştirme',
      description: 'Hızlı refleks oyunu. Gösterilen renk adı ile renk kutusunun renginin eşleşip eşleşmediğini belirle. Dikkat ve karar verme becerilerini geliştir.',
      htmlContent: 'assets/html_games/23-Shape-Clicker-Game/index.html',
      minAge: 5,
      maxAge: 100,
      category: 'Refleks',
      difficulty: 0.6,
      estimatedDuration: Duration(minutes: 3),
    ),
    ExampleGame(
      id: 'math-quiz-001',
      type: ExampleGameType.mathQuiz,
      title: 'Matematik Yarışması',
      description: 'Timed matematik soruları. Toplama, çıkarma, çarpma ve bölme işlemleri hızlı çöz. Zorluk seviyeleri ve ödüller var.',
      htmlContent: 'assets/html_games/27-Quiz-Game/index.html',
      minAge: 6,
      maxAge: 16,
      category: 'Matematik',
      difficulty: 0.5,
      estimatedDuration: Duration(minutes: 5),
    ),
    ExampleGame(
      id: 'word-chain-001',
      type: ExampleGameType.wordChain,
      title: 'Kelime Zinciri',
      description: 'Bir önceki kelimenin son harfi ile başlayan yeni kelime söyle. Kelime dağarcığını geliştir ve hızlı düşün.',
      htmlContent: 'assets/html_games/01-Candy-Crush-Game/index.html',
      minAge: 8,
      maxAge: 100,
      category: 'Dil',
      difficulty: 0.4,
      estimatedDuration: Duration(minutes: 8),
    ),
  ];

  @override
  Future<List<ExampleGame>> getAllExamples() async {
    // Veritabanı yapılacaksa burada değiştirilecek
    await Future.delayed(Duration(milliseconds: 500)); // Simüle network delay
    return _exampleGames;
  }

  @override
  Future<ExampleGame?> getExampleByType(ExampleGameType type) async {
    await Future.delayed(Duration(milliseconds: 300));
    try {
      return _exampleGames.firstWhere((game) => game.type == type);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ExampleGame>> getExamplesByDifficulty(double minDifficulty, double maxDifficulty) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _exampleGames
        .where((game) => game.difficulty >= minDifficulty && game.difficulty <= maxDifficulty)
        .toList();
  }

  @override
  Future<List<ExampleGame>> getExamplesByAgeRange(int minAge, int maxAge) async {
    await Future.delayed(Duration(milliseconds: 300));
    return _exampleGames
        .where((game) => game.minAge <= maxAge && game.maxAge >= minAge)
        .toList();
  }
}
