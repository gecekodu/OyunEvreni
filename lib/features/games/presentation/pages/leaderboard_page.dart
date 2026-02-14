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
        backgroundColor: const Color(0xFFFFF0D6),
        foregroundColor: const Color(0xFF2B210F),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF7E6),
              Color(0xFFFFE7C7),
              Color(0xFFFFF3DC),
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
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF7A00)),
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
                    color: Color(0xFF6B4C1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Oyunları oynayarak puan topla!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A6A3A),
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
    // Kullanıcı adını al - birden fazla fallback ile
    String userName = user['username'] as String? ?? 
                      user['displayName'] as String? ?? 
                      user['userName'] as String? ?? 
                      user['name'] as String? ?? 
                      'Oyuncu';
    
    // Eğer hala generic bir isimse, email'den veya uid'den oluştur
    if (userName == 'Oyuncu' || userName == 'Kullanıcı') {
      final email = user['email'] as String?;
      final uid = user['uid'] as String?;
      
      if (email != null && email.isNotEmpty) {
        userName = email.split('@').first;
      } else if (uid != null && uid.isNotEmpty) {
        userName = 'Oyuncu${uid.substring(0, 6)}';
      }
    }
    
    final totalScore = user['totalScore'] ?? 0;

    // Madalya emojisi ve renk
    String medalEmoji = '';
    Color medalColor = const Color(0xFFFF9AD5);
    Color bgColor = const Color(0xFFFFF4DF);
    Color borderColor = const Color(0xFFFFD8A8);
    
    if (rank == 1) {
      medalEmoji = '🥇';
      medalColor = const Color(0xFFFFC46B);
      bgColor = const Color(0xFFFFE7C7);
      borderColor = const Color(0xFFFFC46B).withOpacity(0.6);
    } else if (rank == 2) {
      medalEmoji = '🥈';
      medalColor = const Color(0xFF9AD5FF);
      bgColor = const Color(0xFFEAF6FF);
      borderColor = const Color(0xFF9AD5FF).withOpacity(0.6);
    } else if (rank == 3) {
      medalEmoji = '🥉';
      medalColor = const Color(0xFFFF9E7A);
      bgColor = const Color(0xFFFFEFE0);
      borderColor = const Color(0xFFFF9E7A).withOpacity(0.6);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgColor, const Color(0xFFFFF7E6)],
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
                      color: const Color(0xFF6B4C1A),
                    ),
                  ),
          ),
          title: Text(
            userName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
                color: Color(0xFF2B210F),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: const Color(0xFFFFF1DB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFFFC46B).withOpacity(0.6),
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
                      color: Color(0xFFFF7A00),
                  ),
                ),
                Text(
                  'puan',
                  style: TextStyle(
                    fontSize: 10,
                      color: Color(0xFF8A6A3A),
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
