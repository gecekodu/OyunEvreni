// 🎮 GAME SERVICE - Oyun Oluşturma ve Kaydetme

import 'dart:convert';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/services/gemini_game_service.dart';
import '../../domain/entities/game_models.dart';

class GameService {
  final FirebaseService _firebaseService;
  final GeminiGameService _geminiService;

  GameService({
    required FirebaseService firebaseService,
    required GeminiGameService geminiService,
  })  : _firebaseService = firebaseService,
        _geminiService = geminiService;

  /// 🎮 Oyun oluştur (Gemini AI + HTML Template)
  Future<Game> createGame({
    required String gameType,
    required String difficulty,
    required List<String> learningGoals,
    required String title,
    required String description,
    required String creatorUserId,
    required String creatorName,
    String? userPrompt, // 🤖 Kullanıcının oyun istemi
  }) async {
    try {
      print('🎮 Oyun oluşturuluyor: $title');
      if (userPrompt != null && userPrompt.isNotEmpty) {
        print('💡 Oyun İstemi: $userPrompt');
      }

      // 1. Gemini'den içerik al (hata olsa bile fallback ile devam et)
      Map<String, dynamic> gameContent;
      try {
        gameContent = await _generateGameContent(
          gameType: gameType,
          difficulty: difficulty,
          learningGoals: learningGoals,
          customDescription: description, // Kullanıcının özel açıklamasını gönder
          userPrompt: userPrompt, // 🤖 Oyun istemi
        );
        print('✅ Gemini içerik oluşturuldu');
      } catch (geminiError) {
        print('⚠️ Gemini API hatası: $geminiError, fallback içerik kullanılıyor');
        gameContent = {'title': title, 'description': description, 'content': {}};
      }

      // 2. HTML oluştur (fallback ile)
      String htmlContent = _generateHtmlFromContent(
        gameType: gameType,
        title: title,
        gameContent: gameContent,
        difficulty: difficulty,
      );
      
      // Fallback HTML kontrolü
      if (htmlContent.isEmpty) {
        htmlContent = _generateGenericGameHtml(
          title: title,
          content: gameContent,
          difficulty: difficulty,
        );
        print('⚠️ HTML boş, fallback kullanılıyor');
      }

      print('✅ HTML oluşturuldu (${htmlContent.length} karakter)');

      // 3. Firestore'a kaydet
      final gameId = _firebaseService.firestore.collection('games').doc().id;
      final now = DateTime.now();

      final game = Game(
        id: gameId,
        title: title,
        description: description,
        creatorId: creatorUserId,
        creatorName: creatorName,
        gameType: gameType,
        difficulty: difficulty,
        learningGoals: learningGoals,
        htmlContent: htmlContent,
        thumbnailUrl: '',
        playCount: 0,
        averageRating: 0.0,
        ratingCount: 0,
        createdAt: now,
        updatedAt: now,
        isPublished: true,
        metadata: {'geminiContent': gameContent},
      );

      await _firebaseService.firestore
          .collection('games')
          .doc(gameId)
          .set(game.toFirestore());

      print('✅ Firestore\'a kaydedildi: $gameId');

      return game;
    } catch (e) {
      print('❌ Oyun oluşturma hatası: $e');
      rethrow;
    }
  }

  /// Gemini'den içerik oluştur
  Future<Map<String, dynamic>> _generateGameContent({
    required String gameType,
    required String difficulty,
    required List<String> learningGoals,
    String? customDescription,
    String? userPrompt, // 🤖 Kullanıcının oyun istemi
  }) async {
    try {
      switch (gameType) {
        case 'math':
          return await _geminiService.generateMathGameContent(
            topic: learningGoals.isNotEmpty ? learningGoals[0] : 'toplama',
            difficulty: difficulty,
            questionCount: 10,
            customDescription: customDescription,
            userPrompt: userPrompt,
          );
        case 'word':
          return await _geminiService.generateWordGameContent(
            difficulty: difficulty,
            wordCount: 10,
            userPrompt: userPrompt,
          );
        case 'puzzle':
          return await _geminiService.generatePuzzleGameContent(
            difficulty: difficulty,
            puzzleCount: 5,
            userPrompt: userPrompt,
          );
        case 'color':
          return await _geminiService.generateColorGameContent(
            difficulty: difficulty,
            colorCount: 8,
            userPrompt: userPrompt,
          );
        case 'memory':
          return await _geminiService.generateMemoryGameContent(
            difficulty: difficulty,
            pairCount: 6,
            userPrompt: userPrompt,
          );
        default:
          print('⚠️ Bilinmeyen oyun türü: $gameType, fallback oluşturuluyor...');
          return {'title': 'Oyun', 'description': 'Oyun açıklaması', 'content': {}};
      }
    } catch (e) {
      print('❌ Gemini API hatası: $e');
      return {'title': 'Oyun', 'description': 'Oyun açıklaması', 'content': {}};
    }
  }

