import 'package:androidcokro/SplashScreen.dart';
import 'package:androidcokro/cariProdukPage.dart';
import 'package:androidcokro/loginPage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          _checkInternetConnection(context);
          return const splashScreen();
        },
      ),
    );
  }

  void _checkInternetConnection(BuildContext context) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        _showNoInternetDialog(context);
      }
    } on SocketException catch (_) {
      _showNoInternetDialog(context);
    }
  }

  void _showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tidak Ada Jaringan'),
          content: Text('Periksa koneksi internet Anda dan coba lagi.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
