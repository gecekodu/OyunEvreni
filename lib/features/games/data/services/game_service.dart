// 🎮 GAME SERVICE - Oyun Oluşturma ve Kaydetme

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  }) async {
    try {
      print('🎮 Oyun oluşturuluyor: $title');

      // 1. Gemini'den içerik al
      Map<String, dynamic> gameContent = await _generateGameContent(
        gameType: gameType,
        difficulty: difficulty,
        learningGoals: learningGoals,
      );

      print('✅ Gemini içerik oluşturuldu');

      // 2. HTML oluştur
      String htmlContent = _generateHtmlFromContent(
        gameType: gameType,
        title: title,
        gameContent: gameContent,
        difficulty: difficulty,
      );

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
  }) async {
    switch (gameType) {
      case 'math':
        return await _geminiService.generateMathGameContent(
          topic: learningGoals.isNotEmpty ? learningGoals[0] : 'toplama',
          difficulty: difficulty,
          questionCount: 10,
        );
      case 'word':
        return await _geminiService.generateWordGameContent(
          difficulty: difficulty,
          wordCount: 10,
        );
      case 'puzzle':
        return await _geminiService.generatePuzzleGameContent(
          difficulty: difficulty,
          puzzleCount: 5,
        );
      case 'color':
        return await _geminiService.generateColorGameContent(
          difficulty: difficulty,
          colorCount: 8,
        );
      case 'memory':
        return await _geminiService.generateMemoryGameContent(
          difficulty: difficulty,
          pairCount: 6,
        );
      default:
        throw Exception('Bilinmeyen oyun türü: $gameType');
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
    }

    return '''
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
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
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        h1 { color: #667eea; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎮 $title</h1>
        <p style="text-align: center; margin: 20px 0;">Zorluk: <strong>$difficulty</strong></p>
    </div>
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
        const questions = ${jsonEncode(questions)};
        let currentQuestion = 0;
        let score = 0;
        let correctAnswers = 0;

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

            if (selected === correct) {
                correctAnswers++;
                score += 10;
                document.getElementById('score').textContent = score;
                document.getElementById('correct').textContent = correctAnswers;
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
        }

        function restartGame() {
            currentQuestion = 0;
            score = 0;
            correctAnswers = 0;
            document.getElementById('score').textContent = '0';
            document.getElementById('correct').textContent = '0';
            document.getElementById('question-container').style.display = 'block';
            document.getElementById('result-screen').style.display = 'none';
            showQuestion();
        }

        showQuestion();
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