  /// HTML template'ini içerik ile doldur
  String _generateHtmlFromContent({
    required String gameType,
    required String title,
    required Map<String, dynamic> gameContent,
    required String difficulty,
  }) {
    if (gameType == 'math') {
      return _generateMathGameHtml(
        title: title,
        questions: gameContent['questions'] ?? [],
        difficulty: difficulty,
      );
    } else if (gameType == 'word') {
      return _generateWordGameHtml(
        title: title,
        words: gameContent['words'] ?? [],
        difficulty: difficulty,
      );
    } else if (gameType == 'puzzle') {
      return _generatePuzzleGameHtml(
        title: title,
        puzzles: gameContent['puzzles'] ?? [],
        difficulty: difficulty,
      );
    } else if (gameType == 'color') {
      return _generateColorGameHtml(
        title: title,
        colors: gameContent['colors'] ?? [],
        difficulty: difficulty,
      );
    } else if (gameType == 'memory') {
      return _generateMemoryGameHtml(
        title: title,
        pairs: gameContent['pairs'] ?? [],
        difficulty: difficulty,
      );
    }

    // Fallback for unsupported types
    return _generateGenericGameHtml(
      title: title,
      content: gameContent,
      difficulty: difficulty,
    );
  }

  /// Generic fallback HTML
  String _generateGenericGameHtml({
    required String title,
    required Map<String, dynamic> content,
    required String difficulty,
  }) {
    return '''
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 600px;
            width: 100%;
            text-align: center;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 { color: #667eea; margin-bottom: 20px; }
        p { color: #666; line-height: 1.8; margin: 15px 0; font-size: 16px; }
        .button {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 10px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            margin-top: 20px;
        }
        .button:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎮 $title</h1>
        <p><strong>Zorluk:</strong> $difficulty</p>
        <p style="color: #999; font-size: 14px;">Oyun motoru hazırlanıyor...</p>
        <button class="button" onclick="testGame()">Oyunu Dene</button>
        <p id="status"></p>
    </div>
    <script>
        let score = 0;
        function testGame() {
            score += 10;
            document.getElementById('status').textContent = 'Skor: ' + score + '/100';
            if (score >= 100) {
                alert('Tebrikler! Oyun tamamlandı!');
                sendScore(100);
            }
        }
        function sendScore(finalScore) {
            if (window.GameChannel) {
                window.GameChannel.postMessage('SCORE:' + finalScore + '/100');
            }
            console.log('✅ Skor gönderildi:', finalScore);
        }
        console.log('✅ Oyun başlatıldı');
    </script>
</body>
</html>
''';
  }

