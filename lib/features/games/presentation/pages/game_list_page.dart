import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/game_models.dart';
import 'play_html_game_page.dart';

class GameListPage extends StatelessWidget {
  GameListPage({super.key});

  Future<List<Game>> fetchGames() async {
    final snapshot = await FirebaseFirestore.instance.collection('games').orderBy('createdAt', descending: true).limit(20).get();
    return snapshot.docs.map((doc) => Game.fromFirestore(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Oyunlar')), 
      body: FutureBuilder<List<Game>>(
        future: fetchGames(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final games = snapshot.data!;
          if (games.isEmpty) {
            return const Center(child: Text('Henüz oyun yok.'));
          }
          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return ListTile(
                title: Text(game.title),
                subtitle: Text(game.description),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PlayHtmlGamePage(gameJson: game.metadata?['geminiContent']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
