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
  String? _selectedDifficulty = 'all';
  List<ExampleGame> _filteredGames = [];

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
        _filteredGames = games;
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

  void _filterByDifficulty(String difficulty) {
    setState(() => _selectedDifficulty = difficulty);

    if (difficulty == 'all') {
      setState(() => _filteredGames = _games);
    } else if (difficulty == 'easy') {
      setState(() => _filteredGames = _games.where((g) => g.difficulty < 0.4).toList());
    } else if (difficulty == 'medium') {
      setState(() => _filteredGames = _games.where((g) => g.difficulty >= 0.4 && g.difficulty < 0.7).toList());
    } else if (difficulty == 'hard') {
      setState(() => _filteredGames = _games.where((g) => g.difficulty >= 0.7).toList());
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
        title: Text('Örnek Oyunlar'),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667EEA),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zorluk Seviyesi Seç',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _difficultyChip('Tümü', 'all'),
                              SizedBox(width: 8),
                              _difficultyChip('Kolay', 'easy'),
                              SizedBox(width: 8),
                              _difficultyChip('Orta', 'medium'),
                              SizedBox(width: 8),
                              _difficultyChip('Zor', 'hard'),
                            ],
                          ),
                        ),
                      ],
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
                        if (index >= _filteredGames.length) return SizedBox.shrink();
                        final game = _filteredGames[index];
                        return _buildGameCard(game);
                      },
                      childCount: _filteredGames.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _difficultyChip(String label, String value) {
    final isSelected = _selectedDifficulty == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _filterByDifficulty(value),
      backgroundColor: Colors.grey[200],
      selectedColor: Color(0xFF667EEA),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildGameCard(ExampleGame game) {
    return GestureDetector(
      onTap: () => _launchGame(game),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getGradientColors(game.type),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.type.emoji,
                      style: TextStyle(fontSize: 32),
                    ),
                    SizedBox(height: 8),
                    Text(
                      game.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            game.difficultyLabel,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          '${game.minAge}-${game.maxAge}+',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Oyna ▶',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

  List<Color> _getGradientColors(ExampleGameType type) {
    switch (type) { // planetHunt vb. yeni types için 
      case ExampleGameType.friction:
        return [Color(0xFF667EEA), Color(0xFF764BA2)];
      case ExampleGameType.tetris:
        return [Color(0xFFF093FB), Color(0xFFF5576C)];
      case ExampleGameType.memory:
        return [Color(0xFF4FACFE), Color(0xFF00F2FE)];
      case ExampleGameType.colorMatch:
        return [Color(0xFFFA709A), Color(0xFFFECE34)];
      case ExampleGameType.mathQuiz:
        return [Color(0xFF30CFD0), Color(0xFF330867)];
      case ExampleGameType.wordChain:
        return [Color(0xFFA8EDEA), Color(0xFFFED6E3)];
      case ExampleGameType.planetHunt:
        return [Color(0xFF667EEA), Color(0xFFFF6B9D)];
    }
  }
}
