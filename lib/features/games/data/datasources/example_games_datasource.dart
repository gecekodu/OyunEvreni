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
      title: 'Besin Ninja',
      description: 'Doğru besin grubunu kes, hedeflenen besinleri yakala ve puan topla.',
      htmlContent: 'assets/Oyunlar/besin_ninja.html',
      minAge: 8,
      maxAge: 18,
      category: 'Sağlık',
      difficulty: 0.4,
      estimatedDuration: Duration(minutes: 6),
      imagePath: 'assets/images/gıda ninja.png',
      price: 5.99,
      rating: 4.2,
    ),
    ExampleGame(
      id: 'lazer-fizik-001',
      type: ExampleGameType.friction,
      title: 'Lazer Fizik',
      description: 'Lazeri aynalarla yönlendir ve hedefe ulaştır.',
      htmlContent: 'assets/Oyunlar/lazer_fizik.html',
      minAge: 10,
      maxAge: 18,
      category: 'Fizik',
      difficulty: 0.6,
      estimatedDuration: Duration(minutes: 8),
      imagePath: 'assets/images/lazer fizik.png',
      price: 7.99,
      rating: 4.7,
    ),
    ExampleGame(
      id: 'matematik-okcusu-001',
      type: ExampleGameType.mathQuiz,
      title: 'Matematik Okcusu',
      description: 'Soruyu çöz, doğru hedefi vur ve puan kazan.',
      htmlContent: 'assets/Oyunlar/matematik_okcusu.html',
      minAge: 8,
      maxAge: 16,
      category: 'Matematik',
      difficulty: 0.5,
      estimatedDuration: Duration(minutes: 7),
      imagePath: 'assets/images/matematik okcusu.png',
      price: 4.99,
      rating: 4.5,
    ),
    ExampleGame(
      id: 'araba-surtunme-001',
      type: ExampleGameType.friction,
      title: 'Sürtünme Yarışı',
      description: 'Farklı zeminlerde doğru arabayı seç ve parkuru tamamla.',
      htmlContent: 'assets/Oyunlar/araba_surtunme.html',
      minAge: 10,
      maxAge: 18,
      category: 'Fizik',
      difficulty: 0.6,
      estimatedDuration: Duration(minutes: 7),
      imagePath: 'assets/images/surtunme yarisi.png',
      price: 6.99,
      rating: 4.8,
    ),
    ExampleGame(
      id: 'gezegen-bul-001',
      type: ExampleGameType.planetHunt,
      title: 'Gezegen Bul',
      description: 'Verilen gezegen ismini bulup gemiyle çarpıştır. Gök bilimi sınavı.',
      htmlContent: 'assets/Oyunlar/gezegen_bul.html',
      minAge: 10,
      maxAge: 18,
      category: 'Fen Bilgisi',
      difficulty: 0.5,
      estimatedDuration: Duration(minutes: 8),
      imagePath: 'assets/images/gezegen bul.png',
      price: 6.99,
      rating: 4.6,
    ),
    ExampleGame(
      id: 'vahsi-doga-001',
      type: ExampleGameType.survival,
      title: 'Vahşi Doğa',
      description: 'Vahşi doğada hayatta kal! Yiyecek topla, su iç, ısını koru ve 100 puana ulaş.',
      htmlContent: 'assets/Oyunlar/vahsi_doga.html',
      minAge: 10,
      maxAge: 18,
      category: 'Yaşam Becerileri',
      difficulty: 0.7,
      estimatedDuration: Duration(minutes: 15),
      imagePath: 'assets/images/Vahsi Doga.png',
      price: 8.99,
      rating: 4.9,
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
