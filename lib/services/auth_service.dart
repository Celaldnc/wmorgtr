import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mevcut kullanıcı durum akışı
  Stream<User?> get userStream => _auth.authStateChanges();

  // Basit giriş yap
  Future<User?> signIn(String email, String password) async {
    try {
      print("Giriş denemesi: $email");
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Güvenli tip kontrolü ve kullanıcı bilgileri alımı
      User? user = result.user;
      print("Giriş başarılı: ${user?.uid}");

      // Kullanıcı varsa firestore'dan ek bilgileri al
      if (user != null) {
        try {
          await _getUserDetails(user.uid);
        } catch (e) {
          print("Kullanıcı detayları alınamadı, ama giriş hala geçerli: $e");
        }
      }

      return user;
    } catch (e) {
      print("Giriş hatası detayları: $e");
      // Hata kodunu özellikle yazdır
      if (e is FirebaseAuthException) {
        print("Firebase Auth hata kodu: ${e.code}");

        // Özel hata mesajları
        switch (e.code) {
          case 'user-not-found':
            throw Exception('Bu e-posta adresiyle kullanıcı bulunamadı');
          case 'wrong-password':
            throw Exception('Yanlış şifre girdiniz');
          case 'invalid-email':
            throw Exception('Geçersiz e-posta adresi');
          case 'user-disabled':
            throw Exception('Bu kullanıcı hesabı devre dışı bırakılmış');
          case 'too-many-requests':
            throw Exception(
              'Çok fazla giriş denemesi. Lütfen daha sonra tekrar deneyin',
            );
          default:
            throw Exception('Giriş başarısız: ${e.message}');
        }
      } else if (e.toString().contains("type 'List<Object?>'")) {
        // List türü hatası için özel işlem
        print(
          "List türü dönüşüm hatası yakalandı, Firebase sürümüyle ilgili bir sorun olabilir",
        );
        throw Exception(
          'Firebase API uyumsuzluğu, lütfen daha sonra tekrar deneyin',
        );
      }
      throw Exception('Giriş sırasında bir hata oluştu');
    }
  }

  // Kullanıcı detaylarını güvenli bir şekilde al
  Future<Map<String, dynamic>?> _getUserDetails(String userId) async {
    try {
      print("Kullanıcı detaylarını getirme girişimi: $userId için");
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        print("Kullanıcı detayları bulunamadı - belge mevcut değil");
        return null;
      }

      try {
        // Güvenli tip dönüşümü ve doğrulama
        final data = doc.data();
        if (data == null) {
          print("Belge var ama içeriği null");
          return null;
        }

        // Tip doğrulaması yaparak dönüştür
        print("Kullanıcı detayları başarıyla alındı: ${data['username']}");
        return data;
            } catch (castError) {
        print("Veri dönüşüm hatası: $castError");
        return null;
      }
    } catch (e) {
      print("Firestore veri okuma hatası: $e");
      return null;
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Basit kayıt ol
  Future<User?> register(
    String email,
    String password, {
    Map<String, dynamic>? userData,
  }) async {
    try {
      print("Kayıt işlemi başlıyor: $email");

      // Kayıt isteği göndermeden önce ağ durumunu kontrol etmek ideal olurdu

      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      print("Kayıt başarılı: ${user?.uid}");

      // Eğer kayıt başarılıysa ve kullanıcı bilgileri varsa, bunları Firestore'a kaydet
      if (user != null && userData != null) {
        try {
          await _saveUserDetails(user.uid, {
            ...userData,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print(
            "Kullanıcı detayları kaydedilemedi, ama kayıt hala geçerli: $e",
          );
        }
      }

      return user;
    } catch (e) {
      print("Kayıt hatası detaylı: $e");

      if (e is FirebaseAuthException) {
        print("Firebase Auth detaylı kayıt hatası kodu: ${e.code}");
        print("Firebase Auth detaylı mesajı: ${e.message}");

        // Bu kısmı daha ayrıntılı hale getirdik
        switch (e.code) {
          case 'email-already-in-use':
            throw Exception('Bu e-posta adresi zaten kullanımda');
          case 'invalid-email':
            throw Exception('Geçersiz e-posta adresi');
          case 'weak-password':
            throw Exception('Şifre çok zayıf. Daha güçlü bir şifre seçin');
          case 'operation-not-allowed':
            throw Exception(
              'E-posta/şifre girişi Firebase konsolunda etkin değil. Firebase konsolunda Authentication ayarlarını kontrol edin',
            );
          case 'network-request-failed':
            throw Exception(
              'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin',
            );
          default:
            throw Exception('Kayıt başarısız: ${e.code} - ${e.message}');
        }
      } else if (e is Exception) {
        print("Standart exception: ${e.toString()}");
        throw Exception('Kayıt sırasında bir hata oluştu: ${e.toString()}');
      } else {
        print("Bilinmeyen hata türü: ${e.runtimeType}");
        throw Exception('Beklenmeyen bir hata oluştu');
      }
    }
  }

  // Kullanıcı detaylarını Firestore'a kaydet
  Future<void> _saveUserDetails(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      print("Firestore'a veri yazma girişimi: $userId için");
      print("Kaydedilecek veri: $userData");

      // Koleksiyon ve belge referansını hazırla
      final userDocRef = _firestore.collection('users').doc(userId);

      // Veriyi kaydet ve sonucu bekle
      await userDocRef.set(userData);

      // Kontrol amaçlı veriyi hemen okuyalım
      final docSnapshot = await userDocRef.get();
      if (docSnapshot.exists) {
        print(
          "✅ Veri başarıyla kaydedildi ve doğrulandı: ${docSnapshot.data()}",
        );
      } else {
        print("❌ Veri kaydedildi ancak doğrulanamadı!");
      }

      print("Kullanıcı detayları Firestore'a kaydedildi");
    } catch (e) {
      print("Firestore veri yazma hatası detayı: $e");
      print("Hata türü: ${e.runtimeType}");

      if (e is FirebaseException) {
        print("Firebase hata kodu: ${e.code}");
        print("Firebase hata mesajı: ${e.message}");
      }

      rethrow; // Hata yönetimini üst metoda bırak
    }
  }
}
