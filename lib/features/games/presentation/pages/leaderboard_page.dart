// 🏆 LEADERBOARD PAGE - Sıralama Tablosu

import 'package:flutter/material.dart';
import '../../domain/entities/game_score.dart';
import '../../domain/entities/game_models.dart';
import '../../data/services/score_service.dart';
import '../../../../main.dart';

class LeaderboardPage extends StatefulWidget {
  final Game game;
  
  const LeaderboardPage({super.key, required this.game});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<GameScore> _scores = [];
  bool _isLoading = true;
  GameScore? _myBestScore;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    
    try {
      final scoreService = getIt<ScoreService>();
      
      // Leaderboard'u getir
      final scores = await scoreService.getLeaderboard(
        gameId: widget.game.id,
        limit: 50,
      );
      
      // Kullanıcının en iyi skorunu getir
      final myScore = await scoreService.getUserBestScore(
        gameId: widget.game.id,
        userId: 'demo-user', // TODO: Gerçek user ID
      );
      
      setState(() {
        _scores = scores;
        _myBestScore = myScore;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Leaderboard yükleme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🏆 ${widget.game.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeaderboard,
          ),
        ],
      ),
      body: Column(
        children: [
          // Kullanıcının en iyi skoru
          if (_myBestScore != null) _buildMyScoreCard(),
          
          // Leaderboard başlık
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.purple.shade50,
            child: Row(
              children: [
                const Text(
                  'En İyi Skorlar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_scores.length} oyuncu',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Leaderboard listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _scores.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _scores.length,
                        itemBuilder: (context, index) {
                          return _buildScoreItem(_scores[index], index + 1);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyScoreCard() {
    final score = _myBestScore!;
    final rank = _scores.indexWhere((s) => s.id == score.id) + 1;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank > 0 ? '#$rank' : '🎮',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Senin Rekorun',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${score.correctAnswers}/${score.totalQuestions} Doğru',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${score.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _getStars(score.starRating),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(GameScore score, int rank) {
    final isTopThree = rank <= 3;
    final isMyScore = score.id == _myBestScore?.id;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isMyScore 
            ? Colors.purple.shade50 
            : isTopThree 
                ? Colors.amber.shade50 
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMyScore 
              ? Colors.purple.shade200 
              : Colors.grey.shade200,
          width: isMyScore ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isTopThree 
                ? _getRankColor(rank) 
                : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              isTopThree ? _getRankEmoji(rank) : '#$rank',
              style: TextStyle(
                fontSize: isTopThree ? 20 : 14,
                fontWeight: FontWeight.bold,
                color: isTopThree ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        title: Text(
          score.userName,
          style: TextStyle(
            fontWeight: isMyScore ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          '${score.correctAnswers}/${score.totalQuestions} doğru • ${_getStars(score.starRating)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${score.score}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${score.successRate.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Henüz kimse oynamadı!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk oynayan sen ol!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade600;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.grey.shade200;
    }
  }

  String _getStars(int count) {
    return '⭐' * count;
  }
}
