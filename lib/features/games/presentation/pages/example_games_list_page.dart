import 'package:flutter/material.dart';
import '../../data/datasources/example_games_datasource.dart';
import '../../data/repositories/example_games_repository_impl.dart';
import '../../domain/entities/example_game.dart';
import '../../../webview/presentation/pages/webview_page.dart';

class ExampleGamesListPage extends StatefulWidget {
  const ExampleGamesListPage({Key? key}) : super(key: key);

  @override
  State<ExampleGamesListPage> createState() => _ExampleGamesListPageState();
}

class _ExampleGamesListPageState extends State<ExampleGamesListPage> {
  late final ExampleGamesRepository _repository;
  List<ExampleGame> _games = [];
  bool _isLoading = true;

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
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
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
        foregroundColor: Colors.black87,
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
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= _games.length) return SizedBox.shrink();
                        final game = _games[index];
                        return _buildGameCard(game);
                      },
                      childCount: _games.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildGameCard(ExampleGame game) {
    return GestureDetector(
      onTap: () => _launchGame(game),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
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
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.type.emoji,
                          style: TextStyle(fontSize: 40),
                        ),
                        SizedBox(height: 12),
                        Text(
                          game.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '🎮 OYNA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
    }
  }
}
