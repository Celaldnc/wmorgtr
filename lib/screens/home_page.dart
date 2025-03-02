import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
