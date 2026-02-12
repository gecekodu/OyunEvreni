// 🏆 LEADERBOARD PAGE - Genel Sıralama

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../data/services/score_service.dart';

class LeaderboardPage extends StatefulWidget {
  final String? gameId; // Oyun bazlı filtre için
  
  const LeaderboardPage({super.key, this.gameId});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final ScoreService _scoreService = GetIt.instance<ScoreService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Genel Sıralama'),
        elevation: 0,
        backgroundColor: Colors.deepOrange.withOpacity(0.1),
      ),
      body: _buildGlobalLeaderboard(),
    );
  }

  /// 🌍 GLOBAL LEADERBOARD - Tüm Kullanıcıların Genel Puanlarına Göre Sıralama
  Widget _buildGlobalLeaderboard() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _scoreService.getGlobalUserLeaderboard(limit: 100),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.show_chart, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Henüz sıralama verisi yok',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Oyunları oynayarak puan topla!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        final leaderboard = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            return _buildLeaderboardItem(leaderboard[index], index + 1);
          },
        );
      },
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> user, int rank) {
    final userName = user['username'] ?? 'Kullanıcı';
    final totalScore = user['totalScore'] ?? 0;

    // Madalya emojisi ve renk
    String medalEmoji = '';
    Color medalColor = Colors.grey;
    Color bgColor = Colors.deepOrange.withOpacity(0.08);
    Color borderColor = Colors.deepOrange.withOpacity(0.3);
    
    if (rank == 1) {
      medalEmoji = '🥇';
      medalColor = Colors.amber;
      bgColor = Colors.amber.withOpacity(0.12);
      borderColor = Colors.amber.withOpacity(0.5);
    } else if (rank == 2) {
      medalEmoji = '🥈';
      medalColor = Colors.grey[400]!;
      bgColor = Colors.grey.withOpacity(0.08);
      borderColor = Colors.grey.withOpacity(0.3);
    } else if (rank == 3) {
      medalEmoji = '🥉';
      medalColor = Colors.orange;
      bgColor = Colors.orange.withOpacity(0.1);
      borderColor = Colors.orange.withOpacity(0.4);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgColor, bgColor.withOpacity(0.5)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: medalColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: medalColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: medalEmoji.isNotEmpty
                ? Text(
                    medalEmoji,
                    style: const TextStyle(fontSize: 28),
                  )
                : Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
          ),
          title: Text(
            userName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.deepOrange.withOpacity(0.6),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  totalScore.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                Text(
                  'puan',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.deepOrange.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
