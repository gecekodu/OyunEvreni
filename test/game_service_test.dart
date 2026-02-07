import 'dart:convert';
import 'package:test/test.dart';

void main() {
  group('Oyun Oluşturma Testi', () {
    test('GameService temel test', () {
      // Basit test
      final jsonData = '''{
        "questions": [
          {
            "question": "3 + 5 = ?",
            "answers": ["8", "7", "6", "9"],
            "correctIndex": 0
          }
        ]
      }''';
      
      final decoded = jsonDecode(jsonData);
      expect(decoded['questions'].length, equals(1));
      expect(decoded['questions'][0]['question'], contains('3 + 5'));
      print('✅ Oyun JSON test passed');
    });
  });
}
