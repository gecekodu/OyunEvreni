#!/usr/bin/env node
// 🔧 Admin Script - Tüm kullanıcıların puanlarını sıfırla
// Node.js + Firebase Admin SDK
// Çalıştırma: node admin_reset_scores.js

const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// Seçenek 1: android/app/google-services.json kullan (Android için)
const serviceAccountPath = path.join(__dirname, 'android/app/google-services.json');

let serviceAccount;
let projectId;

try {
  const googleServicesJson = require(serviceAccountPath);
  projectId = googleServicesJson.project_info.project_id;

  // Firebase Admin SDK için gerekli credentials oluştur
  // Not: Bu, WEB API Key kullandığı için kısıtlı olabilir.
  // Ideal olarak bir Service Account Key (JSON) dosyası kullanmalısınız.
  
  console.log(`📋 Project ID bulundu: ${projectId}`);
  console.log('⚠️  Web API Key kullanıldığı için, full admin işlemleri sınırlı olabilir.');
  console.log('💡 Ideal: Firebase Console\'dan Service Account Key indir ve kodu güncelle.\n');

  // API Key ile başlatma denemesi (sınırlı)
  const apiKey = googleServicesJson.client[0].api_key[0].current_key;
  
  // Firebase SDK'yı Initialize et (API Key ile)
  // NOT: Admin SDK tam işlevsellik için Service Account gerektiriyor.
  // Bu yaklaşım REST API veya alternative yolu kullanacak.
  
  initializeWithApiKey(apiKey, projectId);

} catch (e) {
  console.error('❌ google-services.json dosyası bulunamadı veya hatalı!');
  console.error('   Yolu kontrol edin: ' + serviceAccountPath);
  console.error('   Hata: ' + e.message);
  process.exit(1);
}

function initializeWithApiKey(apiKey, projectId) {
  // REST APIyle yaklaşım kullan
  const https = require('https');

  async function resetScores() {
    console.log('🔧 Admin Script Başlatılıyor (REST API yöntemi)...');
    
    try {
      // REST API ile users koleksiyonunu sor
      console.log('📊 Tüm kullanıcılar sorgulanıyor...');
      
      const docUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users`;
      
      // Dokumentasyon için bilgi
      console.log('\n⚠️  NOT:');
      console.log('   Firestore REST API, Web SDK\'yı gerektirir.');
      console.log('   Admin işlemleri için lütfen Service Account Key kullanın.\n');
      console.log('   1. Firebase Console\'a git: https://console.firebase.google.com/');
      console.log('   2. Project ayarları → Service Accounts');
      console.log('   3. "Yeni ser vice account oluştur" → JSON indir');
      console.log('   4. Dosyayı proje kökne kaydet: service-account-key.json');
      console.log('   5. Kodu güncellemen: require(\'./service-account-key.json\')');
      console.log('\n🎯 Alternatif: Kolay çözüm için Flutter UI ile Reset butonunu kullan!\n');
      
      console.log('   Uygulamada: Navigatör → /admin-reset-scores sayfası');
      console.log('   Oradan "Tüm Puanları Sıfırla" butonuna tıklayınız.\n');
      
      throw new Error('Admin SDK işlemleri için Service Account Key gereklidir.');

    } catch (error) {
      console.error('❌ HATA:', error.message);
      
      console.log('\n✅ ALTERNATIF ÇÖZÜM:');
      console.log('   Flutter uygulamasını başlat ve şu adımları izle:');
      console.log('   1. flutter run');
      console.log('   2. Giriş yap (gerekirse)');
      console.log('   3. Adres bar\'ında: /admin-reset-scores');
      console.log('   4. Puan sıfırla butonuna tıkla\n');
      
      process.exit(1);
    }
  }

  resetScores();
}
