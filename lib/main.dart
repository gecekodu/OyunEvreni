// 🎮 OYUN OLUSTUR - Eğitici Oyun Platformu
// Flutter + Firebase + Gemini AI + HTML Games

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'config/firebase_options.dart';
import 'core/services/firebase_service.dart';
import 'core/services/gemini_service.dart';
import 'core/services/gemini_game_service.dart';
import 'features/games/data/services/game_service.dart';
import 'features/games/data/services/score_service.dart';
import 'features/games/data/services/leaderboard_service.dart';
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
import 'features/games/presentation/pages/leaderboard_page.dart';
import 'features/clan/presentation/pages/clan_page.dart';

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
  getIt.registerSingleton<LeaderboardService>(LeaderboardService());

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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nemos',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => HomePage(onThemeChanged: toggleTheme),
        '/profile': (context) => ProfilePage(onThemeChanged: toggleTheme),
        '/leaderboard': (context) => LeaderboardPage(),
        '/flame-game': (context) => const FlameGamePage(),
        '/ai-game-creator': (context) => const AIGameCreatorPage(),
        '/example-games': (context) => const ExampleGamesListPage(),
        '/clan': (context) => const ClanPage(),
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
    _progressAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(_animationController);

    _animationController.forward();
    _checkAuthState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // Firebase Auth kontrol
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User zaten giriş yapmış - Ana sayfaya git
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // User giriş yapmamış - Login sayfasına git
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0E27),
              const Color(0xFF16213E),
              const Color(0xFF1A2F5A),
              const Color(0xFF0F3460),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo with Glow
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.4),
                              blurRadius: 40 +
                                  (20 * (0.5 - (_fadeAnimation.value - 0.5).abs())),
                              spreadRadius: 15,
                            ),
                            BoxShadow(
                              color: Colors.deepOrange.withOpacity(0.2),
                              blurRadius: 60,
                              spreadRadius: 25,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(25),
                        child: Transform.scale(
                          scale: 0.8 + (_fadeAnimation.value * 0.2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(
                              'assets/images/logo.jpeg',
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Futuristic Title
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              'NEMOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: Colors.deepOrange.withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 0),
                                  ),
                                  Shadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Öğrenmenin oyun hali',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Futuristic Progress Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            // Progress percentage text
                            Text(
                              '${(_progressAnimation.value * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Main progress bar
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.deepOrange.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrange.withOpacity(0.15),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Stack(
                                  children: [
                                    // Backg round
                                    Container(
                                      color: Colors.white.withOpacity(0.05),
                                    ),
                                    // Progress fill with gradient
                                    FractionallySizedBox(
                                      widthFactor: _progressAnimation.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Colors.deepOrange,
                                              Colors.deepOrange
                                                  .withOpacity(0.7),
                                              Colors.amber,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.deepOrange
                                                  .withOpacity(0.6),
                                              blurRadius: 10,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Animated dots for loading effect
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final delay = index * 0.1;
                          final value =
                              ((_progressAnimation.value + delay) % 1.0);
                          final isActive = value > 0.6;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: ScaleTransition(
                              scale: AlwaysStoppedAnimation(
                                isActive ? 1.2 : 0.6,
                              ),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? Colors.deepOrange
                                      : Colors.deepOrange.withOpacity(0.4),
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: Colors.deepOrange
                                                .withOpacity(0.6),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : [],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Yükleniyor...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ======== SAYFA CLASSLAR ========

// 🏠 Home Page
class HomePage extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  const HomePage({super.key, this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  String? _navAvatarEmoji;
  String? _navAvatarPhoto;

  Future<bool> _handleBackPress() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      return false;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Çıkmak istiyor musun?'),
          content: const Text('Uygulamadan çıkmak istiyor musun?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Vazgeç'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Çık'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
      return true;
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _bindUserAvatar();
  }

  void _bindUserAvatar() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _userSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((doc) {
      final data = doc.data();
      if (!mounted) return;
      setState(() {
        _navAvatarEmoji = data?['avatarEmoji'] as String?;
        _navAvatarPhoto = (data?['photoURL'] as String?) ?? user.photoURL;
      });
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeTabView(),
      const ClanPage(),
      const ExampleGamesListPage(),
      const AiPage(),
      const ProfilePage(),
    ];

    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: pages,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                height: 64,
                backgroundColor: Colors.black.withOpacity(0.9),
                indicatorColor: Colors.deepOrange,
                labelTextStyle: WidgetStateProperty.all(
                  const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final color = states.contains(WidgetState.selected)
                      ? Colors.white
                      : Colors.white70;
                  return IconThemeData(color: color);
                }),
              ),
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                onDestinationSelected: (index) {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                destinations: [
                  const NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: _NavSelectedIcon(icon: Icons.home),
                    label: 'Ana Sayfa',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.groups_outlined),
                    selectedIcon: _NavSelectedIcon(icon: Icons.groups),
                    label: 'Klan',
                  ),
                  const NavigationDestination(
                    icon: _GameButtonOffsetIcon(icon: Icons.sports_esports_outlined),
                    selectedIcon: _GameButtonOffsetIcon(
                      icon: Icons.sports_esports,
                      isSelected: true,
                    ),
                    label: 'Oyunlar',
                  ),
                  const NavigationDestination(
                    icon: Icon(Icons.smart_toy_outlined),
                    selectedIcon: _NavSelectedIcon(icon: Icons.smart_toy),
                    label: 'AI',
                  ),
                  NavigationDestination(
                    icon: _NavProfileIcon(
                      avatarEmoji: _navAvatarEmoji,
                      avatarUrl: _navAvatarPhoto,
                    ),
                    selectedIcon: _NavSelectedAvatarIcon(
                      avatarEmoji: _navAvatarEmoji,
                      avatarUrl: _navAvatarPhoto,
                    ),
                    label: 'Profil',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSelectedIcon extends StatelessWidget {
  final IconData icon;

  const _NavSelectedIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _GameButtonOffsetIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _GameButtonOffsetIcon({
    required this.icon,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isSelected
        ? Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.amber, Colors.deepOrange],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.6),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          )
        : Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.withOpacity(0.7),
                  Colors.deepOrange.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.87), size: 26),
          );

    return Transform.translate(
      offset: const Offset(0, -8),
      child: child,
    );
  }
}

class _NavProfileIcon extends StatelessWidget {
  final String? avatarEmoji;
  final String? avatarUrl;

  const _NavProfileIcon({this.avatarEmoji, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarEmoji != null && avatarEmoji!.isNotEmpty) {
      return Text(avatarEmoji!, style: const TextStyle(fontSize: 18));
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 12,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    }
    return const Icon(Icons.person_outline);
  }
}

class _NavSelectedAvatarIcon extends StatelessWidget {
  final String? avatarEmoji;
  final String? avatarUrl;

  const _NavSelectedAvatarIcon({this.avatarEmoji, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: avatarEmoji != null && avatarEmoji!.isNotEmpty
            ? Text(avatarEmoji!, style: const TextStyle(fontSize: 16))
            : (avatarUrl != null && avatarUrl!.isNotEmpty
                ? CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(avatarUrl!),
                  )
                : const Icon(Icons.person, color: Colors.white, size: 20)),
      ),
    );
  }
}

// 🏠 Ana Sayfa Tab
class HomeTabView extends StatefulWidget {
  const HomeTabView({super.key});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final PageController _sliderController = PageController(viewportFraction: 0.9);
  Timer? _sliderTimer;
  int _currentSlide = 0;
  late Future<Map<String, dynamic>> _homeStats;

  final List<_HomeSlide> _slides = const [
    _HomeSlide(
      title: '5 Ornek Oyun',
      subtitle: 'Hemen oyna, puanlarini topla',
      icon: Icons.games,
      colors: [Color(0xFFFF6B35), Color(0xFFFFA24A)],
    ),
    _HomeSlide(
      title: 'Canli Puan Sistemi',
      subtitle: 'Skorlarin aninda kaydolur',
      icon: Icons.emoji_events,
      colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
    ),
    _HomeSlide(
      title: 'Raporlar ve Rutelar',
      subtitle: 'Ilerlemeni takip et',
      icon: Icons.timeline,
      colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _homeStats = _fetchHomeStats();
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _slides.isEmpty) return;
      _currentSlide = (_currentSlide + 1) % _slides.length;
      _sliderController.animateToPage(
        _currentSlide,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _sliderController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchHomeStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return {
        'totalScore': 0,
        'globalRank': '---',
        'diamonds': 0,
        'trophies': 0,
      };
    }

    try {
      final leaderboardService = getIt<LeaderboardService>();
      final firestore = FirebaseFirestore.instance;
      final totalScore = await leaderboardService.getUserTotalScore(user.uid);
      final globalRank = await leaderboardService.getUserGlobalRank(user.uid);
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      final diamonds = (userData['diamonds'] as num?)?.toInt() ?? 0;
      final badgesSnapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('badges')
          .get();
      final trophies = badgesSnapshot.docs.length;
      return {
        'totalScore': totalScore.toInt(),
        'globalRank': globalRank > 0 ? globalRank : '---',
        'diamonds': diamonds,
        'trophies': trophies,
      };
    } catch (e) {
      debugPrint('Ana sayfa istatistikleri yuklenemedi: $e');
      return {
        'totalScore': 0,
        'globalRank': '---',
        'diamonds': 0,
        'trophies': 0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    final fallbackName = user?.email?.split('@').first;
    final userName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : (fallbackName?.isNotEmpty == true ? fallbackName! : 'Oyunsever');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hoşgeldin $userName',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 18),
          FutureBuilder<Map<String, dynamic>>(
            future: _homeStats,
            builder: (context, snapshot) {
              final data = snapshot.data ?? {};
              final totalScore = (data['totalScore'] as int?) ?? 0;
              final globalRank = data['globalRank'] ?? '---';
              final diamonds = (data['diamonds'] as int?) ?? 0;
              final trophies = (data['trophies'] as int?) ?? 0;
              return Column(
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Genel Puan',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                totalScore.toString(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Global Sira',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '#$globalRank',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _HomeStatChip(
                          title: 'Elmas',
                          value: diamonds.toString(),
                          icon: Icons.diamond,
                          color: Colors.cyan.shade600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _HomeStatChip(
                          title: 'Kupa',
                          value: trophies.toString(),
                          icon: Icons.emoji_events,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),

            // Uygulama Logosu - Animated Sparkle Container
            _AnimatedSparkleBackground(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orangeAccent.withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orangeAccent.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(75),
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'NEMOS',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.deepOrange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Öğrenmenin oyun hali',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 170,
              child: PageView.builder(
                controller: _sliderController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentSlide = index;
                  });
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return AnimatedBuilder(
                    animation: _sliderController,
                    builder: (context, child) {
                      double scale = 1.0;
                      if (_sliderController.position.hasPixels) {
                        final page = _sliderController.page ?? _sliderController.initialPage.toDouble();
                        final diff = (page - index).abs();
                        scale = (1 - (diff * 0.08)).clamp(0.92, 1.0);
                      }
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: _HomeSlideCard(slide: slide),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                final isActive = index == _currentSlide;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.deepOrange : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
          Text(
            '👉 Oyunlar sekmesine kaydirarak gecin',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HomeSlide {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const _HomeSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}

class _HomeSlideCard extends StatelessWidget {
  final _HomeSlide slide;

  const _HomeSlideCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: slide.colors,
          ),
          boxShadow: [
            BoxShadow(
              color: slide.colors.last.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(slide.icon, size: 42, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                slide.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                slide.subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeStatChip extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _HomeStatChip({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
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

// 🤖 AI Page
class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  String _selectedOption = 'generate';

  @override
  Widget build(BuildContext context) {
    final geminiService = getIt<GeminiService>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Oyun Asistani'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // AI Başlık
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepOrange, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'Yapay Zekayla Oyun Yarat',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ceşitli oyun türlerini AI ile oluşturabilirsin',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFB0B0B0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Seçenekler
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ne yapmak istersin?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                _buildOptionCard(
                  title: '🎯 Oyun Oluştur',
                  description: 'AI ile yeni bir oyun fikirleri al',
                  selected: _selectedOption == 'generate',
                  onTap: () => setState(() => _selectedOption = 'generate'),
                ),
                const SizedBox(height: 10),
                _buildOptionCard(
                  title: '💡 Fikirler Al',
                  description: 'Oyun tasarımı hakkında tavsiyeleri öğren',
                  selected: _selectedOption == 'ideas',
                  onTap: () => setState(() => _selectedOption = 'ideas'),
                ),
                const SizedBox(height: 10),
                _buildOptionCard(
                  title: '📚 Öğren',
                  description: 'Oyun geliştirme hakkında bilgi edin',
                  selected: _selectedOption == 'learn',
                  onTap: () => setState(() => _selectedOption = 'learn'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Çalıştır Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_circle, size: 24),
                label: const Text(
                  'Başlat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bilgi Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade700),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.lightBlue),
                      SizedBox(width: 8),
                      Text(
                        'Açıklama',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.lightBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AI asistanı tarafından desteklenen bu sayfada oyun önerileri alabilir, tasarım tavsiyesi görebilir veya geliştirme hakkında bilgi edinebilirsin. Hayal gücünle sınırlı kalmayan oyunlar yarat!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String description,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected 
              ? Colors.deepOrange.withOpacity(0.15) 
              : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.deepOrange : const Color(0xFF444444),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB0B0B0),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.deepOrange : const Color(0xFF444444),
                  width: 2,
                ),
                color: selected ? Colors.deepOrange : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSelection() {
    String message;
    switch (_selectedOption) {
      case 'generate':
        message = 'Oyun oluştur seçeneği seçildi. Geliştirme aşamasında...';
        break;
      case 'ideas':
        message = 'Fikirler seçeneği seçildi. Geliştirme aşamasında...';
        break;
      case 'learn':
        message = 'Öğrenme seçeneği seçildi. Geliştirme aşamasında...';
        break;
      default:
        message = 'Bilinmeyen seçenek';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// 👤 Profile Page
class ProfilePage extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  const ProfilePage({Key? key, this.onThemeChanged}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isUploadingPhoto = false;
  String? _profilePhotoUrl;
  String? _selectedAvatarEmoji;
  bool _isSoundEnabled = true;
  final List<String> _avatarEmojis = [
    '😀', '😎', '🤓', '😍', '🎮', '🏆', '⚡', '🌟',
    '👨', '👩', '👨‍🦸', '👩‍🦸', '🦹', '💪', '🧙', '🧑‍💼',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
    _loadAvatarEmoji();
  }

  Future<void> _loadProfilePhoto() async {
    final firebaseService = getIt<FirebaseService>();
    final user = firebaseService.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final photoUrl = userDoc.data()?['photoURL'] as String?;
      if (mounted) {
        setState(() {
          _profilePhotoUrl = photoUrl ?? user.photoURL;
        });
      }
    } catch (e) {
      debugPrint('Profil fotografi yuklenemedi: $e');
    }
  }

  Future<void> _loadAvatarEmoji() async {
    final firebaseService = getIt<FirebaseService>();
    final user = firebaseService.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final emoji = userDoc.data()?['avatarEmoji'] as String?;
      if (mounted) {
        setState(() {
          _selectedAvatarEmoji = emoji;
        });
      }
    } catch (e) {
      debugPrint('Avatar emoji yuklenemedi: $e');
    }
  }

  Future<void> _updateAvatarEmoji(String emoji) async {
    final firebaseService = getIt<FirebaseService>();
    final user = firebaseService.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'avatarEmoji': emoji}, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _selectedAvatarEmoji = emoji;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karakter secildi')),
        );
      }
    } catch (e) {
      debugPrint('Avatar secimi hatasi: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  /// 🔴 Get real-time user stats stream
  Stream<Map<String, dynamic>> _getUserStatsStream() async* {
    final firebaseService = getIt<FirebaseService>();
    final userId = firebaseService.currentUser?.uid ?? 'unknown';
    
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Listen to users document for real-time totalScore
      yield* firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .asyncMap((userDoc) async {
        final userData = userDoc.data() ?? {};
        
        // Get totalScore from users collection (updated by atomic increment)
        final totalScore = (userData['totalScore'] as int?) ?? 0;
        
        // Get game scores for playCount, uniqueGames, and highestScore
        final scoresSnapshot = await firestore
            .collection('game_scores')
            .where('userId', isEqualTo: userId)
            .get();
        
        // Get badges
        final badgesSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('badges')
            .get();
        
        final scores = scoresSnapshot.docs;
        final playCount = scores.length;
        final uniqueGames = {...scores.map((doc) => doc['gameId'])}.length;
        final highestScore = scores.isEmpty 
            ? 0 
            : scores.map((doc) => (doc['score'] as int?) ?? 0).reduce((a, b) => a > b ? a : b);
        
        return {
          'totalScore': totalScore, // 🔴 Real-time from atomic increment
          'playCount': playCount,
          'uniqueGames': uniqueGames,
          'highestScore': highestScore,
          'globalRank': userData['globalRank'] ?? '---',
          'badges': badgesSnapshot.docs.map((d) => d.data()).toList(),
        };
      });
    } catch (e) {
      debugPrint('❌ Error - Istatistikler yuklenemedi: $e');
      // Return empty stats on error
      yield {
        'totalScore': 0,
        'playCount': 0,
        'uniqueGames': 0,
        'highestScore': 0,
        'globalRank': '---',
        'badges': <Map<String, dynamic>>[],
      };
    }
  }

  Future<void> _updateProfilePhoto() async {
    final firebaseService = getIt<FirebaseService>();
    final user = firebaseService.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/profile.jpg');

      final bytes = await picked.readAsBytes();
      await storageRef.putData(bytes);
      final downloadUrl = await storageRef.getDownloadURL();

      await user.updatePhotoURL(downloadUrl);
      await user.reload();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(
        {
          'photoURL': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (mounted) {
        setState(() {
          _profilePhotoUrl = downloadUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotografi guncellendi.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil fotografi yuklenemedi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = getIt<FirebaseService>();
    final user = firebaseService.currentUser;
    final userName = user?.displayName ?? 'Kullanıcı';
    final userEmail = user?.email ?? 'email@example.com';
    final photoUrl = _profilePhotoUrl ?? user?.photoURL;

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
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue.shade100,
                          backgroundImage: photoUrl != null
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null
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
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: InkWell(
                            onTap: _isUploadingPhoto ? null : _updateProfilePhoto,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: _isUploadingPhoto
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                            ),
                          ),
                        ),
                      ],
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
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _isUploadingPhoto ? null : _updateProfilePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Profil Fotografini Guncelle'),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Karakterini Sec',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: GridView.builder(
                        scrollDirection: Axis.horizontal,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _avatarEmojis.length,
                        itemBuilder: (context, index) {
                          final emoji = _avatarEmojis[index];
                          final isSelected = emoji == _selectedAvatarEmoji;
                          return GestureDetector(
                            onTap: () => _updateAvatarEmoji(emoji),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? Colors.deepOrange.withOpacity(0.2)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.deepOrange
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // İstatistikler (Firestore'dan - Real-Time)
            StreamBuilder<Map<String, dynamic>>(
              stream: _getUserStatsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final stats = snapshot.data ?? {};
                final badges = (stats['badges'] as List?) ?? [];
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
                        const SizedBox(height: 16),
                        const Text(
                          '🏅 Rozetler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (badges.isEmpty)
                          Text(
                            'Henuz rozetin yok. Oyun bitirerek kazanabilirsin.',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: badges.map<Widget>((badge) {
                              final name = badge['name'] ?? 'Rozet';
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.amber.shade300),
                                ),
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Ses Ayarları
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔊 Ses Ayarları',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sesleri Aç/Kapat',
                          style: TextStyle(fontSize: 14),
                        ),
                        Switch(
                          value: _isSoundEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isSoundEnabled = value;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value ? 'Sesler açıldı' : 'Sesler kapatıldı',
                                ),
                              ),
                            );
                          },
                          activeColor: Colors.deepOrange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Temalar ve Renkler
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎨 Tema Seçimi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              widget.onThemeChanged?.call(false);
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (mounted) {
                                  Navigator.of(context).pushReplacementNamed('/home');
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Açık tema seçildi')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              elevation: 2,
                              side: const BorderSide(color: Colors.grey),
                            ),
                            icon: const Icon(Icons.light_mode),
                            label: const Text('Açık'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              widget.onThemeChanged?.call(true);
                              Future.delayed(const Duration(milliseconds: 100), () {
                                if (mounted) {
                                  Navigator.of(context).pushReplacementNamed('/home');
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Koyu tema seçildi')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.dark_mode),
                            label: const Text('Koyu'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '🎮 Oyun Renkleri',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildColorButton('Turuncu', const Color(0xFFFF9500)),
                        _buildColorButton('Mor', const Color(0xFF7B1FA2)),
                        _buildColorButton('Mavi', const Color(0xFF1E88E5)),
                        _buildColorButton('Pembe', const Color(0xFFE91E63)),
                        _buildColorButton('Yeşil', const Color(0xFF00897B)),
                        _buildColorButton('Turkuaz', const Color(0xFF0097A7)),
                      ],
                    ),
                  ],
                ),
              ),
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

  Widget _buildColorButton(String label, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label rengi seçildi')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

//  🎆 Animated Sparkle Background Widget
class _AnimatedSparkleBackground extends StatefulWidget {
  final Widget child;

  const _AnimatedSparkleBackground({required this.child});

  @override
  State<_AnimatedSparkleBackground> createState() =>
      _AnimatedSparkleBackgroundState();
}

class _AnimatedSparkleBackgroundState extends State<_AnimatedSparkleBackground>
    with TickerProviderStateMixin {
  late List<_Sparkle> sparkles;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    sparkles = List.generate(
      8,
      (index) => _Sparkle(
        angle: (index * 360 / 8) * (3.14159 / 180),
        delay: (index * 0.15),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _SparklePainter(
                progress: _controller.value,
                sparkles: sparkles,
              ),
              child: SizedBox(
                width: 200,
                height: 200,
                child: widget.child,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _Sparkle {
  final double angle;
  final double delay;

  _Sparkle({required this.angle, required this.delay});
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final List<_Sparkle> sparkles;

  _SparklePainter({required this.progress, required this.sparkles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final sparkle in sparkles) {
      final adjustedProgress = (progress + sparkle.delay) % 1.0;
      final distance = 120 * adjustedProgress;
      final opacity = (1 - adjustedProgress).clamp(0.0, 1.0);

      final sparkleOffset = Offset(
        center.dx + distance * cos(sparkle.angle),
        center.dy + distance * sin(sparkle.angle),
      );

      final paint = Paint()
        ..color = Colors.amber.withOpacity(opacity * 0.8)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(sparkleOffset, (4.0 + 3.0 * opacity), paint);
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) => true;
}

