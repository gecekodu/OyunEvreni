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
import 'package:shared_preferences/shared_preferences.dart';
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
import 'config/app_theme.dart';
import 'core/services/gemini_game_service_v2.dart';
import 'features/flame_game/presentation/pages/flame_game_page.dart';
import 'features/ai_game_engine/presentation/pages/ai_game_creator_page.dart';
import 'features/ai_game_engine/data/services/ai_game_generator_service.dart';
import 'features/games/presentation/pages/example_games_list_page.dart';
import 'features/games/data/datasources/example_games_datasource.dart';
import 'features/games/domain/entities/example_game.dart';
import 'features/webview/presentation/pages/webview_page.dart';
import 'features/games/presentation/pages/leaderboard_page.dart';
import 'features/clan/presentation/pages/clan_page.dart';
import 'core/widgets/futuristic_animations.dart';

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
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Tema tercihlerini yüklerken hata: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    setState(() {
      _isDarkMode = isDark;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDark);
    } catch (e) {
      debugPrint('Tema kaydedilirken hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Nemos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthCheckScreen(),
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

/// 🔐 Auth Check Screen - Firebase Auth kontrol ve splash
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _LoginStreakResult {
  final int streak;
  final int reward;
  final bool rewardGranted;

  const _LoginStreakResult({
    required this.streak,
    required this.reward,
    required this.rewardGranted,
  });
}

class _AuthCheckScreenState extends State<AuthCheckScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _loginStreak = 0;
  late Animation<double> _fadeAnimation;
  final bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(_animationController);
    
    _animationController.forward();
    _checkAuthState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthState() async {
    // Splash ekranı 1.5 saniye göster
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Firebase Auth kontrol
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final result = await _updateLoginStreak(user.uid);
      if (!mounted) return;

      if (result != null && result.rewardGranted) {
        await _showLoginRewardDialog(result);
      }

      // User zaten giriş yapmış - Ana sayfaya git
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // User giriş yapmamış - Login sayfasına git
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<_LoginStreakResult?> _updateLoginStreak(String userId) async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await usersRef.get();
      if (!userDoc.exists) return null;

      final data = userDoc.data() ?? {};
      final lastLogin = data['lastLoginDate'] as Timestamp?;
      final currentStreak = (data['loginStreak'] as num?)?.toInt() ?? 0;
      final lastRewardDay = (data['lastStreakRewardDay'] as num?)?.toInt() ?? 0;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int newStreak;
      if (lastLogin == null) {
        newStreak = 1;
      } else {
        final last = lastLogin.toDate();
        final lastDay = DateTime(last.year, last.month, last.day);
        final diffDays = today.difference(lastDay).inDays;

        if (diffDays == 0) {
          return null;
        }

        newStreak = diffDays == 1 ? currentStreak + 1 : 1;
      }

      final milestoneBonus = <int, int>{
        7: 20,
        14: 40,
        30: 80,
      };
      final baseReward = 5;
      final bonus = milestoneBonus[newStreak] ?? 0;
      final totalReward = baseReward + bonus;
      final rewardGranted = newStreak != lastRewardDay;

      await usersRef.set({
        'loginStreak': newStreak,
        'lastLoginDate': Timestamp.fromDate(now),
        'lastStreakRewardDay': newStreak,
        if (rewardGranted) ...{
          'diamonds': FieldValue.increment(totalReward),
          'totalScore': FieldValue.increment(totalReward * 10),
        },
      }, SetOptions(merge: true));
      
      // State'i güncelle
      if (mounted) {
        setState(() {
          _loginStreak = newStreak;
        });
      }
      
      return _LoginStreakResult(
        streak: newStreak,
        reward: rewardGranted ? totalReward : 0,
        rewardGranted: rewardGranted,
      );
    } catch (e) {
      debugPrint('Giris serisi guncellenemedi: $e');
      return null;
    }
  }

  Future<void> _showLoginRewardDialog(_LoginStreakResult result) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎁 Giris Odulu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Serin: ${result.streak} gun'),
            const SizedBox(height: 8),
            Text('Odul: +${result.reward} elmas'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Harika!'),
          ),
        ],
      ),
    );
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
              const Color(0xFFFFF7E6),
              const Color(0xFFFFE7C7),
              const Color(0xFFFFD9A6),
              const Color(0xFFFFEFD0),
              const Color(0xFFFFF3DC),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🎮 Logo with Pulsing Animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final pulse = 0.8 + 0.2 * sin(_animationController.value * pi * 2);
                    return Transform.scale(
                      scale: pulse,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFFC46B).withOpacity(0.9),
                              const Color(0xFFFF8A00).withOpacity(0.7),
                              const Color(0xFFFF9AD5).withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB65C).withOpacity(0.5),
                              blurRadius: 30 * pulse,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: const Color(0xFFFF9AD5).withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.jpeg',
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                
                // Futuristic Title with Glitch Effect
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final offset = sin(_animationController.value * pi * 2) * 2;
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: Text(
                        'NEMOS',
                        style: TextStyle(
                          color: const Color(0xFFFF7A00),
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFFB65C).withOpacity(0.6),
                              blurRadius: 30,
                              offset: const Offset(0, 0),
                            ),
                            Shadow(
                              color: const Color(0xFF4DB6FF).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(-2, 0),
                            ),
                            Shadow(
                              color: const Color(0xFFFF9AD5).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(2, 0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                
                // Subtitle with Animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final opacity = 0.5 + 0.5 * sin(_animationController.value * pi * 2);
                    return Opacity(
                      opacity: opacity,
                      child: Text(
                        'Eğitici Oyun Platformu',
                        style: TextStyle(
                          color: const Color(0xFF6B4C1A),
                          fontSize: 15,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50),
                
                // Animated Progress Bar with Gradient
                SizedBox(
                  width: 220,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Stack(
                              children: [
                                // Background
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFE2B7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                // Animated Fill
                                Container(
                                  height: 8,
                                  width: 220 * _animationController.value,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFFC46B),
                                        const Color(0xFFFF8A00),
                                        const Color(0xFF4DB6FF),
                                        const Color(0xFF7ED957),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFB65C).withOpacity(0.5),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Percentage Text
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final percentage = (_animationController.value * 100).toInt();
                          return Text(
                            '$percentage%',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Orbiting Loading Dots
                SizedBox(
                  width: 60,
                  height: 60,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Rotating circle background
                          Transform.rotate(
                            angle: _animationController.value * pi * 2,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.deepOrange.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          // Orbiting dots
                          for (int i = 0; i < 3; i++)
                            Transform.rotate(
                              angle: (_animationController.value * pi * 2) + (i * 2 * pi / 3),
                              child: Positioned(
                                right: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: [
                                      Colors.deepOrange,
                                      Colors.purple,
                                      Colors.cyan,
                                    ][i],
                                    boxShadow: [
                                      BoxShadow(
                                        color: [
                                          Colors.deepOrange,
                                          Colors.purple,
                                          Colors.cyan,
                                        ][i].withOpacity(0.6),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
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
                backgroundColor: const Color(0xFFFFF2D9),
                indicatorColor: const Color(0xFFFFB65C),
                labelTextStyle: WidgetStateProperty.all(
                  const TextStyle(color: Color(0xFF6B4C1A), fontSize: 12),
                ),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final color = states.contains(WidgetState.selected)
                      ? const Color(0xFF2C200F)
                      : const Color(0xFF6B4C1A);
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
        color: const Color(0xFFFFB65C),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB65C).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF2C200F), size: 20),
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
                colors: [Color(0xFFFFC46B), Color(0xFFFF8A00)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB65C).withOpacity(0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF2C200F), size: 28),
          )
        : Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFC46B).withOpacity(0.7),
                  const Color(0xFFFF8A00).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB65C).withOpacity(0.3),
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
        color: const Color(0xFFFFB65C),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB65C).withOpacity(0.4),
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
                : const Icon(Icons.person, color: Color(0xFF2C200F), size: 20)),
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
  late Future<Map<String, dynamic>> _homeStats;

  @override
  void initState() {
    super.initState();
    _homeStats = _fetchHomeStats();
  }

  Future<void> _openExampleGame(ExampleGameType type) async {
    final datasource = ExampleGamesDatasourceImpl();
    final game = await datasource.getExampleByType(type);
    if (game == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oyun bulunamadı')),
        );
      }
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          gameTitle: game.title,
          htmlPath: game.htmlContent,
          gameId: game.id,
        ),
      ),
    );
  }

  @override
  void dispose() {
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
    final photoUrl = user?.photoURL;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A3E),
              Color(0xFF0F1B3D),
              Color(0xFF1E1E3F),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo + Profil Row
            Row(
              children: [
                // Logo
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF00D4FF),
                        Color(0xFF8BFF6B),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF00D4FF).withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Spacer(),
                // Profil Resmi
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Color(0xFF00D4FF),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00D4FF).withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photoUrl != null && photoUrl.isNotEmpty
                          ? Image.network(
                              photoUrl,
                              width: 45,
                              height: 45,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Color(0xFF2D3561),
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFF00D4FF),
                                    size: 24,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Color(0xFF2D3561),
                              child: Center(
                                child: Text(
                                  userName.isNotEmpty ? userName[0].toUpperCase() : 'K',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00D4FF),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Hoşgeldin Mesajı
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Merhaba $userName',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '🎮 Hangi oyunu oynayacaksın?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFB9D8FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FutureBuilder<Map<String, dynamic>>(
              future: _homeStats,
              builder: (context, snapshot) {
                final data = snapshot.data ?? {};
                final totalScore = (data['totalScore'] as int?) ?? 0;
                final globalRank = data['globalRank'] ?? '---';
                final diamonds = (data['diamonds'] as int?) ?? 0;
                final trophies = (data['trophies'] as int?) ?? 0;
                final progress = (totalScore / 10000).clamp(0.0, 1.0);

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1E3A8A),
                            Color(0xFF0EA5E9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Color(0xFF00D4FF),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Toplam Skor',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  totalScore.toString(),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Color(0xFF00D4FF),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Sıra: #$globalRank',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _HomeProgressRing(
                            value: progress,
                            label: '${(progress * 100).round()}%',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _HomeStatChip(
                            title: 'Elmas',
                            value: diamonds.toString(),
                            icon: Icons.diamond,
                            color: const Color(0xFF00D4FF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HomeStatChip(
                            title: 'Kupa',
                            value: trophies.toString(),
                            icon: Icons.emoji_events,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            
            // 🔥 Giriş Serisi Widget'ı
            if (_loginStreak > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Giriş Serisi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_loginStreak Gün Üst Üste!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '🔥',
                      style: TextStyle(fontSize: 32),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _HomeActionCard(
                    title: 'Oyunlar',
                    icon: Icons.sports_esports,
                    colors: const [Color(0xFFFF4D9A), Color(0xFFFF8AC1)],
                    onTap: () => Navigator.pushNamed(context, '/example-games'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HomeActionCard(
                    title: 'Klan',
                    icon: Icons.groups,
                    colors: const [Color(0xFF8BFF6B), Color(0xFFB4FF9A)],
                    onTap: () => Navigator.pushNamed(context, '/clan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.stars, color: Color(0xFFFFD700), size: 24),
                SizedBox(width: 8),
                Text(
                  'Önerilen Oyunlar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _HomeMiniCard(
              title: 'Gezegen Bul',
              subtitle: 'Uzay macerası başlasın! 🚀',
              icon: Icons.public,
              colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              onTap: () => _openExampleGame(ExampleGameType.planetHunt),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeProgressRing extends StatelessWidget {
  final double value;
  final String label;

  const _HomeProgressRing({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 10,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8BFF6B)),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF00D4FF).withOpacity(0.2),
                  Color(0xFF8BFF6B).withOpacity(0.2),
                ],
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E2B4F),
            Color(0xFF2D3561),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _HomeActionCard({
    required this.title,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeMiniCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  const _HomeMiniCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Oyun Asistani'),
        centerTitle: true,
      ),
      body: WaveBackground(
        color1: const Color(0xFF0F1027),
        color2: const Color(0xFF1B2B6E),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // AI Başlık
              GlowContainer(
                glowColor: colorScheme.primary.withOpacity(0.6),
                blurRadius: 26,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.35),
                        colorScheme.secondary.withOpacity(0.35),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.primary, width: 2),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'Yapay Zekayla Oyun Yarat',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF5FBFF),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cesitli oyun turlerini AI ile olusturabilirsin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFB9D8FF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Seçenekler
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ne yapmak istersin?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOptionCard(
                    title: '🎯 Oyun Olustur',
                    description: 'AI ile yeni oyun fikirleri al',
                    selected: _selectedOption == 'generate',
                    onTap: () => setState(() => _selectedOption = 'generate'),
                  ),
                  const SizedBox(height: 10),
                  _buildOptionCard(
                    title: '💡 Fikirler Al',
                    description: 'Tasarim tavsiyelerini kesfet',
                    selected: _selectedOption == 'ideas',
                    onTap: () => setState(() => _selectedOption = 'ideas'),
                  ),
                  const SizedBox(height: 10),
                  _buildOptionCard(
                    title: '📚 Ogren',
                    description: 'Oyun gelistirme bilgisini arttir',
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
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.play_circle, size: 24),
                  label: const Text(
                    'Baslat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bilgi Kartı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF122049).withOpacity(0.9),
                      const Color(0xFF1F2F6B).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.secondary, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF6BD6FF)),
                        SizedBox(width: 8),
                        Text(
                          'Aciklama',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF6BD6FF),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'AI asistani bu sayfada oyun onerileri, tasarim tavsiyesi ve gelistirme notlari uretir. Hayal gucunle sinirli kalmayan oyunlar yarat!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFB9D8FF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selected
                ? [const Color(0xFF1E3A8A), const Color(0xFF0EA5E9)]
                : [const Color(0xFF1B244A), const Color(0xFF141A3A)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF6BD6FF) : const Color(0xFF26305C),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6BD6FF).withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
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
                      color: Color(0xFFF5FBFF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFB9D8FF),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? const Color(0xFF6BD6FF) : const Color(0xFF46518A),
                  width: 2,
                ),
                color: selected ? const Color(0xFF00D4FF) : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSelection() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.construction, color: Colors.orange, size: 22),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Geliştirme Aşamasında',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rocket_launch, size: 64, color: Color(0xFF00D4FF)),
            SizedBox(height: 16),
            Text(
              'AI Oyun Asistanı yakında sizlerle!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Bu özellik üzerinde çalışıyoruz. Çok yakında kullanıma açılacak.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

// 👤 Profile Page
class ProfilePage extends StatefulWidget {
  final Function(bool)? onThemeChanged;
  const ProfilePage({super.key, this.onThemeChanged});

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
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı girişi yapılmamış')),
        );
      }
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (picked == null) return;

      if (mounted) {
        setState(() {
          _isUploadingPhoto = true;
        });
      }

      // Firebase Storage referansı
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_photos')
          .child('${user.uid}_$timestamp.jpg');

      // Resmi yükle
      final bytes = await picked.readAsBytes();
      final uploadTask = await storageRef.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'userId': user.uid},
        ),
      );

      // Download URL al
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Firebase Auth profil resmini güncelle
      await user.updatePhotoURL(downloadUrl);
      await user.reload();

      // Firestore'a kaydet
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
          const SnackBar(
            content: Text('✅ Profil fotoğrafı güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Profil fotoğrafı yükleme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: Fotoğraf yüklenemedi. Lütfen tekrar deneyin.'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Tekrar Dene',
              textColor: Colors.white,
              onPressed: _updateProfilePhoto,
            ),
          ),
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
    String userName = 'Kullanıcı';
    final userEmail = user?.email ?? 'email@example.com';
    final photoUrl = _profilePhotoUrl ?? user?.photoURL;

    return Scaffold(
      appBar: AppBar(title: const Text('👤 Profilim'), centerTitle: true),
      body: StreamBuilder<DocumentSnapshot>(
        stream: user != null
            ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
            : null,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data?.data() != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            userName = userData['username'] ?? userData['displayName'] ?? user?.displayName ?? 'Kullanıcı';
          } else {
            userName = user?.displayName ?? 'Kullanıcı';
          }
          
          return SingleChildScrollView(
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
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'serif',
                        color: Color(0xFF2C200F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'serif',
                        color: Color(0xFF6B4C1A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _isUploadingPhoto ? null : _updateProfilePhoto,
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Fotoğraf', style: TextStyle(fontSize: 12)),
                        ),
                        SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _showEditUsernameDialog(context, user?.uid, userName),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Kullanıcı Adı', style: TextStyle(fontSize: 12)),
                        ),
                      ],
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
                                    ? const Color(0xFFFFC300).withOpacity(0.2)
                                    : const Color(0xFF241B45),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFFFC300)
                                      : Colors.white24,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
                            color: const Color(0xFF2A214A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '🏆 Global Sıralama',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '#${stats['globalRank'] ?? '---'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFC300),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A214A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '⭐ Yüksek Skor',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${stats['highestScore'] ?? 0}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFC300),
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
                          activeThumbColor: Colors.deepOrange,
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
        );
        },
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

  Future<void> _showEditUsernameDialog(BuildContext context, String? userId, String currentUsername) async {
    if (userId == null) return;
    
    final usernameController = TextEditingController(text: currentUsername);
    final formKey = GlobalKey<FormState>();
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Kullanıcı Adını Değiştir'),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: 'Yeni Kullanıcı Adı',
              hintText: 'Örn: oyuncu123',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kullanıcı adı boş olamaz';
              }
              if (value.length < 3) {
                return 'En az 3 karakter olmalı';
              }
              if (value.length > 20) {
                return 'En fazla 20 karakter olmalı';
              }
              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                return 'Sadece harf, rakam ve _ kullanın';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({
                    'username': usernameController.text.trim(),
                    'displayName': usernameController.text.trim(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('✅ Kullanıcı adı güncellendi!'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Kaydet'),
          ),
        ],
      ),
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

