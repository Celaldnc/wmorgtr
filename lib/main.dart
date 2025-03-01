import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:wmorgtr_new/screens/splash_screen.dart';
import 'package:wmorgtr_new/screens/home_page.dart';
import 'package:wmorgtr_new/screens/login_page.dart';
import 'package:wmorgtr_new/screens/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wmorgtr_new/services/auth_service.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  // Flutter widget engine'i başlat
  WidgetsFlutterBinding.ensureInitialized();

  // Hata ayıklama bilgisi
  print("Firebase başlatılıyor...");

  try {
    // Önce Firebase'i başlat - bu adım çok önemli
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase başarıyla başlatıldı");

    // AppCheck'i Devre Dışı Bırak veya Debug modda çalıştır
    // Not: Gerçek projelerde bunu kullanmadan önce Firebase konsolunda AppCheck'i yapılandırın
    await FirebaseAppCheck.instance.activate(
      // Debug modda sahte token kullan
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
      webProvider: ReCaptchaV3Provider(
        '6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI',
      ), // Test recaptcha key
    );

    // Windows veya Web için ek ayarlar
    if (kIsWeb || (defaultTargetPlatform == TargetPlatform.windows)) {
      try {
        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
        print("Firebase Auth persistence ayarlandı");
      } catch (e) {
        print("Firebase Auth persistence ayarlama hatası: $e");
      }
    }

    // Firestore bağlantısını test et
    try {
      final firestore = FirebaseFirestore.instance;
      print("Firestore erişimi deneniyor...");

      // Test koleksiyonuna veri yazma denemesi
      final testDocRef = firestore
          .collection('test_collection')
          .doc('test_document');
      await testDocRef.set({
        'test_field': 'test_value',
        'timestamp': DateTime.now().toString(),
      });
      print("✅ Firestore test yazma başarılı");

      // Yazılan veriyi okuma denemesi
      final testDocSnapshot = await testDocRef.get();
      if (testDocSnapshot.exists) {
        print("✅ Firestore test okuma başarılı: ${testDocSnapshot.data()}");
      } else {
        print("❌ Firestore test belgesi okunamadı!");
      }
    } catch (e) {
      print("❌ Firestore test hatası: $e");
      if (e is FirebaseException) {
        print("Firebase hata kodu: ${e.code}");
        print("Firebase hata mesajı: ${e.message}");
      }
    }
  } catch (e) {
    print("Firebase servis başlatma hatası: $e");
    // Hata durumunda uygulama yine de çalışsın
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WM Teknoloji Haber',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Color(0xFFB21274), // WM.ORG.TR mor rengi
      ),
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}
