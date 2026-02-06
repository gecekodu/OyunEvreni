// 🎮 OYUN OLUSTUR - Eğitici Oyun Platformu
// Flutter + Firebase + Gemini AI + HTML Games

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'core/services/firebase_service.dart';
import 'core/services/gemini_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/games/data/datasources/games_remote_datasource.dart';
import 'features/ai/data/datasources/ai_remote_datasource.dart';

// GetIt - Dependency Injection
final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase başlat
  final firebaseService = FirebaseService();
  await firebaseService.initialize();

  // 🤖 Gemini API başlat
  // ⚠️ ZORUNLU: https://ai.google.dev/tutorials/setup adresinden API key al
  const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  final geminiService = GeminiService(apiKey: geminiApiKey);

  // 📦 Dependency Injection setup
  _setupDependencies(firebaseService, geminiService);

  runApp(const MyApp());
}

/// 🔧 Tüm service'leri register et
void _setupDependencies(
    FirebaseService firebaseService, GeminiService geminiService) {
  // Core Services
  getIt.registerSingleton<FirebaseService>(firebaseService);
  getIt.registerSingleton<GeminiService>(geminiService);

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
      title: '🎮 Oyun Olustur',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/createGame': (context) => const CreateGamePage(),
        '/profile': (context) => const ProfilePage(),
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

    final firebaseService = getIt<FirebaseService>();
    if (firebaseService.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
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
              const Text(
                '🎮',
                style: TextStyle(fontSize: 80),
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

// 🔐 Login Page
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: const Center(child: Text('Login Sayfası')),
    );
  }
}

// 📝 Signup Page
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kaydol')),
      body: const Center(child: Text('Signup Sayfası')),
    );
  }
}

// 🏠 Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: const Center(child: Text('Home Sayfası')),
    );
  }
}

// ➕ Create Game Page
class CreateGamePage extends StatelessWidget {
  const CreateGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyun Oluştur')),
      body: const Center(child: Text('Create Game Sayfası')),
    );
  }
}

// 👤 Profile Page
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(child: Text('Profile Sayfası')),
    );
  }
}
