# 📖 AI Game Engine - API Dokümantasyonu

## İçindekiler
1. [AIGameGeneratorService](#aigamegeneratorservice)
2. [DynamicAIGame](#dynamicaigame)
3. [AIGameConfig](#aigameconfig)
4. [Kullanım Örnekleri](#kullanım-örnekleri)

---

## AIGameGeneratorService

Gemini AI kullanarak oyun config'i üreten servis.

### Constructor

```dart
AIGameGeneratorService({required String apiKey})
```

**Parametreler:**
- `apiKey` (String): Gemini API anahtarı

**Örnek:**
```dart
final service = AIGameGeneratorService(
  apiKey: DefaultFirebaseOptions.geminiApiKey,
);
```

---

### generateGameFromDescription()

Doğal dil açıklamasından oyun config'i üretir.

```dart
Future<AIGameConfig> generateGameFromDescription({
  required String userDescription,
  required String difficulty,
  required int targetAge,
  String? preferredTemplate,
}) async
```

**Parametreler:**
- `userDescription` (String): Kullanıcının oyun açıklaması
- `difficulty` (String): 'easy', 'medium', 'hard'
- `targetAge` (int): Hedef yaş grubu (5-12)
- `preferredTemplate` (String, optional): Tercih edilen şablon

**Dönüş:** `Future<AIGameConfig>`

**Örnek Kullanım:**

```dart
try {
  final config = await service.generateGameFromDescription(
    userDescription: '7 yaş için toplama öğreten platform oyunu',
    difficulty: 'easy',
    targetAge: 7,
  );
  
  print('Oyun oluşturuldu: ${config.title}');
  print('Soru sayısı: ${config.educationalContent.questions.length}');
} catch (e) {
  print('Hata: $e');
}
```

**Hatalar:**
- `Exception`: Gemini API hatası
- `FormatException`: JSON parse hatası

---

### generateGameFromTemplate()

Şablon ve konu seçerek oyun üretir.

```dart
Future<AIGameConfig> generateGameFromTemplate({
  required String template,
  required String subject,
  required String difficulty,
  required int targetAge,
  String? customTheme,
}) async
```

**Parametreler:**
- `template` (String): 'platformer', 'collector', 'puzzle', 'educational', 'runner', 'shooter'
- `subject` (String): Eğitim konusu (örn: 'matematik', 'kelime')
- `difficulty` (String): 'easy', 'medium', 'hard'
- `targetAge` (int): Hedef yaş (5-12)
- `customTheme` (String, optional): Özel tema (örn: 'uzay', 'orman')

**Örnek:**

```dart
final config = await service.generateGameFromTemplate(
  template: 'platformer',
  subject: 'çarpma',
  difficulty: 'medium',
  targetAge: 8,
  customTheme: 'uzay',
);
```

---

### regenerateGame()

Mevcut oyunun yeni varyantını üretir.

```dart
Future<AIGameConfig> regenerateGame(AIGameConfig originalConfig) async
```

**Parametreler:**
- `originalConfig` (AIGameConfig): Orijinal oyun config'i

**Örnek:**

```dart
final originalConfig = await service.generateGameFromDescription(...);
final newVariant = await service.regenerateGame(originalConfig);
```

---

## DynamicAIGame

Flame engine kullanarak config'den oyun oluşturan sınıf.

### Constructor

```dart
DynamicAIGame({
  required AIGameConfig config,
  Function(int score)? onScoreChanged,
  Function(Question question)? onQuestionAppear,
  Function()? onGameWin,
  Function()? onGameOver,
})
```

**Parametreler:**
- `config` (AIGameConfig): Oyun konfigürasyonu
- `onScoreChanged` (Function, optional): Skor değiştiğinde callback
- `onQuestionAppear` (Function, optional): Soru göründüğünde callback
- `onGameWin` (Function, optional): Oyun kazanıldığında callback
- `onGameOver` (Function, optional): Oyun kaybedildiğinde callback

**Örnek:**

```dart
final game = DynamicAIGame(
  config: generatedConfig,
  onScoreChanged: (score) => print('Skor: $score'),
  onQuestionAppear: (question) => _showQuestionDialog(question),
  onGameWin: () => _showWinDialog(),
  onGameOver: () => _showGameOverDialog(),
);
```

---

### Public Methods

#### answerQuestion()

Soruya cevap verir.

```dart
void answerQuestion(int selectedIndex)
```

**Parametreler:**
- `selectedIndex` (int): Seçilen cevap index'i (0-3)

**Davranış:**
- Doğru cevap: +20 puan, `waitingForAnswer = false`
- Yanlış cevap: -1 can, `waitingForAnswer = false`

**Örnek:**

```dart
// Kullanıcı 2. seçeneği seçti
game.answerQuestion(1); // Index 0-based
```

---

#### restart()

Oyunu yeniden başlatır.

```dart
void restart()
```

**Davranış:**
- Tüm state sıfırlanır
- Player pozisyonu resetlenir
- Yeni objeler spawn edilir

**Örnek:**

```dart
ElevatedButton(
  onPressed: () => game.restart(),
  child: Text('Tekrar Oyna'),
)
```

---

### Public Properties

```dart
int currentScore;          // Mevcut skor
int currentLives;          // Kalan can sayısı
double elapsedTime;        // Geçen süre (saniye)
bool waitingForAnswer;     // Soru bekleme durumu
GameState gameState;       // playing, paused, won, gameOver
```

---

## AIGameConfig

Oyun konfigürasyon veri modeli.

### Tam Yapı

```dart
class AIGameConfig {
  final String gameId;
  final String title;
  final String description;
  final String template;
  final String difficulty;
  final int targetAge;
  final GameMechanics mechanics;
  final EducationalContent educationalContent;
  final VisualTheme visualTheme;
  final GameRules rules;
  final List<GameObject> initialObjects;
}
```

### JSON Serialization

```dart
// JSON'dan config oluşturma
final config = AIGameConfig.fromJson(jsonMap);

// Config'i JSON'a çevirme
final jsonMap = config.toJson();
```

---

## Kullanım Örnekleri

### 1. Basit Platform Oyunu

```dart
Future<void> createSimplePlatformer() async {
  final service = AIGameGeneratorService(
    apiKey: DefaultFirebaseOptions.geminiApiKey,
  );
  
  final config = await service.generateGameFromDescription(
    userDescription: '5 yaş için sayı öğreten basit platform oyunu',
    difficulty: 'easy',
    targetAge: 5,
  );
  
  final game = DynamicAIGame(
    config: config,
    onScoreChanged: (score) {
      setState(() => _currentScore = score);
    },
  );
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        body: GameWidget(game: game),
      ),
    ),
  );
}
```

---

### 2. Şablon ile Matematik Oyunu

```dart
Future<void> createMathGame() async {
  final service = AIGameGeneratorService(
    apiKey: DefaultFirebaseOptions.geminiApiKey,
  );
  
  final config = await service.generateGameFromTemplate(
    template: 'collector',
    subject: 'toplama',
    difficulty: 'medium',
    targetAge: 7,
  );
  
  final game = DynamicAIGame(
    config: config,
    onQuestionAppear: (question) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(question.text),
          content: Column(
            children: List.generate(
              question.options.length,
              (index) => ElevatedButton(
                onPressed: () {
                  game.answerQuestion(index);
                  Navigator.pop(context);
                },
                child: Text(question.options[index]),
              ),
            ),
          ),
        ),
      );
    },
  );
}
```

---

### 3. Tam Entegre Örnek

```dart
class GameCreatorScreen extends StatefulWidget {
  @override
  _GameCreatorScreenState createState() => _GameCreatorScreenState();
}

class _GameCreatorScreenState extends State<GameCreatorScreen> {
  final _service = AIGameGeneratorService(
    apiKey: DefaultFirebaseOptions.geminiApiKey,
  );
  
  AIGameConfig? _config;
  DynamicAIGame? _game;
  bool _isLoading = false;
  int _currentScore = 0;
  Question? _currentQuestion;
  
  Future<void> _generateGame(String description) async {
    setState(() => _isLoading = true);
    
    try {
      final config = await _service.generateGameFromDescription(
        userDescription: description,
        difficulty: 'medium',
        targetAge: 7,
      );
      
      final game = DynamicAIGame(
        config: config,
        onScoreChanged: (score) {
          setState(() => _currentScore = score);
        },
        onQuestionAppear: (question) {
          setState(() => _currentQuestion = question);
        },
        onGameWin: () {
          _showDialog('Kazandınız!', 'Skorunuz: $_currentScore');
        },
        onGameOver: () {
          _showDialog('Oyun Bitti', 'Tekrar deneyin!');
        },
      );
      
      setState(() {
        _config = config;
        _game = game;
      });
    } catch (e) {
      _showDialog('Hata', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (_game == null) {
      return _buildCreatorView();
    }
    
    return Stack(
      children: [
        GameWidget(game: _game!),
        if (_currentQuestion != null) _buildQuestionOverlay(),
        _buildScoreOverlay(),
      ],
    );
  }
  
  Widget _buildCreatorView() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Oyun açıklaması',
              hintText: '7 yaş için toplama öğreten oyun',
            ),
            onSubmitted: _generateGame,
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionOverlay() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentQuestion!.text,
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 20),
                ...List.generate(
                  _currentQuestion!.options.length,
                  (index) => ElevatedButton(
                    onPressed: () {
                      _game!.answerQuestion(index);
                      setState(() => _currentQuestion = null);
                    },
                    child: Text(_currentQuestion!.options[index]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildScoreOverlay() {
    return Positioned(
      top: 40,
      left: 20,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Skor: $_currentScore',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }
}
```

---

### 4. Özel Tema ile Oyun

```dart
final config = await service.generateGameFromTemplate(
  template: 'runner',
  subject: 'kelime',
  difficulty: 'hard',
  targetAge: 10,
  customTheme: 'ormanda hayvan maceraları',
);
```

---

### 5. Oyun Yeniden Üretme

```dart
// İlk oyun
final originalGame = await service.generateGameFromDescription(
  userDescription: 'Matematik oyunu',
  difficulty: 'easy',
  targetAge: 6,
);

// Aynı mantıkta farklı sorular
final variant1 = await service.regenerateGame(originalGame);
final variant2 = await service.regenerateGame(originalGame);
final variant3 = await service.regenerateGame(originalGame);

// Her variant farklı sorular içerir
```

---

## Hata Yönetimi

### Try-Catch Örneği

```dart
try {
  final config = await service.generateGameFromDescription(...);
  final game = DynamicAIGame(config: config);
  
} on SocketException {
  // İnternet bağlantısı yok
  showError('İnternet bağlantınızı kontrol edin');
  
} on FormatException catch (e) {
  // JSON parse hatası
  showError('Oyun oluşturulamadı: ${e.message}');
  
} catch (e) {
  // Genel hata
  showError('Beklenmedik hata: $e');
}
```

---

## Best Practices

### 1. API Key Güvenliği

```dart
// ✅ İyi
final service = AIGameGeneratorService(
  apiKey: DefaultFirebaseOptions.geminiApiKey, // Environment variable
);

// ❌ Kötü
final service = AIGameGeneratorService(
  apiKey: 'AIzaSyB...', // Hard-coded
);
```

### 2. Loading States

```dart
Future<void> _generateGame() async {
  setState(() => _isLoading = true);
  
  try {
    final config = await service.generateGameFromDescription(...);
    // ...
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 3. Memory Cleanup

```dart
@override
void dispose() {
  _game?.onRemove(); // Flame game cleanup
  super.dispose();
}
```

### 4. Error Feedback

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Oyun oluşturuldu: ${config.title}'),
    duration: Duration(seconds: 2),
  ),
);
```

---

## Performans İpuçları

1. **Lazy Loading**: Sadece gerektiğinde oyun oluştur
2. **Caching**: Aynı config'i tekrar kullanabilir
3. **Timeout**: Uzun süren AI istekleri için timeout ayarla
4. **Retry Logic**: Başarısız istekleri tekrar dene

```dart
Future<AIGameConfig> _generateWithRetry(String description) async {
  int attempts = 0;
  const maxAttempts = 3;
  
  while (attempts < maxAttempts) {
    try {
      return await service.generateGameFromDescription(
        userDescription: description,
        difficulty: 'medium',
        targetAge: 7,
      ).timeout(Duration(seconds: 30));
    } catch (e) {
      attempts++;
      if (attempts >= maxAttempts) rethrow;
      await Future.delayed(Duration(seconds: 2));
    }
  }
  
  throw Exception('Maksimum deneme sayısına ulaşıldı');
}
```

---

## Sık Sorulan Sorular

### Kaç tane oyun şablonu var?
6 şablon: platformer, collector, puzzle, educational, runner, shooter

### Gemini hangi modeli kullanıyor?
`gemini-2.0-flash-exp` (fallback: `gemini-pro`)

### Oyun config'i kaydedebilir miyim?
Evet, `toJson()` ile JSON'a çevirip Firestore'a kaydedebilirsiniz.

### Offline çalışır mı?
Hayır, Gemini AI internete ihtiyaç duyar. Ancak kaydedilmiş config'ler offline oynanabilir.

### Kaç soru üretilir?
Genellikle 3-5 soru, yaş grubuna göre değişir.

---

**🎮 Happy Game Creating!**
