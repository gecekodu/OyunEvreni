// 🎮 OYUN OYNATMA SAYFASI

import 'package:flutter/material.dart';
import 'dart:math';

class PlayGamePage extends StatefulWidget {
  final String gameTitle;
  final String gameType;

  const PlayGamePage({
    super.key,
    required this.gameTitle,
    required this.gameType,
  });

  @override
  State<PlayGamePage> createState() => _PlayGamePageState();
}

class _PlayGamePageState extends State<PlayGamePage> {
  int _score = 0;
  int _questionNumber = 1;
  int _totalQuestions = 10;
  
  late int _num1;
  late int _num2;
  late int _correctAnswer;
  late List<int> _options;
  
  bool _answered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    
    if (widget.gameType == 'math') {
      _num1 = random.nextInt(20) + 1;
      _num2 = random.nextInt(20) + 1;
      _correctAnswer = _num1 + _num2;
      
      // Yanlış cevaplar üret
      _options = [_correctAnswer];
      while (_options.length < 4) {
        final wrongAnswer = _correctAnswer + random.nextInt(10) - 5;
        if (wrongAnswer > 0 && !_options.contains(wrongAnswer)) {
          _options.add(wrongAnswer);
        }
      }
      _options.shuffle();
    }
  }

  void _checkAnswer(int selectedAnswer) {
    if (_answered) return;
    
    setState(() {
      _answered = true;
      _isCorrect = selectedAnswer == _correctAnswer;
      if (_isCorrect) {
        _score += 10;
      }
    });

    // 1.5 saniye sonra yeni soru
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      if (_questionNumber < _totalQuestions) {
        setState(() {
          _questionNumber++;
          _answered = false;
          _generateQuestion();
        });
      } else {
        _showResultsDialog();
      }
    });
  }

  void _showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Oyun Bitti!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tebrikler!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Puanın: $_score / ${_totalQuestions * 10}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Doğru Cevap: ${(_score / 10).toInt()} / $_totalQuestions',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Ana Sayfaya Dön'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _score = 0;
                _questionNumber = 1;
                _answered = false;
                _generateQuestion();
              });
            },
            child: const Text('Tekrar Oyna'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gameTitle),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '⭐ $_score',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // İlerleme Göstergesi
            LinearProgressIndicator(
              value: _questionNumber / _totalQuestions,
              backgroundColor: Colors.grey[200],
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'Soru $_questionNumber / $_totalQuestions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Soru Kartı
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          '$_num1 + $_num2 = ?',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Cevap Seçenekleri
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _options.length,
                      itemBuilder: (context, index) {
                        final option = _options[index];
                        final isCorrect = option == _correctAnswer;
                        
                        Color? buttonColor;
                        if (_answered) {
                          if (isCorrect) {
                            buttonColor = Colors.green;
                          } else if (!isCorrect && option == option) {
                            buttonColor = Colors.grey;
                          }
                        }

                        return ElevatedButton(
                          onPressed: _answered ? null : () => _checkAnswer(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: _answered ? Colors.white : null,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '$option',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),

                    // Geri Bildirim
                    if (_answered) ...[
                      const SizedBox(height: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isCorrect
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isCorrect ? Icons.check_circle : Icons.cancel,
                              color: _isCorrect ? Colors.green : Colors.red,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isCorrect ? 'Doğru! 🎉' : 'Yanlış 😢',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _isCorrect ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
