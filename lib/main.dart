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

class _AuthCheckScreenState extends State<AuthCheckScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
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
      await _updateLoginStreak(user.uid);
      // User zaten giriş yapmış - Ana sayfaya git
      if (mounted) Navigator.of(context).pushReplacementNamed('/home');
    } else {
      // User giriş yapmamış - Login sayfasına git
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _updateLoginStreak(String userId) async {
    try {
      final usersRef = FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await usersRef.get();
      if (!userDoc.exists) return;

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
          return;
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

      await usersRef.set({
        'loginStreak': newStreak,
        'lastLoginDate': Timestamp.fromDate(now),
        'lastStreakRewardDay': newStreak,
        if (newStreak != lastRewardDay) ...{
          'diamonds': FieldValue.increment(totalReward),
          'totalScore': FieldValue.increment(totalReward * 10),
        },
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Giris serisi guncellenemedi: $e');
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
              const Color(0xFF1B1532),
              const Color(0xFF211A3D),
              const Color(0xFF2A214A),
              const Color(0xFF3B2B6F),
              const Color(0xFF1E1638),
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
                              const Color(0xFFFFC300).withOpacity(0.9),
                              const Color(0xFFFF8A00).withOpacity(0.7),
                              const Color(0xFF6C5CE7).withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC300).withOpacity(0.5),
                              blurRadius: 30 * pulse,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: const Color(0xFF6C5CE7).withOpacity(0.4),
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
                          color: const Color(0xFFFFC300),
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFFC300).withOpacity(0.6),
                              blurRadius: 30,
                              offset: const Offset(0, 0),
                            ),
                            Shadow(
                              color: const Color(0xFF6C5CE7).withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(-2, 0),
                            ),
                            Shadow(
                              color: const Color(0xFFFF8A00).withOpacity(0.5),
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
                          color: Colors.white70,
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
                                    color: Colors.white.withOpacity(0.12),
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
                                        const Color(0xFFFFC300),
                                        const Color(0xFFFF8A00),
                                        const Color(0xFF6C5CE7),
                                        const Color(0xFF4DD6FF),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFC300).withOpacity(0.5),
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
                backgroundColor: const Color(0xFF211A3D),
                indicatorColor: const Color(0xFFFFC300),
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
        color: const Color(0xFFFFC300),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC300).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF1B1532), size: 20),
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
                colors: [Color(0xFFFFC300), Color(0xFFFF8A00)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC300).withOpacity(0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF1B1532), size: 28),
          )
        : Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFC300).withOpacity(0.7),
                  const Color(0xFFFF8A00).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC300).withOpacity(0.3),
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
        color: const Color(0xFFFFC300),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC300).withOpacity(0.4),
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
                : const Icon(Icons.person, color: Color(0xFF1B1532), size: 20)),
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

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1638),
              Color(0xFF221A40),
              Color(0xFF2A1F4D),
              Color(0xFF1B1532),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merhaba $userName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Bugun hangi oyunu kesfedecegiz?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF2A214A),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.jpeg',
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2C214F),
                            Color(0xFF1F173B),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Toplam Skor',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  totalScore.toString(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFC300),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Global sira: #$globalRank',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _HomeStatChip(
                            title: 'Elmas',
                            value: diamonds.toString(),
                            icon: Icons.diamond,
                            color: const Color(0xFF4DD6FF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _HomeStatChip(
                            title: 'Kupa',
                            value: trophies.toString(),
                            icon: Icons.emoji_events,
                            color: const Color(0xFFFFC300),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6C5CE7),
                    Color(0xFF3D2E7C),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Yeni hedef',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '5 oyun oynayip bonus kazan!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/example-games'),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC300),
                      foregroundColor: const Color(0xFF1B1532),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Oyna'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hizli erisim',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _HomeActionCard(
                    title: 'Oyunlar',
                    icon: Icons.sports_esports,
                    colors: const [Color(0xFFFF8A00), Color(0xFFFFC300)],
                    onTap: () => Navigator.pushNamed(context, '/example-games'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HomeActionCard(
                    title: 'Siralama',
                    icon: Icons.emoji_events,
                    colors: const [Color(0xFF4DD6FF), Color(0xFF6C5CE7)],
                    onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HomeActionCard(
                    title: 'Klan',
                    icon: Icons.groups,
                    colors: const [Color(0xFF48D597), Color(0xFF2CB67D)],
                    onTap: () => Navigator.pushNamed(context, '/clan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Öneriler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _HomeMiniCard(
                  title: 'Gezegen Bul',
                  subtitle: 'Uzay macerasi',
                  icon: Icons.extension,
                  colors: const [Color(0xFF3B2B6F), Color(0xFF6C5CE7)],
                  onTap: () => _openExampleGame(ExampleGameType.planetHunt),
                ),
                _HomeMiniCard(
                  title: 'Skor',
                  subtitle: 'En iyiler',
                  icon: Icons.show_chart,
                  colors: const [Color(0xFF2C3E50), Color(0xFF4DD6FF)],
                  onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                ),
                _HomeMiniCard(
                  title: 'AI Oyun',
                  subtitle: 'Kendi oyunun',
                  icon: Icons.smart_toy,
                  colors: const [Color(0xFF3E1F47), Color(0xFFFF6FB1)],
                  onTap: () => Navigator.pushNamed(context, '/ai-game-creator'),
                ),
                _HomeMiniCard(
                  title: 'Profil',
                  subtitle: 'Ilerlemeni gormek',
                  icon: Icons.person,
                  colors: const [Color(0xFF20304A), Color(0xFF48D597)],
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
              ],
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
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 8,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFC300)),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A214A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: (MediaQuery.of(context).size.width - 52) / 2,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.3),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 11,
              ),
            ),
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

