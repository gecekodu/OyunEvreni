// 🏆 LEADERBOARD PAGE - Global ve Oyun Bazlı Sıralamalar

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/services/leaderboard_service.dart';
import '../../data/services/score_service.dart';

class LeaderboardPage extends StatefulWidget {
  final String? gameId; // Oyun bazlı filtre için
  
  const LeaderboardPage({super.key, this.gameId});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LeaderboardService _leaderboardService =
      GetIt.instance<LeaderboardService>();

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
      appBar: AppBar(
        title: const Text('Siralamalar'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepOrange,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Bu Ay'),
            Tab(text: 'Elmas'),
            Tab(text: 'Kupa'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalLeaderboard(),
          _buildTrendingGames(),
          _buildDiamondsLeaderboard(),
          _buildTrophiesLeaderboard(),
        ],
      ),
    );
  }

  /// 🌍 GLOBAL LEADERBOARD
  Widget _buildGlobalLeaderboard() {
    final scoreService = GetIt.instance<ScoreService>();
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: scoreService.getGlobalUserLeaderboard(limit: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('📋 Henüz sıralama verisi yok'),
              ],
            ),
          );
        }

        final leaderboard = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final user = leaderboard[index];
            final rank = index + 1;
            final score = user['totalScore'] ?? 0;
            final userName = user['username'] ?? 'Kullanıcı';

            // Madalya emojisi
            String medalEmoji = '';
            Color medalColor = Colors.grey;
            
            if (rank == 1) {
              medalEmoji = '🥇';
              medalColor = Colors.amber;
            } else if (rank == 2) {
              medalEmoji = '🥈';
              medalColor = Colors.grey[400]!;
            } else if (rank == 3) {
              medalEmoji = '🥉';
              medalColor = Colors.orange;
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.withOpacity(0.3),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.deepPurple.withOpacity(0.5),
                ),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: medalEmoji.isNotEmpty
                      ? Text(
                          medalEmoji,
                          style: const TextStyle(fontSize: 24),
                        )
                      : Text(
                          '#$rank',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                ),
                title: Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Seviyi ${(score ~/ 100) + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Text(
                    '$score',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 📊 BU AY TRENDİNG OYUNLAR
  Widget _buildTrendingGames() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _leaderboardService.getTrendingThisMonth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('📊 Henüz oynanmış oyun yok.'),
          );
        }

        final trending = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: trending.length,
          itemBuilder: (context, index) {
            final game = trending[index];
            final gameId = game['gameId'] ?? 'Bilinmiyor';
            final playCount = game['playCount'] ?? 0;
            final avgScore = (game['avgScore'] as num?)?.toStringAsFixed(1) ?? '0';

            // Oyun adına göre emoji
            final gameEmojis = {
              'besin-ninja': '🥗',
              'lazer-fizik': '🔦',
              'matematik-okcusu': '🏹',
              'araba-surtunme': '🚗',
              'gezegenibul': '🪐',
              'tetris': '🧱',
              'memory': '🧠',
              'snake': '🐍',
              'friction': '🔬',
            };

            final emoji = gameEmojis[gameId] ?? '🎮';
            final displayName = _formatGameName(gameId);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.2),
                    Colors.red.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.5)),
              ),
              child: ListTile(
                leading: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                title: Text(
                  displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Oynayan: $playCount kişi',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '⌀ $avgScore',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 💎 ELMAS LEADERBOARD
  Widget _buildDiamondsLeaderboard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _leaderboardService.getDiamondsLeaderboard(limit: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Elmas siralamasi bulunamadi.'),
          );
        }

        final leaderboard = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final user = leaderboard[index];
            final rank = index + 1;
            final diamonds = user['diamonds'] ?? 0;
            final userName = user['userName'] ?? 'Anonim';

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.cyan.withOpacity(0.2),
                    Colors.blue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyan.withOpacity(0.4)),
              ),
              child: ListTile(
                leading: Text(
                  '#$rank',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Row(
                  children: [
                    _buildAvatar(user),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.cyan),
                  ),
                  child: Text(
                    '💎 $diamonds',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 🏆 KUPA LEADERBOARD
  Widget _buildTrophiesLeaderboard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _leaderboardService.getTrophiesLeaderboard(limit: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Kupa siralamasi bulunamadi.'),
          );
        }

        final leaderboard = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final user = leaderboard[index];
            final rank = index + 1;
            final trophies = user['trophies'] ?? 0;
            final userName = user['userName'] ?? 'Anonim';

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.2),
                    Colors.orange.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: ListTile(
                leading: Text(
                  '#$rank',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Row(
                  children: [
                    _buildAvatar(user),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Text(
                    '🏆 $trophies',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatar(Map<String, dynamic> user) {
    final avatarEmoji = (user['avatarEmoji'] as String?) ?? '';
    final avatarUrl = (user['userAvatar'] as String?) ?? '';

    if (avatarEmoji.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: Colors.deepOrange.withOpacity(0.15),
        child: Text(
          avatarEmoji,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.grey.shade300,
      child: const Icon(Icons.person, size: 18, color: Colors.black54),
    );
  }

  /// Oyun adını formatla
  String _formatGameName(String gameId) {
    final names = {
      'besin-ninja': 'Besin Ninja',
      'lazer-fizik': 'Lazer Fizik',
      'matematik-okcusu': 'Matematik Okçusu',
      'araba-surtunme': 'Sürütüme Yarışı',
      'gezegenibul': 'Gezegen Bul',
      'tetris': 'Tetris',
      'memory': 'Hafıza Oyunu',
      'snake': 'Yılan Oyunu',
      'friction': 'Sürtünme Deneyi',
    };
    return names[gameId] ?? gameId;
  }
}
