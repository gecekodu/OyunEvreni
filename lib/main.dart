// 🎮 OYUN OLUSTUR - Eğitici Oyun Platformu
// Flutter + Firebase + Gemini AI + HTML Games

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config/firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'core/services/gemini_service.dart';
import 'core/services/gemini_game_service.dart';
import 'features/games/data/services/game_service.dart';
import 'features/games/data/services/score_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/games/data/datasources/games_remote_datasource.dart';
import 'features/ai/data/datasources/ai_remote_datasource.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/games/presentation/pages/create_game_flow_page.dart';
import 'features/games/presentation/pages/game_list_page.dart';
import 'features/games/presentation/pages/social_feed_page.dart';
import 'features/admin/presentation/pages/test_panel_page.dart';
import 'config/app_theme.dart';
import 'core/services/gemini_game_service_v2.dart';
import 'features/flame_game/presentation/pages/flame_game_page.dart';
import 'features/ai_game_engine/presentation/pages/ai_game_creator_page.dart';
import 'features/ai_game_engine/data/services/ai_game_generator_service.dart';
import 'features/webview/presentation/pages/webview_page.dart';
import 'features/games/presentation/pages/example_games_list_page.dart';

// GetIt - Dependency Injection
final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase başlat (Firebase options kullanarak)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firebaseService = FirebaseService();
  await firebaseService.initialize();

  // 🔥 Firebase Firestore test verisini yaz
  print('⏳ Firestore\'a test verisi yazılıyor...');
  final firestore = FirebaseFirestore.instance;
  try {
    print('📝 Yazma işlemi başladı...');
    final testData = {
      'message': 'Test message from Flutter app',
      'timestamp': DateTime.now(),
      'app': 'OyunEvreni',
      'status': 'active',
      'device': 'iOS/Android',
    };

    await firestore.collection('test').doc('test_doc').set(testData);
    print('✅ Test koleksiyonu Firestore\'a başarıyla yazıldı!');
    print(
      '📍 Kontrol et: Firebase Console → Firestore Database → test koleksiyonu',
    );

    // Veriyi oku ve doğrula
    final docSnapshot = await firestore
        .collection('test')
        .doc('test_doc')
        .get();
    if (docSnapshot.exists) {
      print('✅ Veriler veritabanında okundu: ${docSnapshot.data()}');
    }
  } catch (e, stackTrace) {
    print('❌ Firestore yazma hatası: $e');
    print('📋 Stack trace: $stackTrace');
    print('⚠️ Eğer "PERMISSION_DENIED" hatası alıyorsanız:');
    print(
      '   Firebase Console → Firestore Database → Rules → Test Mode etkinleştir',
    );
  }

  // 🤖 Gemini API başlat (API Key: --dart-define=GEMINI_API_KEY=...)
  const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
  if (geminiApiKey.isEmpty) {
    print('⚠️ GEMINI_API_KEY tanımlı değil. AI özellikleri çalışmayabilir.');
  }
  final geminiService = GeminiService(apiKey: geminiApiKey);

  // 📦 Dependency Injection setup
  _setupDependencies(firebaseService, geminiService, geminiApiKey);

  runApp(const MyApp());
}

/// 🔧 Tüm service'leri register et
void _setupDependencies(
  FirebaseService firebaseService,
  GeminiService geminiService,
  String geminiApiKey,
) {
  // Core Services
  getIt.registerSingleton<FirebaseService>(firebaseService);
  getIt.registerSingleton<GeminiService>(geminiService);
  getIt.registerSingleton<GeminiGameService>(
    GeminiGameService(apiKey: geminiApiKey),
  );
  // ✨ Yeni refactored service (test aşaması)
  getIt.registerSingleton<GeminiGameServiceV2>(
    GeminiGameServiceV2(apiKey: geminiApiKey),
  );
  getIt.registerSingleton<GameService>(
    GameService(
      firebaseService: firebaseService,
      geminiService: getIt<GeminiGameService>(),
    ),
  );
  getIt.registerSingleton<ScoreService>(
    ScoreService(firebaseService: firebaseService),
  );

  // 🤖 AI Game Generator Service
  getIt.registerSingleton<AIGameGeneratorService>(
    AIGameGeneratorService(apiKey: geminiApiKey),
  );

  // Datasources
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSource(firebaseService: firebaseService),
  );

  getIt.registerSingleton<GamesRemoteDataSource>(
    GamesRemoteDataSource(firebaseService: firebaseService),
  );

  getIt.registerSingleton<AIRemoteDataSource>(
    AIRemoteDataSource(geminiService: geminiService),
  );

  // Repositories
  getIt.registerSingleton(
    AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      firebaseService: firebaseService,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nemos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/flame-game': (context) => const FlameGamePage(),
        '/ai-game-creator': (context) => const AIGameCreatorPage(),
        '/example-games': (context) => const ExampleGamesListPage(),
      },
    );
  }
}

/// 🎨 Splash Screen (Başlangıç Ekranı)
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 🐛 DEBUG MODE: Direkt ana sayfaya git (geliştirme için)
    const bool debugSkipAuth = false; // Firebase bağlantısı yoksa true yapın

    if (debugSkipAuth) {
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/logo.jpeg',
                  width: 140,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Oyun Olustur',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'AI ile eğitici oyunlar oluştur',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======== SAYFA CLASSLAR ========

// 🏠 Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeTabView(),
      const SocialFeedPage(),
      const CreateGameFlowPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.public_outlined),
            selectedIcon: Icon(Icons.public),
            label: 'Sosyal',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Oluştur',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// 🏠 Ana Sayfa Tab
