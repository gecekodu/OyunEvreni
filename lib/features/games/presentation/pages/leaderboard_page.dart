// 🏆 LEADERBOARD PAGE - Global ve Oyun Bazlı Sıralamalar

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/services/leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  final String? gameId; // Oyun bazlı filtre için
  
  const LeaderboardPage({Key? key, this.gameId}) : super(key: key);

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
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('🏆 Sıralamalar'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '🌍 Global'),
            Tab(text: '📊 Bu Ay'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalLeaderboard(),
          _buildTrendingGames(),
        ],
      ),
    );
  }

  /// 🌍 GLOBAL LEADERBOARD
  Widget _buildGlobalLeaderboard() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _leaderboardService.getGlobalLeaderboard(limit: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('📋 Sıralamaya ait veri bulunamadı.'),
          );
        }

        final leaderboard = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final user = leaderboard[index];
            final rank = index + 1;
            final score = user['score'] ?? 0;
            final userName = user['userName'] ?? 'Anonim';

            // Madalya emojisi
            String medalEmoji = '';
            if (rank == 1)
              medalEmoji = '🥇';
            else if (rank == 2)
              medalEmoji = '🥈';
            else if (rank == 3) medalEmoji = '🥉';

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
                leading: Text(
                  medalEmoji.isEmpty ? '#$rank' : medalEmoji,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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
