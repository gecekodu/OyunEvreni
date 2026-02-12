// 🎮 HTML OYUNLARDAN FLUTTER'A PUAN GÖNDERME REHBERİ
// Bu dosya, assets/Oyunlar/ klasöründeki tüm HTML oyunlarında kullanılmalır

// ═══════════════════════════════════════════════════════════════

// 📝 1. HTML OYUN İÇERİSİNDE KULLANILACAK GLOBAL FONKSİYON
// Tüm HTML oyunlarının içine bunu ekle

<script>
  // 🌐 Flutter ile iletişim kur
  window.sendScoreToFlutter = function(score) {
    if (window.flutter_inappwebview) {
      // flutter_inappwebview kullanıyorsak
      window.flutter_inappwebview.callHandler('sendScore', score);
    } else if (window.parent && window.parent.postMessage) {
      // Fallback: postMessage kullan
      window.parent.postMessage({ type: 'score', data: score }, '*');
    }
  };

  // 🎮 Oyun başladı bildirimi
  window.notifyGameStarted = function() {
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler('gameStarted');
    }
  };

  // 🏁 Oyun tamamlandı bildirimi
  window.notifyGameCompleted = function(finalScore) {
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler('gameCompleted', finalScore);
    }
  };

  console.log('✅ Flutter haberleşme hazır!');
</script>

// ═══════════════════════════════════════════════════════════════

// 📋 2. ÖRNEK: BASIT KÜP OYUNU
// assets/Oyunlar/cube_game.html

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Küp Oyunu</title>
    <style>
        body { margin: 0; padding: 20px; background: #2c3e50; }
        #gameContainer { 
            width: 300px; 
            height: 300px; 
            background: #3498db; 
            margin: auto;
            position: relative;
            overflow: hidden;
        }
        .cube { 
            position: absolute; 
            width: 50px; 
            height: 50px; 
            background: #e74c3c;
            cursor: pointer;
        }
        #score { 
            color: white; 
            font-size: 24px; 
            text-align: center; 
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div id="gameContainer"></div>
    <div id="score">Puan: 0</div>

    <script>
        // 🌐 Flutter iletişim
        window.sendScoreToFlutter = function(score) {
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('sendScore', score);
            }
        };

        // 🎮 OYUN KODU
        let score = 0;
        const container = document.getElementById('gameContainer');
        const scoreDisplay = document.getElementById('score');

        function createCube() {
            const cube = document.createElement('div');
            cube.className = 'cube';
            cube.style.left = Math.random() * 250 + 'px';
            cube.style.top = Math.random() * 250 + 'px';
            
            cube.onclick = () => {
                score += 10;
                scoreDisplay.textContent = 'Puan: ' + score;
                
                // ⭐ FLUTTER'A PUAN GÖNDERİ
                window.sendScoreToFlutter(10);
                
                cube.remove();
                if (score >= 100) {
                    alert('Tamamlandı! ' + score + ' puan!');
                    window.flutter_inappwebview?.callHandler('gameCompleted', score);
                } else {
                    createCube();
                }
            };
            
            container.appendChild(cube);
        }

        // Oyun başlat
        window.notifyGameStarted?.();
        createCube();
    </script>
</body>
</html>

// ═══════════════════════════════════════════════════════════════

// 📋 3. ÖRNEK: OYUNCU SKORLAMA SİSTEMİ

// Temel Tüm Oyunlar için Şablon
class GameScoreManager {
    constructor() {
        this.score = 0;
        this.comboMultiplier = 1;
        this.sessionScores = [];
    }

    // ⭐ Ana puan ekleme metodu
    addScore(points) {
        const earnedScore = points * this.comboMultiplier;
        this.score += earnedScore;
        this.sessionScores.push(earnedScore);
        
        console.log(`📊 Puan: +${earnedScore} (Total: ${this.score})`);
        
        // 🌐 Flutter'a gönder
        this.sendToFlutter(earnedScore);
        
        return earnedScore;
    }

    // 📈 Combo çarpanı
    setComboMultiplier(multiplier) {
        this.comboMultiplier = Math.max(1, multiplier);
        console.log(`🔥 Combo: x${this.comboMultiplier}`);
    }

    // 🌐 Flutter'a puan gönderme
    sendToFlutter(score) {
        if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('sendScore', score);
        } else {
            console.warn('⚠️ Flutter bağlantısı yok (WebView kontrolü)');
        }
    }

    // 🏁 Oyun bitişi
    completeGame() {
        console.log(`✅ Oyun tamamlandı! Final Skor: ${this.score}`);
        if (window.flutter_inappwebview) {
            window.flutter_inappwebview.callHandler('gameCompleted', this.score);
        }
    }

    // 📊 İstatistikler
    getStats() {
        return {
            totalScore: this.score,
            sessionCount: this.sessionScores.length,
            averageScore: this.score / this.sessionScores.length || 0
        };
    }
}

// 🎮 KULLANIM ÖRNEĞI
const gameManager = new GameScoreManager();

// Oyuncu bir eylem yaptığında (tıklama, vb)
document.addEventListener('click', () => {
    gameManager.addScore(10);
});

// Combo artışı
gameManager.setComboMultiplier(2);  // x2 çarpan

// Oyun bittiğinde
// gameManager.completeGame();

// ═══════════════════════════════════════════════════════════════

// 📋 4. CORS & GÜVENLIK NOTU

/*
❌ SORUN: "Unable to findHandler with name: sendScore"

✅ ÇÖZÜM:
   1. EnhancedWebviewPage'da handler'ın kayıtlı olduğundan emin ol
   2. onWebViewCreated callback'ini kontrol et
   3. HTML dosyasın window.flutter_inappwebview kullandığını kontrol et

❌ SORUN: Puan güncellenmeyeceğini

✅ ÇÖZÜM:
   1. Firebase Authentication etkinleştirilmiş mi?
   2. Firestore Rules yazma iznine izin veriyor mu? (await check)
   3. Konsol hatasını kontrol et (F12 / DevTools)

❌ SORUN: Leaderboard sıralanması yanlış

✅ ÇÖZÜM:
   1. Firestore'da users/{userId}/totalScore alanın sayı tipi olduğundan emin ol
   2. StreamBuilder'ın orderBy('totalScore', descending: true) kullanıp kullanmadığını kontrol et
*/

// ═══════════════════════════════════════════════════════════════

// 📝 5. MEVCUT HTML OYUNLARA NASIL ENTEGRE ETMELIM?

/*
STEP 1: assets/Oyunlar/ klasöründeki her .html dosyasının <head> kısmına ekle:

    <script>
      window.sendScoreToFlutter = function(score) {
        if (window.flutter_inappwebview) {
          window.flutter_inappwebview.callHandler('sendScore', score);
        }
      };
    </script>

STEP 2: Oyunun puan verme kodu içinde bul, örneğin:
    score += 10;  // gibi bir satır varsa

STEP 3: Hemen sonrasına ekle:
    window.sendScoreToFlutter(10);

STEP 4: Test et!
    - Flutter uygulamayı başlat
    - WebView oyununu aç
    - Oyun oyna
    - Puan artışını kontrol et
    - Firebase Firestore'da profil puanını doğrula
*/
