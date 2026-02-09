// 🎮 AI GAME CREATOR PAGE
// Kullanici dogal dilde oyun tarif eder, AI oyun olusturur

import 'package:flutter/material.dart';
import '../../data/services/ai_game_generator_service.dart';
import '../../domain/entities/game_template.dart';
import '../../../../config/firebase_options.dart';
import '../../../../core/services/ai_game_social_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../webview/presentation/pages/webview_page.dart';

class AIGameCreatorPage extends StatefulWidget {
  const AIGameCreatorPage({Key? key}) : super(key: key);

  @override
  State<AIGameCreatorPage> createState() => _AIGameCreatorPageState();
}

class _AIGameCreatorPageState extends State<AIGameCreatorPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final AIGameGeneratorService _aiService =
      AIGameGeneratorService(apiKey: DefaultFirebaseOptions.geminiApiKey);
  final AIGameSocialService _socialService = AIGameSocialService();

  bool _isGenerating = false;
  bool _isSharing = false;
  AIGameConfig? _generatedGameConfig;
  String? _generatedHtmlGame;
  String? _sharedGameId;

  String _selectedDifficulty = 'medium';
  int _selectedAge = 8;
  GameTemplate? _selectedTemplate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI Oyun Olusturucu'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _buildCreatorView(),
    );
  }

  Widget _buildCreatorView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '🎮 Hayal Ettigin Oyunu Tarif Et!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Yapay zeka senin icin ozel bir 3D HTML oyunu olusturacak',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Oyun Aciklamasi',
              hintText:
                  'Ornek: "7 yas icin toplama ogreten 3D araba oyunu"',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.description),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Text('Zorluk: ', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'easy', label: Text('Kolay')),
                    ButtonSegment(value: 'medium', label: Text('Orta')),
                    ButtonSegment(value: 'hard', label: Text('Zor')),
                  ],
                  selected: {_selectedDifficulty},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _selectedDifficulty = newSelection.first;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Text('Yas: ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Slider(
                  value: _selectedAge.toDouble(),
                  min: 5,
                  max: 12,
                  divisions: 7,
                  label: '$_selectedAge yas',
                  onChanged: (value) {
                    setState(() {
                      _selectedAge = value.toInt();
                    });
                  },
                ),
              ),
              Text('$_selectedAge yas',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),

          const Text('Oyun Sablonu (Opsiyonel):',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTemplateChip(null, 'AI Belirlesin'),
              _buildTemplateChip(GameTemplate.platformer, 'Platform'),
              _buildTemplateChip(GameTemplate.collector, 'Koleksiyon'),
              _buildTemplateChip(GameTemplate.puzzle, 'Bulmaca'),
              _buildTemplateChip(GameTemplate.educational, 'Egitim'),
            ],
          ),
          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateGame,
            icon: _isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isGenerating ? 'Olusturuluyor...' : '🎮 Oyun Olustur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),

          if (!_isGenerating) _buildExamples(),
          const SizedBox(height: 16),

          if (_generatedGameConfig != null) _buildGeneratedGameCard(),
        ],
      ),
    );
  }

  Widget _buildTemplateChip(GameTemplate? template, String label) {
    final isSelected = _selectedTemplate == template;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedTemplate = template;
        });
      },
      selectedColor: Colors.deepPurple.shade200,
    );
  }

  Widget _buildExamples() {
    final examples = [
      '7 yas icin carpma ogreten 3D araba oyunu',
      '8 yas icin kelime bulmaca temali 3D macera',
      '9 yas icin hizli refleks gerektiren 3D uzay oyunu',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ornekler:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: examples
              .map(
                (text) => ActionChip(
                  label: Text(text),
                  onPressed: () {
                    _descriptionController.text = text;
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildGeneratedGameCard() {
    final config = _generatedGameConfig!;
    final isShared = _sharedGameId != null;

    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              config.description,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('🎯 ${config.template.name}')),
                Chip(label: Text('📊 ${config.difficulty}')),
                Chip(label: Text('👶 ${config.targetAge} yas')),
                const Chip(label: Text('🌐 HTML 3D')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _startGame,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Oyna'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSharing || isShared ? null : _shareGame,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(isShared ? Icons.check : Icons.share),
                    label: Text(_isSharing
                        ? 'Paylasiliyor...'
                        : isShared
                            ? 'Paylasildi'
                            : 'Paylas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isShared ? Colors.grey : Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateGame() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lutfen bir oyun aciklamasi girin!')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _sharedGameId = null;
    });

    try {
      final htmlGame = await _aiService.generateHTML3DGame(
        userDescription: _descriptionController.text,
        difficulty: _selectedDifficulty,
        targetAge: _selectedAge,
      );

      final basicConfig = AIGameConfig(
        gameId: 'html_${DateTime.now().millisecondsSinceEpoch}',
        title: _descriptionController.text.split('\n').first,
        description: _descriptionController.text,
        template: _selectedTemplate ?? GameTemplate.platformer,
        difficulty: _selectedDifficulty,
        targetAge: _selectedAge,
        mechanics: GameMechanics(),
        educationalContent: null,
        visualTheme: VisualTheme.fromJson(const {}),
        rules: GameRules.fromJson(const {}),
      );

      setState(() {
        _generatedHtmlGame = htmlGame;
        _generatedGameConfig = basicConfig;
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 3D Oyun basariyla olusturuldu!')),
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Hata: $e')),
      );
    }
  }

  void _startGame() {
    if (_generatedHtmlGame == null || _generatedHtmlGame!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Once oyunu olusturmalisiniz.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(
          htmlContent: _generatedHtmlGame!,
          gameTitle: _descriptionController.text.split('\n').first,
        ),
      ),
    );
  }

  Future<void> _shareGame() async {
    final config = _generatedGameConfig;
    if (config == null) return;

    final currentUser = FirebaseService().currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paylasmak icin giris yapmalisiniz'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSharing = true);

    try {
      String gameDocId;
      if (_generatedHtmlGame != null && _generatedHtmlGame!.isNotEmpty) {
        gameDocId = await _socialService.shareGameHtml(
          htmlCode: _generatedHtmlGame!,
          title: _descriptionController.text.split('\n').first,
          description: _descriptionController.text,
          userId: currentUser.uid,
          userName: currentUser.displayName ?? 'Anonim',
          difficulty: _selectedDifficulty,
          targetAge: _selectedAge,
        );
      } else {
        gameDocId = await _socialService.shareGame(
          gameConfig: config,
          userId: currentUser.uid,
          userName: currentUser.displayName ?? 'Anonim',
        );
      }

      setState(() {
        _sharedGameId = gameDocId;
        _isSharing = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('🎉 Oyun basariyla paylasildi!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() => _isSharing = false);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
