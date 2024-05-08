import 'package:androidcokro/SplashScreen.dart';
import 'package:androidcokro/cariProdukPage.dart';
import 'package:androidcokro/loginPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: splashScreen(),
    );
  }
}
