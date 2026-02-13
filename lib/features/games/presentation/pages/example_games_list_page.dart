import 'package:flutter/material.dart';
import '../../data/datasources/example_games_datasource.dart';
import '../../data/repositories/example_games_repository_impl.dart';
import '../../domain/entities/example_game.dart';
import '../../../webview/presentation/pages/webview_page.dart';

class ExampleGamesListPage extends StatefulWidget {
  const ExampleGamesListPage({super.key});

  @override
  State<ExampleGamesListPage> createState() => _ExampleGamesListPageState();
}

class _ExampleGamesListPageState extends State<ExampleGamesListPage> {
  late final ExampleGamesRepository _repository;
  List<ExampleGame> _games = [];
  bool _isLoading = true;
  final Set<int> _pressedCards = {};

  @override
  void initState() {
    super.initState();
    _repository = ExampleGamesRepositoryImpl(
      datasource: ExampleGamesDatasourceImpl(),
    );
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final games = await _repository.getAllExamples();
      if (!mounted) return;
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Oyunlar yüklenemedi: $e')),
        );
      }
    }
  }

  void _launchGame(ExampleGame game) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎮 Oyunlar'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black87,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF9500),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Eğlenceli Oyunlar Seni Bekliyor! 🎯',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _games.length) return SizedBox.shrink();
                        final game = _games[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: _buildGameCard(game, index),
                        );
                      },
                      childCount: _games.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGameCard(ExampleGame game, int index) {
    final isPressed = _pressedCards.contains(index);
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressedCards.add(index)),
        onTapCancel: () => setState(() => _pressedCards.remove(index)),
        onTapUp: (_) => setState(() => _pressedCards.remove(index)),
        child: InkWell(
          onTap: () => _launchGame(game),
          splashColor: Colors.white.withOpacity(0.4),
          highlightColor: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getGradientColors(game.type),
              ),
            ),
            child: Stack(
              children: [
                // Oyun görseli
                if (game.imagePath != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        game.imagePath!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                // Dokunma efekti
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: isPressed ? 1 : 0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                ),

                // Kategori etiketi (sol taraf dikey)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      border: Border(
                        right: BorderSide(
                          color: Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          game.category.toUpperCase(),
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(ExampleGameType type) {
    switch (type) {
      case ExampleGameType.friction:
        return [Color(0xFFFF9500), Color(0xFFFF6B35)]; // Turuncu
      case ExampleGameType.tetris:
        return [Color(0xFFFFA500), Color(0xFFFF8C00)]; // Turuncu-sarı
      case ExampleGameType.memory:
        return [Color(0xFF1E88E5), Color(0xFF42A5F5)]; // Mavi
      case ExampleGameType.colorMatch:
        return [Color(0xFFE91E63), Color(0xFFC2185B)]; // Pembe-mor
      case ExampleGameType.mathQuiz:
        return [Color(0xFF7B1FA2), Color(0xFF9C27B0)]; // Mor
      case ExampleGameType.wordChain:
        return [Color(0xFF0097A7), Color(0xFF0288D1)]; // Turkuaz
      case ExampleGameType.planetHunt:
        return [Color(0xFF00897B), Color(0xFF26A69A)]; // Yeşil
      case ExampleGameType.survival:
        return [Color(0xFF558B2F), Color(0xFF7CB342)]; // Orman yeşili
    }
  }
}
