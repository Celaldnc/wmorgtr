import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/unified_news_provider.dart';
import '../models/news_model.dart';

class CreateNewsScreen extends StatefulWidget {
  const CreateNewsScreen({Key? key}) : super(key: key);

  @override
  State<CreateNewsScreen> createState() => _CreateNewsScreenState();
}

class _CreateNewsScreenState extends State<CreateNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _excerptController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _sourceController = TextEditingController();

  List<int> _selectedCategories = [];
  bool _isLoading = false;

  // Kategori listesi
  final List<Map<String, dynamic>> _categories = [
    {'id': 1, 'name': 'Teknoloji'},
    {'id': 2, 'name': 'Bilim'},
    {'id': 3, 'name': 'Yazılım'},
    {'id': 4, 'name': 'Donanım'},
    {'id': 5, 'name': 'Mobil'},
    {'id': 6, 'name': 'Oyun'},
    {'id': 7, 'name': 'İnternet'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _excerptController.dispose();
    _imageUrlController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir kategori seçin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Haber modelini oluştur
      final news = NewsModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text,
        content: _contentController.text,
        excerpt: _excerptController.text,
        date: DateTime.now().toIso8601String(),
        link: '',
        featuredImageUrl: _imageUrlController.text,
        source: _sourceController.text,
        categories: _selectedCategories,
        authorName:
            'Kullanıcı', // Gerçek uygulamada giriş yapan kullanıcının adı
      );

      // Provider üzerinden haberi kaydet
      // await Provider.of<UnifiedNewsProvider>(context, listen: false).createNews(news);

      // Başarılı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Haber başarıyla oluşturuldu')),
      );

      // Önceki sayfaya dön
      Navigator.pop(context);
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Haber Oluştur'),
        backgroundColor: const Color(0xFFB21274),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitForm,
            child: Text(
              'Paylaş',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Başlık',
                            hintText: 'Haberin başlığını girin',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          maxLength: 100,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen bir başlık girin';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Özet
                        TextFormField(
                          controller: _excerptController,
                          decoration: InputDecoration(
                            labelText: 'Özet',
                            hintText: 'Haberin kısa özetini girin',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          maxLength: 150,
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen bir özet girin';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // İçerik
                        TextFormField(
                          controller: _contentController,
                          decoration: InputDecoration(
                            labelText: 'İçerik',
                            hintText: 'Haberin içeriğini girin',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            alignLabelWithHint: true,
                          ),
                          maxLines: 10,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen içerik girin';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Görsel URL
                        TextFormField(
                          controller: _imageUrlController,
                          decoration: InputDecoration(
                            labelText: 'Görsel URL',
                            hintText: 'Haberin görselinin URL adresini girin',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.image),
                              onPressed: () {
                                // Görsel seçme işlemi
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen bir görsel URL girin';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Kaynak
                        TextFormField(
                          controller: _sourceController,
                          decoration: InputDecoration(
                            labelText: 'Kaynak',
                            hintText: 'Haberin kaynağını girin',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen bir kaynak girin';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Kategoriler
                        const Text(
                          'Kategoriler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _categories.map((category) {
                                final isSelected = _selectedCategories.contains(
                                  category['id'],
                                );
                                return FilterChip(
                                  label: Text(category['name']),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedCategories.add(category['id']);
                                      } else {
                                        _selectedCategories.remove(
                                          category['id'],
                                        );
                                      }
                                    });
                                  },
                                  selectedColor: const Color(
                                    0xFFB21274,
                                  ).withOpacity(0.2),
                                  checkmarkColor: const Color(0xFFB21274),
                                  backgroundColor: Colors.grey[200],
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 32),

                        // Gönder butonu
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB21274),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Haberi Paylaş',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
