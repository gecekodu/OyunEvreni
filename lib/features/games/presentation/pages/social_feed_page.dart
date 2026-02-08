// 📱 SOSYAL AKIŞ SAYFASI

import 'package:flutter/material.dart';
import '../../data/services/social_feed_service.dart';
import '../../domain/entities/game_models.dart';
import '../../domain/entities/game_score.dart';
import '../../../../core/widgets/futuristic_animations.dart';

class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({super.key});

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _feedService = SocialFeedService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                  'Sosyal Akış 📱',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Topluluk tarafından seçilen oyunlar',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(icon: Icon(Icons.calendar_today), text: 'Bugün'),
                Tab(icon: Icon(Icons.star), text: 'Editor Seçimi'),
                Tab(icon: Icon(Icons.favorite), text: 'Beğenilenler'),
                Tab(icon: Icon(Icons.trending_up), text: 'Trend'),
              ],
            ),
          ),

          // Tab İçeriği
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedList(_feedService.getTodaysGames()),
                _buildFeedList(_feedService.getEditorsChoice()),
                _buildFeedList(_feedService.getMostLovedGames()),
                _buildFeedList(_feedService.getTrendingGames()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedList(Future<List<Game>> gamesFuture) {
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
                width: double.infinity,
                height: 200,
                borderRadius: 15,
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
                          // Oyun oynat
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🎮 Oyun başlatılıyor...'),
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
              // Oyunu oyna
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🎮 Oyun başlatılıyor...')),
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
