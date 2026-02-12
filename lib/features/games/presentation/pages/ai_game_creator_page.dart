// 🤖 AI OYUN OLUŞTURMA SAYFASI

import 'package:flutter/material.dart';

class AIGameCreatorPage extends StatefulWidget {
  const AIGameCreatorPage({super.key});

  @override
  State<AIGameCreatorPage> createState() => _AIGameCreatorPageState();
}

class _AIGameCreatorPageState extends State<AIGameCreatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Matematik';
  String _selectedDifficulty = 'Orta';
  String _selectedAge = '6-8';
  bool _isGenerating = false;

  final List<String> _categories = [
    'Matematik',
    'Türkçe',
    'İngilizce',
    'Fen Bilgisi',
    'Mantık',
    'Bellek',
    'Hız',
    'Renk Eşleştirme',
  ];

  final List<String> _difficulties = ['Kolay', 'Orta', 'Zor'];
  final List<String> _ageGroups = ['4-6', '6-8', '8-10', '10-12', '12+'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _generateGame() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    try {
      // Simüle edilmiş AI üretimi (gerçek Gemini API yerine)
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Başarı mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 "${_titleController.text}" oyunu oluşturuluyor!',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Ana sayfaya dön
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 AI ile Oyun Oluştur'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bilgilendirme Kartı
              Card(
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.purple, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Yapay zeka senin için özel bir eğitici oyun tasarlayacak!',
                          style: TextStyle(
                            color: Colors.purple.shade900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Oyun Başlığı
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Oyun Başlığı',
                  hintText: 'Örn: Toplama Macerasısı',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Oyun başlığı gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Oyun Açıklaması
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Oyun Açıklaması',
                  hintText: 'Oyunun ne hakkında olmasını istiyorsun?',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama gerekli';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kategori Seçimi
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
              const SizedBox(height: 16),

              // Zorluk ve Yaş Grubu
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedDifficulty,
                      decoration: InputDecoration(
                        labelText: 'Zorluk',
                        prefixIcon: const Icon(Icons.speed),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _difficulties.map((diff) {
                        return DropdownMenuItem(
                          value: diff,
                          child: Text(diff),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedDifficulty = value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedAge,
                      decoration: InputDecoration(
                        labelText: 'Yaş',
                        prefixIcon: const Icon(Icons.child_care),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _ageGroups.map((age) {
                        return DropdownMenuItem(
                          value: age,
                          child: Text(age),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedAge = value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Özellikler
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✨ Oyun Özellikleri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem('🎨 Renkli ve eğlenceli tasarım'),
                      _buildFeatureItem('🏆 Puan ve rozet sistemi'),
                      _buildFeatureItem('📊 İlerleme takibi'),
                      _buildFeatureItem('🔊 Sesli geri bildirim'),
                      _buildFeatureItem('⚡ Hızlı ve akıcı oynanış'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Oluştur Butonu
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateGame,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.purple,
                ),
                icon: _isGenerating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(
                  _isGenerating ? 'Oluşturuluyor...' : '🚀 Oyunu Oluştur',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
