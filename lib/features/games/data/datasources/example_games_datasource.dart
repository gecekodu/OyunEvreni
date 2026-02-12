import '../../domain/entities/example_game.dart';

abstract class ExampleGamesDatasource {
  Future<List<ExampleGame>> getAllExamples();
  Future<ExampleGame?> getExampleByType(ExampleGameType type);
  Future<List<ExampleGame>> getExamplesByDifficulty(double minDifficulty, double maxDifficulty);
  Future<List<ExampleGame>> getExamplesByAgeRange(int minAge, int maxAge);
}

class ExampleGamesDatasourceImpl implements ExampleGamesDatasource {
  // Sadece 5 temel HTML oyun
  static final List<ExampleGame> _exampleGames = [
    ExampleGame(
      id: 'besin-ninja-001',
      type: ExampleGameType.colorMatch,
      title: '🥗 Besin Ninja',
      description: 'Doğru besin grubunu kes, hedeflenen besinleri yakala ve puan topla.',
      htmlContent: 'assets/Oyunlar/besin_ninja.html',
      minAge: 8,
      maxAge: 18,
      category: 'Sağlık',
      difficulty: 0.4,
      estimatedDuration: Duration(minutes: 6),
    ),
    ExampleGame(
      id: 'lazer-fizik-001',
      type: ExampleGameType.friction,
      title: '🔦 Lazer Fizik',
      description: 'Lazeri aynalarla yönlendir ve hedefe ulaştır.',
      htmlContent: 'assets/Oyunlar/lazer_fizik.html',
      minAge: 10,
      maxAge: 18,
      category: 'Fizik',
      difficulty: 0.6,
      estimatedDuration: Duration(minutes: 8),
    ),
    ExampleGame(
      id: 'matematik-okcusu-001',
      type: ExampleGameType.mathQuiz,
      title: '🏹 Matematik Okcusu',
      description: 'Soruyu çöz, doğru hedefi vur ve puan kazan.',
      htmlContent: 'assets/Oyunlar/matematik_okcusu.html',
      minAge: 8,
      maxAge: 16,
      category: 'Matematik',
      difficulty: 0.5,
      estimatedDuration: Duration(minutes: 7),
    ),
    ExampleGame(
      id: 'araba-surtunme-001',
      type: ExampleGameType.friction,
      title: '🚗 Sürütünme Yarışı',
      description: 'Farklı zeminlerde doğru arabayı seç ve parkuru tamamla.',
      htmlContent: 'assets/Oyunlar/araba_surtunme.html',
      minAge: 10,
      maxAge: 18,
      category: 'Fizik',
      difficulty: 0.6,
      estimatedDuration: Duration(minutes: 7),
    ),
    ExampleGame(
      id: 'gezegen-bul-001',
      type: ExampleGameType.planetHunt,
      title: '🪐 Gezegen Bul',
      description: 'Verilen gezegen ismini bulup gemiyle çarpıştır. Gök bilimi sınavı.',
      htmlContent: 'assets/Oyunlar/gezegen_bul.html',
      minAge: 10,
      maxAge: 18,
      category: 'Fen Bilgisi',
      difficulty: 0.5,
      estimatedDuration: Duration(minutes: 8),
    ),
    ExampleGame(
      id: 'vahsi-doga-001',
      type: ExampleGameType.survival,
      title: '🌲 Vahşi Doğa',
      description: 'Vahşi doğada hayatta kal! Yiyecek topla, su iç, ısını koru ve 100 puana ulaş.',
      htmlContent: 'assets/Oyunlar/vahsi_doga.html',
      minAge: 10,
      maxAge: 18,
      category: 'Yaşam Becerileri',
      difficulty: 0.7,
      estimatedDuration: Duration(minutes: 15),
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