class HomeTabView extends StatelessWidget {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Uygulama Logosu
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logo.jpeg',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'AI Oyun Dünyası',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Hayal gücünle oyun yarat!',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 48),

            // 🤖 AI OYUN OLUŞTURUCU - ANA BUTON
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed('/ai-game-creator');
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 60, color: Colors.white),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '🤖 AI Oyun Oluştur',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Gemini AI ile orijinal oyunlar',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Profilim ve İstatistikler
            _buildFeatureCard(
              context: context,
              icon: Icons.person,
              title: 'Profilim',
              subtitle: 'İstatistikler',
              color: Colors.purple,
              onTap: () {
                // Profil sayfasına git
                Navigator.pushNamed(context, '/profile');
              },
            ),

            const SizedBox(height: 24),

            // Klasik Oyunlar Bölümü
            const Divider(height: 40),
            const Text(
              'Klasik Oyunlar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // HTML Oyun Oluştur
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateGameFlowPage(),
                  ),
                );
              },
              icon: const Icon(Icons.code),
              label: const Text('HTML Oyun Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),

            // Oyunları Listele
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => GameListPage()));
              },
              icon: const Icon(Icons.list),
              label: const Text('HTML Oyunları Listele'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 12),

            // Flame Platformer
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/flame-game');
              },
              icon: const Icon(Icons.videogame_asset),
              label: const Text('🎮 Flame 2D Platformer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required String icon,
    required int plays,
    required String gameType,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Text(icon, style: const TextStyle(fontSize: 24)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline, size: 20),
            Text('$plays kez', style: const TextStyle(fontSize: 11)),
          ],
        ),
        onTap: () {
          // Navigate to Social Feed to play games
          // or implement PlayGamePage if needed
        },
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ➕ Create Game Page Eski versiyon - Kaldırıldı
// CreateGameFlowPage tarafından değiştirildi

// 👤 Profile Page
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> userStats;

  @override
  void initState() {
    super.initState();
    userStats = _fetchUserStats();
  }

  Future<Map<String, dynamic>> _fetchUserStats() async {
    final firebaseService = getIt<FirebaseService>();
    final userId = firebaseService.currentUser?.uid ?? 'unknown';
    
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Kullanıcı genel verileri
      final userDoc = await firestore.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};
      
      // Oyun skorları
      final scoresSnapshot = await firestore
          .collection('game_scores')
          .where('userId', isEqualTo: userId)
          .get();
      
      final scores = scoresSnapshot.docs;
      final totalScore = scores.fold<int>(0, (sum, doc) {
        final score = doc['score'] as int? ?? 0;
        return sum + score;
      });
      
      // Oyun sayısı
      final uniqueGames = {...scores.map((doc) => doc['gameId'])}.length;
      
      // En yüksek skor
      final highestScore = scores.isEmpty 
          ? 0 
          : scores.map((doc) => (doc['score'] as int?) ?? 0).reduce((a, b) => a > b ? a : b);
      
      return {
        'totalScore': totalScore,
        'playCount': scores.length,
        'uniqueGames': uniqueGames,
        'highestScore': highestScore,
        'globalRank': userData['globalRank'] ?? '---',
      };
    } catch (e) {
      debugPrint('Hata - İstatistikler yüklenemedi: $e');
      return {
        'totalScore': 0,
        'playCount': 0,
        'uniqueGames': 0,
        'highestScore': 0,
        'globalRank': '---',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = getIt<FirebaseService>();
    final user = firebaseService.currentUser;
    final userName = user?.displayName ?? 'Kullanıcı';
    final userEmail = user?.email ?? 'email@example.com';

    return Scaffold(
      appBar: AppBar(title: const Text('👤 Profilim'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profil Kartı
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue.shade100,
                      backgroundImage: user?.photoURL != null 
                          ? NetworkImage(user!.photoURL!) 
                          : null,
                      child: user?.photoURL == null
                          ? Text(
                              userName.isNotEmpty ? userName[0].toUpperCase() : 'K',
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // İstatistikler (Firestore'dan)
            FutureBuilder<Map<String, dynamic>>(
              future: userStats,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final stats = snapshot.data ?? {};
                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 İstatistikler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Toplam Puan',
                              '${stats['totalScore'] ?? 0}',
                              Icons.emoji_events,
                            ),
                            _buildStatItem(
                              'Oynama',
                              '${stats['playCount'] ?? 0}',
                              Icons.play_circle,
                            ),
                            _buildStatItem(
                              'Oyun Sayısı',
                              '${stats['uniqueGames'] ?? 0}',
                              Icons.gamepad,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '🏆 Global Sıralama',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '#${stats['globalRank'] ?? '---'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '⭐ Yüksek Skor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${stats['highestScore'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Hızlı Linkler
            Card(
              elevation: 4,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Ayarlar'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.emoji_events),
                    title: const Text('Sıralamalar'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, '/leaderboard');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Yardım'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('Hakkında'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Çıkış Yap
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await firebaseService.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Çıkış Yap',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
