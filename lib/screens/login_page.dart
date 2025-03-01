import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wmorgtr_new/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;
  bool _isPasswordVisible = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Üst kısımda "login" metni
              const Text(
                'WMORGTR',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              // Merhaba başlık bölümü
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Hello\n',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'Again!',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Karşılama mesajı
              const Text(
                "Hoşgeldiniz, yeni bir yolculuk başlıyor!",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 40),
              // Kullanıcı adı alanı
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'E-posta',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'E-posta adresinizi girin',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Şifre alanı
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Şifre',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Şifrenizi girin',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Remember me ve Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Beni Hatırla'),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      // Şifre sıfırlama sayfasına yönlendirme
                    },
                    child: const Text(
                      'Şifremi Unuttum',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Login butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);

                    try {
                      final email = _usernameController.text.trim();
                      final password = _passwordController.text.trim();

                      // E-posta formatını kontrol et
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(email)) {
                        throw Exception('Geçerli bir e-posta adresi giriniz');
                      }

                      // Şifre kriterlerini kontrol et
                      if (password.length < 6) {
                        throw Exception('Şifre en az 6 karakter olmalıdır');
                      }

                      print("Giriş deneniyor: $email");
                      final user = await _authService.signIn(email, password);

                      if (user != null) {
                        print("Giriş başarılı, yönlendiriliyor");
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        // Bu kısım artık çalışmayacak çünkü AuthService'deki signIn metodu
                        // başarısız olduğunda Exception fırlatacak, null dönmeyecek
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Giriş başarısız, lütfen bilgilerinizi kontrol edin',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      print("Hata: $e");
                      String errorMessage;
                      if (e.toString().contains('Exception:')) {
                        errorMessage = e.toString().replaceAll(
                          'Exception: ',
                          '',
                        );
                      } else {
                        errorMessage = 'Giriş işlemi sırasında bir hata oluştu';
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 5),
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
                      setState(() => _isLoading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Giriş Yap',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ),
              const SizedBox(height: 8),
              // Test hesabı bilgisi
              Center(
                child: TextButton(
                  onPressed: () {
                    _usernameController.text = "test@test.com";
                    _passwordController.text = "Test123456";
                  },
                  child: Text(
                    'Test hesabıyla giriş yap',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Diğer giriş yöntemleri
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('veya devam et', style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 16),
              // Sosyal medya butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialLoginButton(
                    onTap: () {
                      // Facebook ile giriş
                    },
                    icon: Icons.facebook,
                    text: 'Facebook',
                  ),
                  _socialLoginButton(
                    onTap: () {
                      // Google ile giriş
                    },
                    icon: Icons.g_mobiledata,
                    text: 'Google',
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Kayıt ol kısmı
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Hesabın yok mu?"),
                  TextButton(
                    onPressed: () {
                      // Kayıt sayfasına yönlendirme
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Kayıt Ol',
                      style: TextStyle(
                        color: Colors.blue,
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
    );
  }

  Widget _socialLoginButton({
    required VoidCallback onTap,
    required IconData icon,
    required String text,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [Icon(icon), const SizedBox(width: 8), Text(text)],
        ),
      ),
    );
  }
}
