// 🎮 OYUN OLUŞTURMA SAYFASI - Gelişmiş Versiyon

import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class CreateGameFlowPage extends StatefulWidget {
  const CreateGameFlowPage({super.key});

  @override
  State<CreateGameFlowPage> createState() => _CreateGameFlowPageState();
}

class _CreateGameFlowPageState extends State<CreateGameFlowPage> {
  int _currentStep = 0;
  
  // Kullanıcı seçimleri
  String? _selectedGameType;
  String? _selectedDifficulty;
  List<String> _selectedGoals = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedGameType != null;
      case 1:
        return _selectedGoals.isNotEmpty;
      case 2:
        return _selectedDifficulty != null;
      case 3:
        return _titleController.text.isNotEmpty &&
            _descriptionController.text.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _createGame() async {
    // TODO: Burada Gemini AI ile oyun içeriği oluşturulacak
    // TODO: HTML şablonu ile birleştirilecek
    // TODO: Firestore'a kaydedilecek
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Oyun Oluşturuluyor!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Yapay zeka oyununuzu hazırlıyor...'),
            const SizedBox(height: 8),
            Text(
              'Oyun Türü: $_selectedGameType\n'
              'Zorluk: $_selectedDifficulty\n'
              'Hedefler: ${_selectedGoals.length} adet',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );

    // Simüle edilmiş bekleme (gerçekte Gemini API çağrısı olacak)
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    Navigator.of(context).pop(); // Dialog kapat
    
    // Başarı mesajı
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Oyununuz başarıyla oluşturuldu!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Ana sayfaya dön
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Yeni Oyun Oluştur'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // İlerleme Göstergesi
          _buildProgressIndicator(),
          
          // İçerik
          Expanded(
            child: _buildStepContent(),
          ),
          
          // Alt Butonlar
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? Colors.blue
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 3) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildGameTypeSelection();
      case 1:
        return _buildLearningGoalsSelection();
      case 2:
        return _buildDifficultySelection();
      case 3:
        return _buildGameDetailsForm();
      default:
        return const SizedBox();
    }
  }

  // Adım 1: Oyun Türü Seçimi
  Widget _buildGameTypeSelection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '1️⃣ Oyun Türü Seçin',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Hangi tür oyun oluşturmak istersiniz?',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        ...AppConstants.gameTypes.map((gameType) {
          final isSelected = _selectedGameType == gameType.id;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isSelected ? Color(gameType.color).withOpacity(0.1) : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(gameType.color).withOpacity(0.2),
                child: Text(gameType.icon, style: const TextStyle(fontSize: 24)),
              ),
              title: Text(
                gameType.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(gameType.description),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: Color(gameType.color))
                  : const Icon(Icons.circle_outlined),
              onTap: () {
                setState(() {
                  _selectedGameType = gameType.id;
                  _selectedGoals = []; // Reset goals
                });
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  // Adım 2: Öğrenme Hedefleri
  Widget _buildLearningGoalsSelection() {
    final availableGoals = AppConstants.learningGoals
        .where((goal) => goal.category == _selectedGameType)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '2️⃣ Öğrenme Hedefleri',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Oyununuz hangi konuları öğretsin? (Birden fazla seçebilirsiniz)',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        ...availableGoals.map((goal) {
          final isSelected = _selectedGoals.contains(goal.id);
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isSelected ? Colors.blue.shade50 : null,
            child: CheckboxListTile(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedGoals.add(goal.id);
                  } else {
                    _selectedGoals.remove(goal.id);
                  }
                });
              },
              title: Text(goal.name),
              subtitle: Text(goal.description),
              secondary: Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  // Adım 3: Zorluk Seviyesi
  Widget _buildDifficultySelection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '3️⃣ Zorluk Seviyesi',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Oyununuz hangi seviyede olsun?',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        ...AppConstants.difficultyLevels.map((level) {
          final isSelected = _selectedDifficulty == level.id;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: isSelected ? Colors.orange.shade50 : null,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: Text(level.emoji, style: const TextStyle(fontSize: 28)),
              ),
              title: Text(
                level.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                'Puan çarpanı: x${level.multiplier}',
                style: const TextStyle(fontSize: 13),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.orange)
                  : const Icon(Icons.circle_outlined),
              onTap: () {
                setState(() => _selectedDifficulty = level.id);
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  // Adım 4: Oyun Detayları
  Widget _buildGameDetailsForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '4️⃣ Oyun Açıklaması',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Oyununuza bir isim ve açıklama verin',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        
        // Başlık
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Oyun Başlığı',
            hintText: 'Örn: Matematik Kahramanı',
            prefixIcon: const Icon(Icons.text_fields),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          maxLength: 50,
        ),
        const SizedBox(height: 16),
        
        // Açıklama
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Oyun Açıklaması',
            hintText: 'Oyununuzu kısaca tanıtın...',
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          maxLength: 200,
        ),
        const SizedBox(height: 24),
        
        // Özet Card
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 Oyun Özeti',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(),
                _buildSummaryRow('Tür', _getGameTypeName()),
                _buildSummaryRow('Hedefler', '${_selectedGoals.length} adet'),
                _buildSummaryRow('Zorluk', _getDifficultyName()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _getGameTypeName() {
    return AppConstants.gameTypes
            .firstWhere((t) => t.id == _selectedGameType,
                orElse: () => AppConstants.gameTypes.first)
            .name;
  }

  String _getDifficultyName() {
    return AppConstants.difficultyLevels
            .firstWhere((d) => d.id == _selectedDifficulty,
                orElse: () => AppConstants.difficultyLevels.first)
            .name;
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Geri Butonu
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('← Geri'),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 12),
          
          // İleri / Oluştur Butonu
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canProceed()
                  ? (_currentStep == 3 ? _createGame : _nextStep)
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.blue,
              ),
              child: Text(
                _currentStep == 3 ? '✨ Oyunu Oluştur' : 'İleri →',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
