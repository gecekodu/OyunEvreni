// 🔧 Firebase Cloud Functions
// Tüm kullanıcıların puanlarını sıfırla

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const cors = require('cors')({origin: true});

// Firebase Admin SDK'yı başlat
admin.initializeApp();

const db = admin.firestore();

/**
 * 🔄 HTTP Triggered Function: Tüm kullanıcıların totalScore'unu 0'a sıfırla
 * 
 * Kullanım:
 * POST /resetAllUsersTotalScores
 * Body: { adminPassword: "YOUR_ADMIN_PASSWORD" }
 * 
 * ⚠️ ÜRETIM: Gerçek admin authentication kullanın!
 */
exports.resetAllUsersTotalScores = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      // Request validation
      if (req.method !== 'POST') {
        return res.status(400).json({ 
          error: 'Sadece POST requests kabul edilir',
          method: req.method 
        });
      }

      // Admin authentication check
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(403).json({ error: 'Yetkisiz: Authorization header gerekli' });
      }

      console.log('🔧 Puan sıfırlama işlemi başlatılıyor...');

      // Tüm users'ları oku
      const snapshot = await db.collection('users').get();
      const userCount = snapshot.size;

      console.log(`👥 Toplam ${userCount} kullanıcı bulundu`);

      if (userCount === 0) {
        return res.json({
          success: true,
          message: 'Hiç kullanıcı bulunamadı',
          usersProcessed: 0,
        });
      }

      // Batch operasyonlar
      let batch = db.batch();
      let operations = 0;
      const BATCH_SIZE = 500; // Firestore batch limit

      let updatedCount = 0;
      for (const doc of snapshot.docs) {
        batch.update(doc.ref, { totalScore: 0 });
        operations++;
        updatedCount++;

        if (operations >= BATCH_SIZE) {
          console.log(`📤 Batch commit: ${operations} işlem...`);
          await batch.commit();
          batch = db.batch();
          operations = 0;
        }
      }

      // Son batch'i gönder
      if (operations > 0) {
        console.log(`📤 Son batch commit: ${operations} işlem...`);
        await batch.commit();
      }

      console.log(`✅ ${updatedCount} kullanıcının puanları sıfırlandı`);

      res.json({
        success: true,
        message: 'Tüm kullanıcıların toplam puanları başarılı ile sıfırlandı',
        usersProcessed: updatedCount,
        timestamp: new Date().toISOString(),
      });

    } catch (error) {
      console.error('❌ Hata:', error);
      res.status(500).json({
        success: false,
        error: error.message,
        details: error.toString(),
      });
    }
  });
});

/**
 * 📊 Firestore Trigger: game_scores collection'na yeni skor eklendiğinde
 * Kullanıcı istatistiklerini güncelle
 */
exports.onGameScoreCreated = functions.firestore
  .document('game_scores/{scoreId}')
  .onCreate(async (snap, context) => {
    try {
      const scoreData = snap.data();
      const userId = scoreData.userId;

      console.log(`🎮 Yeni skor: Kullanıcı ${userId}, Puan: ${scoreData.score}`);

      // Kullanıcının tüm oyunlardaki max puanlarının toplamını hesapla
      const userScores = await db.collection('game_scores')
        .where('userId', '==', userId)
        .get();

      const gameMaxScores = {};
      let totalScore = 0;

      for (const doc of userScores.docs) {
        const score = doc.data();
        if (!gameMaxScores[score.gameId] || gameMaxScores[score.gameId] < score.score) {
          gameMaxScores[score.gameId] = score.score;
        }
      }

      // En yüksek puanları topla
      totalScore = Object.values(gameMaxScores).reduce((sum, score) => sum + score, 0);

      // users koleksiyonunu güncelle
      await db.collection('users').doc(userId).update({
        totalScore: totalScore,
        lastGameTime: admin.firestore.Timestamp.now(),
      });

      console.log(`✅ Kullanıcı ${userId} toplam puan güncellendi: ${totalScore}`);

    } catch (error) {
      console.error('❌ onGameScoreCreated Error:', error);
      // Log the error but don't throw - this is a background task
    }
  });

/**
 * 🔍 HTTP Triggered Function: Sistem sağlık kontrolü
 */
exports.healthCheck = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    res.json({
      status: 'OK',
      timestamp: new Date().toISOString(),
      functions: {
        resetAllUsersTotalScores: 'Available',
        onGameScoreCreated: 'Available',
        healthCheck: 'Available',
      },
    });
  });
});

/**
 * 📋 HTTP Triggered Function: İstatistik listesi
 */
exports.getStats = functions.https.onRequest(async (req, res) => {
  cors(req, res, async () => {
    try {
      const usersSnapshot = await db.collection('users').get();
      const scoresSnapshot = await db.collection('game_scores').get();

      res.json({
        stats: {
          totalUsers: usersSnapshot.size,
          totalScores: scoresSnapshot.size,
          timestamp: new Date().toISOString(),
        },
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });
});

console.log('✅ Cloud Functions başlatıldı');
