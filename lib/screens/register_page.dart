import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wmorgtr_new/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _jobController = TextEditingController();
  final _ageController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  // İlgi alanları için kontrol değişkenleri
  final Map<String, bool> _interests = {
    'Teknoloji': false,
    'Savaş': false,
    'Telefon': false,
    'Araba': false,
  };

  final _authService = AuthService();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _jobController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık
                Text(
                  'Yeni Hesap Oluştur',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Kullanıcı Adı
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen kullanıcı adınızı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // E-posta
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'E-posta',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen e-posta adresinizi girin';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Şifre
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Şifre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen şifrenizi girin';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Meslek
                TextFormField(
                  controller: _jobController,
                  decoration: InputDecoration(
                    labelText: 'Meslek',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.work),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen mesleğinizi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Yaş
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Yaş',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen yaşınızı girin';
                    }
                    try {
                      int age = int.parse(value);
                      if (age < 13 || age > 120) {
                        return 'Geçerli bir yaş girin (13-120)';
                      }
                    } catch (e) {
                      return 'Geçerli bir sayı girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // İlgi Alanları Başlığı
                const Text(
                  'İlgilendiğiniz Haber Türleri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // İlgi Alanları (Chip Seçenekleri)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children:
                      _interests.keys.map((String interest) {
                        return FilterChip(
                          label: Text(interest),
                          selected: _interests[interest]!,
                          onSelected: (bool selected) {
                            setState(() {
                              _interests[interest] = selected;
                            });
                          },
                          selectedColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          checkmarkColor: Theme.of(context).primaryColor,
                        );
                      }).toList(),
                ),

                // Hata Mesajı
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 32),

                // Kayıt Ol Butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                  _errorMessage = '';
                                });

                                try {
                                  // Kullanıcı bilgilerini Firestore için hazırla
                                  Map<String, dynamic> userData = {
                                    'username': _usernameController.text.trim(),
                                    'job': _jobController.text.trim(),
                                    'age':
                                        int.tryParse(
                                          _ageController.text.trim(),
                                        ) ??
                                        0,
                                    'interests':
                                        _interests.entries
                                            .where((entry) => entry.value)
                                            .map((entry) => entry.key)
                                            .toList(),
                                    'registeredAt':
                                        DateTime.now().toIso8601String(),
                                  };

                                  // Yeni AuthService kullanarak kayıt ol ve kullanıcı verilerini gönder
                                  final user = await _authService.register(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                    userData: userData,
                                  );

                                  if (user != null) {
                                    // Kayıt başarılı, giriş sayfasına yönlendir
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Kayıt başarılı! Giriş yapabilirsiniz.',
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                      ),
                                    );

                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/login',
                                    );
                                  }
                                } catch (e) {
                                  print("Kayıt hatası detayı: $e");

                                  // Hatanın daha ayrıntılı görüntülenmesi
                                  String errorMessage;

                                  if (e.toString().contains('Exception:')) {
                                    errorMessage = e.toString().replaceAll(
                                      'Exception: ',
                                      '',
                                    );
                                  } else if (e is FirebaseAuthException) {
                                    // Firebase Auth hata kodlarını da yazdır
                                    errorMessage =
                                        "Firebase hata kodu: ${e.code}, Mesaj: ${e.message}";
                                    print(
                                      "Firebase Auth detaylı hata: $errorMessage",
                                    );
                                  } else {
                                    errorMessage =
                                        'Kayıt sırasında bir hata oluştu: ${e.toString()}';
                                  }

                                  setState(() {
                                    _errorMessage = errorMessage;
                                  });

                                  // Ekranın altında daha görünür hata mesajı göster
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(errorMessage),
                                      backgroundColor: Colors.red,
                                      duration: Duration(seconds: 10),
                                      action: SnackBarAction(
                                        label: 'Tamam',
                                        textColor: Colors.white,
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).hideCurrentSnackBar();
                                        },
                                      ),
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Kayıt Ol',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),

                const SizedBox(height: 24),

                // Giriş Yap Linki
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Zaten hesabınız var mı?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Giriş Yap',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
