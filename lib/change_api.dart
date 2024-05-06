import 'dart:convert';

import 'package:androidcokro/loginPage.dart';
import 'package:androidcokro/main.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class changeApi extends StatefulWidget {
  const changeApi({super.key});

  @override
  State<changeApi> createState() => _changeApiState();
}

TextEditingController _apiController = TextEditingController();

void showAlert(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("API CHANGES"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

// Fungsi untuk menulis data ke file JSON
Future<void> writeJsonToFile(BuildContext context, String api) async {
  final Map<String, dynamic> data = {'base_url': api};

  try {
    final directory = await getExternalStorageDirectory();
    final file = File('${directory?.path}/data.json');
    await file.writeAsString(jsonEncode(data));
    showAlert(context, 'Data berhasil dituliss ke file JSON.');
  } catch (e) {
    showAlert(context, 'Error: $e');
  }
}

Future<void> readJsonFromFile(BuildContext context) async {
  try {
    final directory = await getExternalStorageDirectory();
    final file = File('${directory?.path}/data.json');
    final data = await file.readAsString();
    final jsonData = jsonDecode(data);
    final String baseUrl = jsonData['base_url'];
    showAlert(context, 'Nama dari file JSON: $baseUrl');
  } catch (e) {
    showAlert(context, 'Error: $e');
  }
}

class _changeApiState extends State<changeApi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.center,
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _apiController,
                autocorrect: false,
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                textCapitalization: TextCapitalization.none,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await writeJsonToFile(context, _apiController.text);
                  },
                  child: const Text('Submit Api')),
              ElevatedButton(
                  onPressed: () async {
                    await readJsonFromFile(context);
                  },
                  child: const Text('Cek Api')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const loginPage()));
                  },
                  child: const Text('Kembali'))
            ],
          ),
        ),
      ),
    );
  }
}
