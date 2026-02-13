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
        backgroundColor: const Color(0xFF211A3D),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1638),
              Color(0xFF221A40),
              Color(0xFF2A1F4D),
            ],
          ),
        ),
        child: _buildGlobalLeaderboard(),
      ),
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
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC300)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.show_chart, size: 64, color: Colors.white54),
                const SizedBox(height: 16),
                Text(
                  'Henüz sıralama verisi yok',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Oyunları oynayarak puan topla!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
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
    Color medalColor = const Color(0xFF6C5CE7);
    Color bgColor = const Color(0xFF2A214A);
    Color borderColor = Colors.white.withOpacity(0.08);
    
    if (rank == 1) {
      medalEmoji = '🥇';
      medalColor = const Color(0xFFFFC300);
      bgColor = const Color(0xFF3A2B6A);
      borderColor = const Color(0xFFFFC300).withOpacity(0.6);
    } else if (rank == 2) {
      medalEmoji = '🥈';
      medalColor = const Color(0xFFB0B3FF);
      bgColor = const Color(0xFF2C234B);
      borderColor = Colors.white24;
    } else if (rank == 3) {
      medalEmoji = '🥉';
      medalColor = const Color(0xFFFF8A00);
      bgColor = const Color(0xFF30224F);
      borderColor = const Color(0xFFFF8A00).withOpacity(0.5);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgColor, const Color(0xFF1E1638)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: medalColor.withOpacity(0.2),
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
              color: medalColor.withOpacity(0.2),
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
                      color: Colors.white70,
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
              color: const Color(0xFFFFC300).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFC300).withOpacity(0.6),
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
                    color: Color(0xFFFFC300),
                  ),
                ),
                Text(
                  'puan',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
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
