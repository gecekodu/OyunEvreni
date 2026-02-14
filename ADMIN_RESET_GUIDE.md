📋 TÜMLÜ KULLANICLARIN PUANLARINI SIFIRLAMAK İÇİN:
=======================================================

✅ KOLAY ADIMLAR:

1. Flutter uygulamasını başlat:
   $ flutter run

2. Uygulama başladığında:
   - Giriş yap (eğer gerekiyorsa)
   - Home sayfasına git

3. Puan sıfırlama sayfasına erişim:
   - Android: Cihazda URL bar'ına erişmek için (varsa)
   VEYA
   - Terminal'de, Flutter app çalışırken: 
     * "a" tuşlarına basarak Android emülatörü açabilirsiniz
     * Deep link kullanarak sayfayı açabilirsiniz

4. Alternatif - Log'tan navigate et:
   - Profil sayfasından admin kısımları açmak (admin user isen)
   - Veya uygulamaya bir menü butonunu manuel olarak test etmek

⚠️ DİKKAT:
- Bu işlem GERI ALINAMAZ
- Tüm kullanıcıların totalScore alanı 0'a ayarlanır
- Firestore'da güncelleme yapılır

🔧 KULLANILAN TEKNOLOJI:
- Dart: leaderboard_service.resetAllUsersTotalScore()
- Flutter UI: AdminResetScoresPage (/admin-reset-scores route)
- Firebase: Firestore Collection batch update

📚 KOD DOSYALARI:
- lib/features/games/data/services/leaderboard_service.dart → resetAllUsersTotalScore() metodu
- lib/main.dart → AdminResetScoresPage class ve /admin-reset-scores route
