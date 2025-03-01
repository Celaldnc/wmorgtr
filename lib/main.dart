import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:wmorgtr/screens/splash_screen.dart';
import 'package:wmorgtr/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WM Teknoloji Haber'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(child: Text('Ana Sayfa İçeriği Burada Görüntülenecek')),
    );
  }
}
