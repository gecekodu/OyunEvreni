// 🔧 Admin Script - Tüm kullanıcıların puanlarını sıfırla
// Çalıştırma: dart admin_reset_scores.dart

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config/firebase_options.dart';

void main() async {
  print('🔧 Admin Script Başlatılıyor...');
  
  // Firebase başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final firestore = FirebaseFirestore.instance;
  
  try {
    print('📊 Tüm kullanıcılar sorgulanıyor...');
    
    final snapshot = await firestore.collection('users').get();
    final userCount = snapshot.docs.length;
    
    print('👥 Toplam $userCount kullanıcı bulundu.');
    print('⚠️  Bu, tüm kullanıcıların totalScore alanını 0\'olarak ayarlayacak!');
    print('');
    
    // Batch update
    WriteBatch batch = firestore.batch();
    int ops = 0;
    const int batchSize = 450;
    
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'totalScore': 0});
      ops++;
      
      if (ops >= batchSize) {
        print('🔄 Batch commit: $ops işlem...');
        await batch.commit();
        batch = firestore.batch();
        ops = 0;
      }
    }
    
    // Son batch'i gönder
    if (ops > 0) {
      print('🔄 Son batch commit: $ops işlem...');
      await batch.commit();
    }
    
    print('✅ TÜM KULLANICILAR PUANLARı BAŞARILI İLE SIFIRLANDI!');
    print('📊 Sıfırlanan kullanıcı sayısı: $userCount');
    
  } catch (e, stackTrace) {
    print('❌ HATA: $e');
    print('📋 Stack trace: $stackTrace');
  }
  
  print('\n🏁 Script tamamlandı.');
  exit(0);
}
