// 🎨 HTML OYUN GENERATOR - JSON → HTML Dönüştürme

import 'dart:convert';

class GameHtmlGenerator {
  /// 🎮 Matematik oyunu HTML'ini oluştur
  static String generateMathGameHtml({
    required String title,
    required String difficulty,
    required Map<String, dynamic> gameContent,
  }) {
    final questions = gameContent['questions'] as List? ?? [];
    final questionsJson = jsonEncode(questions);

    return '''<!DOCTYPE html>
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
            padding: 10px;
        }
        .container {
            width: 100%;
            max-width: 600px;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 30px;
            overflow-y: auto;
            max-height: 90vh;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
            border-bottom: 3px solid #667eea;
            padding-bottom: 15px;
        }
        .header h1 {
            color: #667eea;
            font-size: 28px;
            margin-bottom: 5px;
        }
        .header p {
            color: #666;
            font-size: 14px;
        }
        .progress-bar {
            width: 100%;
            height: 8px;
            background: #e0e0e0;
            border-radius: 10px;
            margin-bottom: 20px;
            overflow: hidden;
        }
        .progress-fill {
            height: 100%;
            background: linear-gradient(90deg, #667eea, #764ba2);
            width: 0%;
            transition: width 0.3s ease;
        }
        .question-box {
            background: #f5f5f5;
            border-left: 4px solid #667eea;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 10px;
        }
        .question-text {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin-bottom: 15px;
        }
        .answer-option {
            background: white;
            border: 2px solid #ddd;
            padding: 15px;
            margin-bottom: 10px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 16px;
        }
        .answer-option:hover {
            border-color: #667eea;
            background: #f0f4ff;
        }
        .answer-option.selected {
            border-color: #667eea;
            background: #e8ecff;
            color: #667eea;
            font-weight: bold;
        }
        .answer-option.correct {
            border-color: #4caf50;
            background: #e8f5e9;
            color: #4caf50;
        }
        .answer-option.incorrect {
            border-color: #f44336;
            background: #ffebee;
            color: #f44336;
        }
        .btn {
            width: 100%;
            padding: 15px;
            margin-top: 10px;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }
        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }
        .stats-box {
            display: flex;
            justify-content: space-around;
            gap: 10px;
            margin: 20px 0;
            flex-wrap: wrap;
        }
        .stat {
            flex: 1;
            min-width: 80px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            padding: 15px;
            border-radius: 10px;
            text-align: center;
        }
        .stat-value {
            font-size: 24px;
            font-weight: bold;
        }
        .stat-label {
            font-size: 12px;
            margin-top: 5px;
            opacity: 0.9;
        }
        .results {
            text-align: center;
            display: none;
        }
        .results.show {
            display: block;
        }
        .results h2 {
            color: #667eea;
            font-size: 32px;
            margin-bottom: 20px;
        }
        .result-emoji {
            font-size: 80px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📐 $title</h1>
            <p>${gameContent['description'] ?? 'Matematik oyunu'}</p>
        </div>

        <div class="stats-box">
            <div class="stat">
                <div class="stat-value" id="score">0</div>
                <div class="stat-label">Puan</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="correct">0/<span id="total">0</span></div>
                <div class="stat-label">Doğru</div>
            </div>
            <div class="stat">
                <div class="stat-value" id="percentage">0%</div>
                <div class="stat-label">Başarı</div>
            </div>
        </div>

        <div class="progress-bar">
            <div class="progress-fill" id="progressFill"></div>
        </div>

        <div id="questionsContainer"></div>

        <div class="results" id="results">
            <div class="result-emoji" id="resultEmoji">🎉</div>
            <h2 id="resultTitle">Tamamlandı!</h2>
            <p id="resultMessage" style="color: #666; font-size: 16px; margin-bottom: 20px;"></p>
            <button class="btn btn-primary" onclick="location.reload()">🔄 Tekrar Oyna</button>
        </div>
    </div>

    <script>
        const questionsData = $questionsJson;
        let currentQuestion = 0;
        let score = 0;
        let correctCount = 0;

        function initGame() {
            document.getElementById('total').textContent = questionsData.length;
            renderQuestion();
        }

        function renderQuestion() {
            if (currentQuestion >= questionsData.length) {
                showResults();
                return;
            }

            const container = document.getElementById('questionsContainer');
            const q = questionsData[currentQuestion];
            
            container.innerHTML = \`
                <div class="question-box">
                    <div class="question-text">Soru \${currentQuestion + 1} / \${questionsData.length}</div>
                    <div class="question-text">\${q.question}</div>
                    <div>
                        \${q.answers.map((ans, idx) => \`
                            <div class="answer-option" onclick="selectAnswer(\${idx}, \${q.correctIndex})">
                                \${ans}
                            </div>
                        \`).join('')}
                    </div>
                </div>
            \`;
        }

        function selectAnswer(selectedIdx, correctIdx) {
            const options = document.querySelectorAll('.answer-option');
            let isCorrect = selectedIdx === correctIdx;

            options.forEach((opt, idx) => {
                opt.style.pointerEvents = 'none';
                if (idx === correctIdx) {
                    opt.classList.add('correct');
                }
                if (idx === selectedIdx && !isCorrect) {
                    opt.classList.add('incorrect');
                }
            });

            if (isCorrect) {
                correctCount++;
                score += 10;
            }

            updateStats();

            setTimeout(() => {
                currentQuestion++;
                renderQuestion();
            }, 1500);
        }

        function updateStats() {
            document.getElementById('score').textContent = score;
            document.getElementById('correct').textContent = correctCount;
            document.getElementById('percentage').textContent = Math.round((correctCount / questionsData.length) * 100) + '%';
            document.getElementById('progressFill').style.width = ((currentQuestion + 1) / questionsData.length) * 100 + '%';
        }

        function showResults() {
            const percentage = Math.round((correctCount / questionsData.length) * 100);
            let emoji = '🎉';
            let title = 'Süper!';
            
            if (percentage < 50) {
                emoji = '💪';
                title = 'Daha İyi Yapabilirsin!';
            } else if (percentage < 70) {
                emoji = '👍';
                title = 'İyi!';
            } else if (percentage < 90) {
                emoji = '🌟';
                title = 'Harika!';
            }

            document.getElementById('resultEmoji').textContent = emoji;
            document.getElementById('resultTitle').textContent = title;
            document.getElementById('resultMessage').textContent = \`
                \${correctCount} / \${questionsData.length} doğru (\${percentage}%)
                Toplam Puan: \${score}
            \`;
            document.getElementById('questionsContainer').style.display = 'none';
            document.getElementById('results').classList.add('show');
        }

        // Oyunu başlat
        initGame();
    </script>
</body>
</html>''';
  }

  /// 🎮 Genel oyun HTML'ini oluştur (diğer türler için)
  static String generateGenericGameHtml({
    required String title,
    required String gameType,
    required Map<String, dynamic> gameContent,
  }) {
    return '''<!DOCTYPE html>
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
            width: 100%;
            max-width: 600px;
            background: white;
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            text-align: center;
        }
        h1 {
            color: #667eea;
            margin-bottom: 20px;
        }
        p {
            color: #666;
            font-size: 16px;
            line-height: 1.6;
            margin-bottom: 15px;
        }
        .content {
            background: #f5f5f5;
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
        }
        .btn {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 10px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 20px;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>$title</h1>
        <p>${gameContent['description'] ?? 'Eğlenceli oyun'}</p>
        <div class="content">
            <pre>${jsonEncode(gameContent)}</pre>
        </div>
        <button class="btn" onclick="alert('Bu oyun türü şu anda hazırlanıyor!'); location.href='/';">Geri Dön</button>
    </div>
</body>
</html>''';
  }
}
