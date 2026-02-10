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
      htmlContent: 'assets/html_games/example_games/tetris.html',
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
      description: 'Aynı emojileri bularak eşleştir. Bellek ve konsantrasyon yeteneklerini geliştir.',
      htmlContent: 'assets/html_games/example_games/memory_game.html',
      minAge: 4,
      maxAge: 100,
      category: 'Bilişsel',
      difficulty: 0.3,
      estimatedDuration: Duration(minutes: 5),
    ),
    ExampleGame(
      id: 'color-match-001',
      type: ExampleGameType.colorMatch,
      title: '🐍 Snake Oyunu',
      description: 'Klasik snake oyunu. Oku kullanarak topu hareket ettir. Hızlı refleks gerekir!',
      htmlContent: 'assets/html_games/example_games/snake_game.html',
      minAge: 5,
      maxAge: 100,
      category: 'Refleks',
      difficulty: 0.5,
      estimatedDuration: Duration(minutes: 5),
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
