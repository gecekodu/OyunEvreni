// 🗺️ Uygulama Routes - Sayfa Navigasyonu

import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String createGame = '/createGame';
  static const String gameDetails = '/gameDetails';
  static const String playGame = '/playGame';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case createGame:
        return MaterialPageRoute(builder: (_) => const CreateGamePage());
      case playGame:
        final gameId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => PlayGamePage(gameId: gameId),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Sayfa bulunamadı: ${settings.name}'),
            ),
          ),
        );
    }
  }
}

// 🔐 Login Page Placeholder
class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş Yap')),
      body: const Center(child: Text('Login Sayfası')),
    );
  }
}

// 📝 Signup Page Placeholder
class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kaydol')),
      body: const Center(child: Text('Signup Sayfası')),
    );
  }
}

// 🏠 Home Page Placeholder
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ana Sayfa')),
      body: const Center(child: Text('Home Sayfası')),
    );
  }
}

// ➕ Create Game Page Placeholder
class CreateGamePage extends StatelessWidget {
  const CreateGamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyun Oluştur')),
      body: const Center(child: Text('Create Game Sayfası')),
    );
  }
}

// ▶️ Play Game Page Placeholder
class PlayGamePage extends StatelessWidget {
  final String gameId;

  const PlayGamePage({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oynu Oyna')),
      body: Center(child: Text('Game ID: $gameId')),
    );
  }
}

// 👤 Profile Page Placeholder
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const Center(child: Text('Profile Sayfası')),
    );
  }
}
