// 📱 SOSYAL AKIŞ SAYFASI - HTML + AI Oyunlar

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/services/social_feed_service.dart';
import '../../domain/entities/game_models.dart';
import '../../domain/entities/game_score.dart';
import '../../../../core/widgets/futuristic_animations.dart';
import '../../../../core/services/ai_game_social_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../ai_game_engine/data/game/dynamic_ai_game.dart';
import '../../../webview/presentation/pages/webview_page.dart';
import 'package:flame/game.dart' show GameWidget;
import 'play_game_simple.dart';

class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({super.key});

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _htmlTabController;
  late TabController _aiTabController;
  final _feedService = SocialFeedService();
  final _aiSocialService = AIGameSocialService();

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 2, vsync: this);
    _htmlTabController = TabController(length: 4, vsync: this);
    _aiTabController = TabController(length: 3, vsync: this);
    
    // Türkçe timeago
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _htmlTabController.dispose();
    _aiTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar.large(
            floating: true,
            snap: true,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sosyal Akış 🌐',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Topluluk oyunlarını keşfet',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _mainTabController,
              tabs: const [
                Tab(icon: Icon(Icons.auto_awesome), text: 'AI Oyunlar'),
                Tab(icon: Icon(Icons.code), text: 'HTML Oyunlar'),
              ],
            ),
          ),

          // Tab İçeriği
          SliverFillRemaining(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                _buildAIGamesSection(),
                _buildHTMLGamesSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== AI OYUNLAR BÖLÜMÜ ==========
  Widget _buildAIGamesSection() {
    return Column(
      children: [
        TabBar(
          controller: _aiTabController,
          tabs: const [
            Tab(icon: Icon(Icons.explore), text: 'Keşfet'),
            Tab(icon: Icon(Icons.star), text: 'Popüler'),
            Tab(icon: Icon(Icons.person), text: 'Benim'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _aiTabController,
            children: [
              _buildAIExploreFeed(),
              _buildAIPopularFeed(),
              _buildMyAIGamesFeed(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIExploreFeed() {
    return StreamBuilder<List<SharedAIGame>>(
      stream: _aiSocialService.getGameFeed(limit: 50),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final games = snapshot.data ?? [];

        if (games.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.games, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  'Henüz paylaşılan oyun yok',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/ai-game-creator');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('İlk oyunu sen oluştur!'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: games.length,
          itemBuilder: (context, index) => _buildAIGameCard(games[index]),
        );
      },
    );
  }

  Widget _buildAIPopularFeed() {
    return StreamBuilder<List<SharedAIGame>>(
      stream: _aiSocialService.getPopularGames(limit: 20),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final games = snapshot.data ?? [];

        if (games.isEmpty) {
          return const Center(child: Text('Popüler oyun bulunamadı'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return _buildAIGameCard(games[index], showRank: true, rank: index + 1);
          },
        );
      },
    );
  }

  Widget _buildMyAIGamesFeed() {
    final userId = FirebaseService().currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Lütfen giriş yapın'));
    }

    return StreamBuilder<List<SharedAIGame>>(
      stream: _aiSocialService.getUserGames(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final games = snapshot.data ?? [];

        if (games.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videogame_asset_off, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text('Henüz oyun oluşturmadınız'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/ai-game-creator');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Oyun Oluştur'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: games.length,
          itemBuilder: (context, index) {
            return _buildAIGameCard(games[index], showDelete: true);
          },
        );
      },
    );
  }

  Widget _buildAIGameCard(SharedAIGame game, {bool showRank = false, int? rank, bool showDelete = false}) {
    final userId = FirebaseService().currentUser?.uid;
    final isLiked = userId != null && game.isLikedBy(userId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: InkWell(
        onTap: () => _playAIGame(game),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  if (showRank && rank != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getRankColor(rank),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('#$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  _buildTemplateChip(game.template),
                  const Spacer(),
                  if (showDelete)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteAIGame(game),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Title
              Text(game.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              
              // Description
              Text(game.description, style: TextStyle(fontSize: 14, color: Colors.grey.shade700), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              
              // Info chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!game.isHtmlGame)
                    _buildInfoChip(icon: Icons.school, label: game.subject, color: Colors.blue),
                  if (!game.isHtmlGame)
                    _buildInfoChip(icon: Icons.quiz, label: '${game.questionCount} soru', color: Colors.green),
                  _buildInfoChip(icon: Icons.child_care, label: '${game.targetAge} yaş', color: Colors.orange),
                  _buildInfoChip(icon: Icons.speed, label: game.difficulty, color: _getDifficultyColor(game.difficulty)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Play button
              ElevatedButton.icon(
                onPressed: () => _playAIGame(game),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Oyna'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
              const SizedBox(height: 12),
              
              // Bottom row: creator + stats
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(game.createdByName[0].toUpperCase(), style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(game.createdByName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        if (game.createdAt != null)
                          Text(timeago.format(game.createdAt!, locale: 'tr'), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey),
                    onPressed: () => _toggleLikeAI(game),
                  ),
                  Text('${game.likeCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  const Icon(Icons.play_circle, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${game.playCount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== HTML OYUNLAR BÖLÜMÜ ==========
  Widget _buildHTMLGamesSection() {
    return Column(
      children: [
        TabBar(
          controller: _htmlTabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today), text: 'Bugün'),
            Tab(icon: Icon(Icons.star), text: 'Editor Seçimi'),
            Tab(icon: Icon(Icons.favorite), text: 'Beğenilenler'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trend'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _htmlTabController,
            children: [
              _buildHTMLFeedList(_feedService.getTodaysGames()),
              _buildHTMLFeedList(_feedService.getEditorsChoice()),
              _buildHTMLFeedList(_feedService.getMostLovedGames()),
              _buildHTMLFeedList(_feedService.getTrendingGames()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHTMLFeedList(Future<List<Game>> gamesFuture) {
    return FutureBuilder<List<Game>>(
      future: gamesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: 3,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShimmerLoading(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          );
        }

        // ✅ Error handling
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Hata: ${snapshot.error}',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Yenile'),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gamepad, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Henüz oyun yok',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              ],
            ),
          );
        }

        final games = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: games.length,
          itemBuilder: (context, index) => FadeSlideIn(
            delay: Duration(milliseconds: index * 100),
            child: _buildGameCard(context, games[index]),
          ),
        );
      },
    );
  }

  Widget _buildGameCard(BuildContext context, Game game) {
    return ScaleBounce(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GameDetailPage(game: game, feedService: _feedService),
          ),
        );
      },
      child: GlowContainer(
        glowColor: Colors.purple.withOpacity(0.3),
        blurRadius: 15,
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Oyun Türü ve Yaratıcı
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yaratıcı: ${game.creatorName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        game.gameType.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Açıklama
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  game.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 12),

              // İstatistikler - Yatay Üst Üste
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatChip('🎮 ${game.playCount}', 'Oynama'),
                    _buildStatChip(
                      '⭐ ${game.averageRating.toStringAsFixed(1)}',
                      'Puan',
                    ),
                    _buildStatChip('📊 ${game.difficulty}', 'Zorluk'),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),

              // Alt - Düğmeler
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Oyna Butonu
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Oyun sayfasına git
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayGameSimple(game: game),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Oyna'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Beğen Butonu
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('❤️ Beğenildi!')),
                        );
                      },
                      icon: const Icon(Icons.favorite_border),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                      ),
                    ),

                    // Paylaş Butonu
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📤 Paylaş!')),
                        );
                      },
                      icon: const Icon(Icons.share),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
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

  Widget _buildStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ========== AI OYUN HELPER METHODLARI ==========

  Widget _buildTemplateChip(String template) {
    final templates = {
      'platformer': ('🏃', 'Platform', Colors.blue),
      'collector': ('⭐', 'Koleksiyon', Colors.amber),
      'puzzle': ('🧩', 'Puzzle', Colors.purple),
      'educational': ('📚', 'Eğitim', Colors.green),
      'runner': ('🏃‍♂️', 'Runner', Colors.orange),
      'shooter': ('🚀', 'Shooter', Colors.red),
      'html3d': ('🌐', 'HTML 3D', Colors.teal),
    };

    final info = templates[template] ?? ('🎮', template, Colors.grey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: info.$3.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: info.$3.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(info.$1, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            info.$2,
            style: TextStyle(
              color: info.$3,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.brown.shade300;
    return Colors.blue;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _playAIGame(SharedAIGame sharedGame) async {
    // Oynanma sayisini artir
    await _aiSocialService.incrementPlayCount(sharedGame.docId);

    if (sharedGame.isHtmlGame) {
      if (sharedGame.htmlCode == null || sharedGame.htmlCode!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('HTML oyun verisi bulunamadı.')),
          );
        }
        return;
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(
            htmlContent: sharedGame.htmlCode!,
            gameTitle: sharedGame.title,
          ),
        ),
      );
      return;
    }

    if (sharedGame.gameConfig == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oyun konfigurasyonu bulunamadı.')),
        );
      }
      return;
    }

    // Oyunu baslat
    final game = DynamicAIGame(config: sharedGame.gameConfig!);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(sharedGame.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: GameWidget(game: game),
        ),
      ),
    );
  }

  Future<void> _toggleLikeAI(SharedAIGame game) async {
    final userId = FirebaseService().currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beğenmek için giriş yapmalısınız')),
      );
      return;
    }

    try {
      await _aiSocialService.toggleLike(game.docId, userId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  Future<void> _deleteAIGame(SharedAIGame game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Oyunu Sil'),
        content: Text('${game.title} oyununu silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final userId = FirebaseService().currentUser?.uid;
    if (userId == null) return;

    try {
      await _aiSocialService.deleteGame(game.docId, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Oyun silindi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}

// 📄 OYUN DETAY SAYFASI
class GameDetailPage extends StatefulWidget {
  final Game game;
  final SocialFeedService feedService;

  const GameDetailPage({
    super.key,
    required this.game,
    required this.feedService,
  });

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  late Future<List<GameComment>> _commentsFuture;
  late Future<List<GameScore>> _leaderboardFuture;
  int _userRating = 0;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentsFuture = widget.feedService.getGameComments(widget.game.id);
    _leaderboardFuture = widget.feedService.getGameLeaderboard(widget.game.id);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.game.title),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                  ),
                ),
                child: Center(
                  child: Text(
                    _getGameEmoji(widget.game.gameType),
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
          ),

          // İçerik
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Temel Bilgiler
                _buildInfoCard(),
                const SizedBox(height: 16),

                // Puanlama Bölümü
                _buildRatingSection(),
                const SizedBox(height: 16),

                // Yorum Bölümü
                _buildCommentSection(),
                const SizedBox(height: 16),

                // Sıralama Tablosu
                _buildLeaderboardSection(),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: () {
              // Oyunu oyna sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayGameSimple(game: widget.game),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Oyunu Oyna'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.game.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: widget.game.learningGoals
                  .map((goal) => Chip(label: Text(goal)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⭐ Bu oyunu puanla',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _userRating = index + 1);
                    widget.feedService.addRating(
                      gameId: widget.game.id,
                      userId: 'current_user_id', // TODO: Gerçek user ID
                      rating: index + 1,
                    );
                  },
                  child: Icon(
                    index < _userRating ? Icons.star : Icons.star_outline,
                    size: 40,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💬 Yorumlar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Bir yorum yazın...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (_commentController.text.isNotEmpty) {
                  widget.feedService.addComment(
                    gameId: widget.game.id,
                    userId: 'current_user_id', // TODO: Gerçek user ID
                    userName: 'Kullanıcı', // TODO: Gerçek user name
                    comment: _commentController.text,
                  );
                  _commentController.clear();
                  setState(() {
                    _commentsFuture = widget.feedService.getGameComments(
                      widget.game.id,
                    );
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<GameComment>>(
          future: _commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Henüz yorum yok',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            return Column(
              children: snapshot.data!
                  .map((comment) => _buildCommentItem(comment))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentItem(GameComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(comment.comment),
              const SizedBox(height: 4),
              Text(
                _formatDate(comment.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏆 Sıralama Tablosu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<GameScore>>(
          future: _leaderboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Henüz skoru olmayan oyuncu yok',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }

            return Column(
              children: List.generate(snapshot.data!.length, (index) {
                final score = snapshot.data![index];
                return _buildLeaderboardItem(index + 1, score);
              }),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(int position, GameScore score) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: position == 1
                  ? Colors.amber
                  : position == 2
                  ? Colors.grey
                  : position == 3
                  ? Colors.orange
                  : Colors.blue.shade100,
            ),
            child: Center(
              child: Text(
                '#$position',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: position <= 3 ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          title: Text(
            score.userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${score.correctAnswers}/${score.totalQuestions} doğru',
          ),
          trailing: Text(
            '${score.score} puan',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  String _getGameEmoji(String gameType) {
    switch (gameType) {
      case 'math':
        return '🔢';
      case 'word':
        return '📝';
      case 'puzzle':
        return '🧩';
      case 'color':
        return '🎨';
      case 'memory':
        return '🧠';
      default:
        return '🎮';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Az önce';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}d önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}s önce';
    } else {
      return '${difference.inDays}g önce';
    }
  }
}