  /// Matematik oyunu HTML'i
  String _generateMathGameHtml({
    required String title,
    required List<dynamic> questions,
    required String difficulty,
  }) {
    return '''
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .game-container {
            background: white;
            border-radius: 20px;
            padding: 30px;
            max-width: 600px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 { color: #667eea; text-align: center; margin-bottom: 20px; }
        .score-board {
            display: flex;
            justify-content: space-around;
            margin-bottom: 25px;
            padding: 15px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            border-radius: 15px;
            color: white;
        }
        .score-value { font-size: 24px; font-weight: bold; }
        .question-box {
            background: #f5f5f5;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 20px;
        }
        .question-text {
            font-size: 24px;
            text-align: center;
            margin-bottom: 25px;
            font-weight: bold;
        }
        .answers {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }
        .answer-btn {
            padding: 18px;
            font-size: 16px;
            border: 2px solid #667eea;
            background: white;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s;
            font-weight: 600;
        }
        .answer-btn:hover { background: #667eea; color: white; }
        .answer-btn.correct { background: #4CAF50; color: white; border-color: #4CAF50; }
        .answer-btn.wrong { background: #f44336; color: white; border-color: #f44336; }
        .result-screen { text-align: center; display: none; }
        .result-screen h2 { color: #667eea; font-size: 32px; margin-bottom: 20px; }
        .restart-btn {
            padding: 15px 40px;
            font-size: 18px;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="game-container">
        <h1>🎮 $title</h1>

        <div class="score-board">
            <div>
                <div class="score-value" id="current-question">1</div>
                <div>Soru</div>
            </div>
            <div>
                <div class="score-value" id="score">0</div>
                <div>Puan</div>
            </div>
            <div>
                <div class="score-value" id="correct">0</div>
                <div>Doğru</div>
            </div>
        </div>

        <div id="question-container" class="question-box">
            <div class="question-text" id="question"></div>
            <div class="answers" id="answers"></div>
        </div>

        <div id="result-screen" class="result-screen">
            <h2>🎉 Tebrikler!</h2>
            <p style="font-size: 24px; margin: 20px 0;">
                <span id="final-score">0</span> / <span id="total-questions">0</span> Doğru
            </p>
            <button class="restart-btn" onclick="restartGame()">🔄 Yeniden Oyna</button>
        </div>
    </div>

    <script>
        // Questions verisini güvenli şekilde yükle ve parse et
        const questionsJson = '${jsonEncode(questions).replaceAll("'", "\\'").replaceAll('"', '\\"')}';
        let questions = [];
        try {
            // JSON parse
            questions = JSON.parse(questionsJson);
            if (!Array.isArray(questions)) {
                throw new Error('Questions is not an array');
            }
            console.log('✅ '+questions.length+' soru yüklendi');
        } catch (e) {
            console.error('❌ JSON Parse Error:', e.message);
            // Fallback
            questions = [{
                question: 'Test Sorusu: 5 + 3 = ?',
                answers: ['8', '7', '9', '6'],
                correctIndex: 0,
                explanation: 'Doğru cevap'
            }];
        }

        let currentQuestion = 0;
        let score = 0;
        let correctAnswers = 0;

        // Flutter'a mesaj gönder
        function sendToFlutter(message) {
            if (window.GameChannel) {
                window.GameChannel.postMessage(message);
            } else if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('gameMessage', message);
            }
            console.log('📱 Message to Flutter:', message);
        }

        function showQuestion() {
            if (currentQuestion >= questions.length) {
                showResults();
                return;
            }

            const q = questions[currentQuestion];
            document.getElementById('current-question').textContent = currentQuestion + 1;
            document.getElementById('question').textContent = q.question;

            const answersDiv = document.getElementById('answers');
            answersDiv.innerHTML = '';

            q.answers.forEach((answer, index) => {
                const btn = document.createElement('button');
                btn.className = 'answer-btn';
                btn.textContent = answer;
                btn.onclick = () => checkAnswer(index, q.correctIndex);
                answersDiv.appendChild(btn);
            });
            
            console.log('❓ Soru gösteriliyor:', currentQuestion + 1, '/', questions.length);
        }

        function checkAnswer(selected, correct) {
            const buttons = document.querySelectorAll('.answer-btn');
            buttons.forEach((btn, index) => {
                btn.disabled = true;
                if (index === correct) {
                    btn.classList.add('correct');
                } else if (index === selected) {
                    btn.classList.add('wrong');
                }
            });

            const isCorrect = selected === correct;
            if (isCorrect) {
                correctAnswers++;
                score += 10;
                document.getElementById('score').textContent = score;
                document.getElementById('correct').textContent = correctAnswers;
                console.log('✅ Doğru cevap! Puan:', score);
                sendToFlutter('CORRECT:' + score);
            } else {
                console.log('❌ Yanlış cevap');
                sendToFlutter('WRONG:' + score);
            }

            setTimeout(() => {
                currentQuestion++;
                showQuestion();
            }, 1500);
        }

        function showResults() {
            document.getElementById('question-container').style.display = 'none';
            document.getElementById('result-screen').style.display = 'block';
            document.getElementById('final-score').textContent = correctAnswers;
            document.getElementById('total-questions').textContent = questions.length;
            
            const percentage = Math.round((correctAnswers / questions.length) * 100);
            console.log('🎉 Oyun bitti! Skor:', correctAnswers, '/', questions.length, '(' + percentage + '%)');
            sendToFlutter('SCORE:' + correctAnswers + '/' + questions.length);
        }

        function restartGame() {
            currentQuestion = 0;
            score = 0;
            correctAnswers = 0;
            document.getElementById('score').textContent = '0';
            document.getElementById('correct').textContent = '0';
            document.getElementById('question-container').style.display = 'block';
            document.getElementById('result-screen').style.display = 'none';
            console.log('🔄 Oyun yeniden başlatıldı');
            sendToFlutter('RESTART');
            showQuestion();
        }

        // Oyun başlıyor
        console.log('🎮 Oyun başlatılıyor...');
        console.log('📝 Soru sayısı:', questions.length);
        sendToFlutter('GAME_STARTED');
        showQuestion();
    </script>
</body>
</html>
''';
  }

