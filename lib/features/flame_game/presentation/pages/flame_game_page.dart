// 📱 FLAME GAME PAGE - Flutter Sayfası
// Flame oyununu Flutter'a embed etme

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../data/game/main_game.dart';
import '../../domain/entities/game_constants.dart';

class FlameGamePage extends StatefulWidget {
  const FlameGamePage({Key? key}) : super(key: key);

  @override
  State<FlameGamePage> createState() => _FlameGamePageState();
}

class _FlameGamePageState extends State<FlameGamePage> {
  late FlappyGame gameInstance;
  int currentScore = 0;

  @override
  void initState() {
    super.initState();

    // Oyun instance'ı oluştur
    gameInstance = FlappyGame(
      onGameOver: () {
        _showGameOverDialog();
      },
      onScoreChanged: (score) {
        setState(() {
          currentScore = score;
        });
      },
    );

    print('📱 Game page initialized');
  }

  /// 💀 Game Over Dialog
  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('💀 Oyun Bitti!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Puan: ${gameInstance.gameStats.score}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Geçilen Engeller: ${gameInstance.gameStats.obstaclesPassed}'),
            Text('Zaman: ${gameInstance.gameStats.gameDuration?.inSeconds}s'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentScore = 0;
              });
              gameInstance.startGame();
            },
            child: const Text('Tekrar Oyna'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Önceki sayfaya dön
            },
            child: const Text('Ana Menüye Dön'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Flappy Game - Flame Engine'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Score badge
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '📊 Skor',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    '${gameInstance.gameStats.score}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🎮 Flame Oyun Widget
          GameWidget(
            game: gameInstance,
            textDirection: TextDirection.ltr,
            loadingBuilder: (context) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Oyun Yükleniyor...'),
                ],
              ),
            ),
          ),

          // 🎮 Oyun Talimatları (Overlay)
          if (gameInstance.gameState == GameState.idle)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        '👆 Ekrana Dokunarak Zıpla',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '🚧 Kırmızı engellere çarpma!',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameInstance.pauseEngine();
    super.dispose();
  }
}
