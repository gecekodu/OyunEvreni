import '../datasources/example_games_datasource.dart';
import '../../domain/entities/example_game.dart';

abstract class ExampleGamesRepository {
  Future<List<ExampleGame>> getAllExamples();
  Future<ExampleGame?> getExampleByType(ExampleGameType type);
  Future<List<ExampleGame>> getExamplesByDifficulty(double minDifficulty, double maxDifficulty);
  Future<List<ExampleGame>> getExamplesByAgeRange(int minAge, int maxAge);
}

class ExampleGamesRepositoryImpl implements ExampleGamesRepository {
  final ExampleGamesDatasource datasource;

  ExampleGamesRepositoryImpl({required this.datasource});

  @override
  Future<List<ExampleGame>> getAllExamples() async {
    try {
      return await datasource.getAllExamples();
    } catch (e) {
      // Error handling ve logging
      rethrow;
    }
  }

  @override
  Future<ExampleGame?> getExampleByType(ExampleGameType type) async {
    try {
      return await datasource.getExampleByType(type);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ExampleGame>> getExamplesByDifficulty(double minDifficulty, double maxDifficulty) async {
    try {
      return await datasource.getExamplesByDifficulty(minDifficulty, maxDifficulty);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ExampleGame>> getExamplesByAgeRange(int minAge, int maxAge) async {
    try {
      return await datasource.getExamplesByAgeRange(minAge, maxAge);
    } catch (e) {
      rethrow;
    }
  }
}