  /// Kelime Oyunu HTML'i
  String _generateWordGameHtml({
    required String title,
    required List<dynamic> words,
    required String difficulty,
  }) {
    return '''
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .game-container {
            background: white;
            border-radius: 20px;
            padding: 30px;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 { color: #667eea; text-align: center; margin-bottom: 20px; }
        .word-item {
            background: #f5f5f5;
            padding: 15px;
            margin: 10px 0;
            border-radius: 10px;
            font-size: 16px;
        }
        .button {
            background: #667eea;
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 10px;
            cursor: pointer;
            width: 100%;
            margin-top: 20px;
            font-size: 16px;
            font-weight: bold;
        }
        .button:hover { background: #764ba2; }
    </style>
</head>
<body>
    <div class="game-container">
        <h1>📚 $title</h1>
        <p style="text-align: center; color: #666; margin-bottom: 20px;">Zorluk: <strong>$difficulty</strong></p>
        <div id="words"></div>
        <button class="button" onclick="finishGame()">Oyunu Bitir</button>
    </div>
    <script>
        const words = ${jsonEncode(words).replaceAll("'", "\\'")};
        console.log('✅ Kelime Oyunu Başladı', words.length, 'kelime ile');
        
        function finishGame() {
            if (window.GameChannel) {
                window.GameChannel.postMessage('SCORE:10/10');
            }
            alert('Tebrikler! Oyun tamamlandı!');
        }
        
        const container = document.getElementById('words');
        try {
            const wordData = words || [];
            wordData.slice(0, 5).forEach(w => {
                const div = document.createElement('div');
                div.className = 'word-item';
                div.textContent = (typeof w === 'string' ? w : (w.word || 'Kelime'));
                container.appendChild(div);
            });
        } catch(e) {
            console.log('Word game loaded');
        }
    </script>
</body>
</html>
''';
  }

  /// Puzzle Oyunu HTML'i
  String _generatePuzzleGameHtml({
    required String title,
    required List<dynamic> puzzles,
    required String difficulty,
  }) {
    return '''
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .game-container {
            background: white;
            border-radius: 20px;
            padding: 30px;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 { color: #667eea; text-align: center; margin-bottom: 20px; }
        .puzzle-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin: 20px 0;
        }
        .puzzle-piece {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 20px;
            border-radius: 10px;
            cursor: pointer;
            text-align: center;
            font-weight: bold;
            transition: all 0.3s;
        }
        .puzzle-piece:hover { transform: scale(1.05); }
        .button {
            background: #667eea;
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 10px;
            cursor: pointer;
            width: 100%;
            margin-top: 20px;
            font-size: 16px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="game-container">
        <h1>🧩 $title</h1>
        <p style="text-align: center; color: #666; margin-bottom: 20px;">Zorluk: <strong>$difficulty</strong></p>
        <div class="puzzle-grid" id="puzzles"></div>
        <button class="button" onclick="finishGame()">Oyunu Bitir</button>
    </div>
    <script>
        const puzzles = ${jsonEncode(puzzles).replaceAll("'", "\\'")};
        console.log('✅ Puzzle Oyunu Başladı');
        
        function finishGame() {
            if (window.GameChannel) {
                window.GameChannel.postMessage('SCORE:10/10');
            }
            alert('Tebrikler! Oyun tamamlandı!');
        }
        
        const container = document.getElementById('puzzles');
        try {
            const puzzleData = puzzles || [];
            puzzleData.slice(0, 9).forEach((p, i) => {
                const div = document.createElement('div');
                div.className = 'puzzle-piece';
                div.textContent = i + 1;
                div.onclick = () => container.appendChild(div);
                container.appendChild(div);
            });
        } catch(e) {
            console.log('Puzzle game loaded');
        }
    </script>
</body>
</html>
''';
  }

