// 🎮 ÖRNEK OYUNLAR - VERİ MODELİ

/// Oyun türleri
enum ExampleGameType {
  friction('Sürtünme Deneyi', '🔬'),
  tetris('Tetris', '🧱'),
  memory('Hafıza Oyunu', '🧠'),
  colorMatch('Renk Eşleştir', '🎨'),
  mathQuiz('Matematik', '🔢'),
  wordChain('Kelime Zinciri', '📝'),
  planetHunt('Gezegen Bul', '🪐'),
  survival('Vahşi Doğa', '🌲');

  final String title;
  final String emoji;
  const ExampleGameType(this.title, this.emoji);
}

/// Örnek oyun veri modeli
class ExampleGame {
  final String id;
  final ExampleGameType type;
  final String title;
  final String description;
  final String htmlContent;
  final int minAge;
  final int maxAge;
  final String category;
  final double difficulty; // 0.0 - 1.0
  final Duration estimatedDuration;

  const ExampleGame({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.htmlContent,
    required this.minAge,
    required this.maxAge,
    required this.category,
    required this.difficulty,
    required this.estimatedDuration,
  });

  String get difficultyLabel {
    if (difficulty < 0.33) return 'Kolay';
    if (difficulty < 0.66) return 'Orta';
    return 'Zor';
  }
}
