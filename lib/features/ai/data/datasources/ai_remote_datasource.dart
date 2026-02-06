// 🤖 AI Datasource - Gemini API çağrıları

import '../../../../core/services/gemini_service.dart';
import '../../../../core/errors/exceptions.dart';

class AIRemoteDataSource {
  final GeminiService _geminiService;

  AIRemoteDataSource({
    required GeminiService geminiService,
  }) : _geminiService = geminiService;

  /// 🎮 Oyun JSON'u üret
  Future<Map<String, dynamic>> generateGameJson({
    required String lesson,
    required String topic,
    required String grade,
    required String difficulty,
    required String learningObjective,
  }) async {
    try {
      return await _geminiService.generateGameJson(
        lesson: lesson,
        topic: topic,
        grade: grade,
        difficulty: difficulty,
        learningObjective: learningObjective,
      );
    } catch (e) {
      throw GeminiException(
        message: 'Oyun üretilirken hata: $e',
        code: 'GAME_GENERATION_ERROR',
      );
    }
  }

  /// 💡 İpuçları üret
  Future<List<String>> generateHints({
    required String gameTitle,
    required String topic,
    required String difficulty,
  }) async {
    try {
      return await _geminiService.generateHints(
        gameTitle: gameTitle,
        topic: topic,
        difficulty: difficulty,
      );
    } catch (e) {
      throw GeminiException(
        message: 'İpuçları üretilirken hata: $e',
        code: 'HINTS_GENERATION_ERROR',
      );
    }
  }

  /// 📊 Geri bildirim üret
  Future<String> generateFeedback({
    required String gameTitle,
    required int score,
    required bool completed,
    required int timeSpent,
  }) async {
    try {
      return await _geminiService.generateFeedback(
        gameTitle: gameTitle,
        score: score,
        completed: completed,
        timeSpent: timeSpent,
      );
    } catch (e) {
      throw GeminiException(
        message: 'Geri bildirim üretilirken hata: $e',
        code: 'FEEDBACK_GENERATION_ERROR',
      );
    }
  }

  /// 🔧 Geliştirme önerileri üret
  Future<List<String>> generateImprovementSuggestions({
    required String gameTitle,
    required double currentRating,
    required int playCount,
  }) async {
    try {
      return await _geminiService.generateImprovementSuggestions(
        gameTitle: gameTitle,
        currentRating: currentRating,
        playCount: playCount,
      );
    } catch (e) {
      throw GeminiException(
        message: 'Öneriler üretilirken hata: $e',
        code: 'SUGGESTIONS_GENERATION_ERROR',
      );
    }
  }
}