  /// Renk Oyunu HTML'i
  String _generateColorGameHtml({
    required String title,
    required List<dynamic> colors,
    required String difficulty,
  }) {
    return '''
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .game-container {
            background: white;
            border-radius: 20px;
            padding: 30px;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 { color: #667eea; text-align: center; margin-bottom: 20px; }
        .color-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            margin: 20px 0;
        }
        .color-box {
            height: 80px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s;
            border: 2px solid transparent;
        }
        .color-box:hover { transform: scale(1.05); border-color: #333; }
        .button {
            background: #667eea;
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 10px;
            cursor: pointer;
            width: 100%;
            margin-top: 20px;
            font-size: 16px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="game-container">
        <h1>🎨 $title</h1>
        <p style="text-align: center; color: #666; margin-bottom: 20px;">Zorluk: <strong>$difficulty</strong></p>
        <div class="color-grid" id="colors"></div>
        <button class="button" onclick="finishGame()">Oyunu Bitir</button>
    </div>
    <script>
        const colors = ${jsonEncode(colors).replaceAll("'", "\\'")};
        console.log('✅ Renk Oyunu Başladı');
        
        function finishGame() {
            if (window.GameChannel) {
                window.GameChannel.postMessage('SCORE:10/10');
            }
            alert('Tebrikler! Oyun tamamlandı!');
        }
        
        const container = document.getElementById('colors');
        const colorList = ['#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA07A', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E2'];
        colorList.forEach(color => {
            const div = document.createElement('div');
            div.className = 'color-box';
            div.style.backgroundColor = color;
            container.appendChild(div);
        });
    </script>
</body>
</html>
''';
  }

  /// Bellek Oyunu HTML'i
  String _generateMemoryGameHtml({
    required String title,
    required List<dynamic> pairs,
    required String difficulty,
  }) {
    return '''
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .game-container {
            background: white;
            border-radius: 20px;
            padding: 30px;
            max-width: 500px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 { color: #667eea; text-align: center; margin-bottom: 20px; }
        .memory-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 10px;
            margin: 20px 0;
        }
        .memory-card {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 30px;
            border-radius: 10px;
            cursor: pointer;
            font-size: 24px;
            font-weight: bold;
            transition: all 0.3s;
        }
        .memory-card:hover { transform: scale(1.05); }
        .button {
            background: #667eea;
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 10px;
            cursor: pointer;
            width: 100%;
            margin-top: 20px;
            font-size: 16px;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="game-container">
        <h1>🧠 $title</h1>
        <p style="text-align: center; color: #666; margin-bottom: 20px;">Zorluk: <strong>$difficulty</strong></p>
        <div class="memory-grid" id="cards"></div>
        <button class="button" onclick="finishGame()">Oyunu Bitir</button>
    </div>
    <script>
        const pairs = ${jsonEncode(pairs).replaceAll("\"", "\\\"")};
        let matches = 0;
        console.log('✅ Bellek Oyunu Başladı');
        
        function finishGame() {
            if (window.GameChannel) {
                window.GameChannel.postMessage('SCORE:' + (matches * 10) + '/100');
            }
            alert('Tebrikler! Oyun tamamlandı! Eşleşme: ' + matches);
        }
        
        const container = document.getElementById('cards');
        for (let i = 0; i < 6; i++) {
            const btn = document.createElement('button');
            btn.className = 'memory-card';
            btn.textContent = '?';
            btn.onclick = () => { 
                btn.textContent = String.fromCharCode(65 + i);
                matches++;
            };
            container.appendChild(btn);
        }
    </script>
</body>
</html>
''';
  }

  /// Oyunu ID ile getir
  Future<Game?> getGame(String gameId) async {
    try {
      final doc = await _firebaseService.firestore
          .collection('games')
          .doc(gameId)
          .get();

      if (doc.exists) {
        return Game.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Oyun getirme hatası: $e');
      return null;
    }
  }
}
