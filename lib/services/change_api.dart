import 'dart:convert';

import 'package:androidcokro/screens/loginPage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart';
import 'package:androidcokro/services/ApiConfig.dart';

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
    showAlert(context, 'Base Url: $baseUrl');
  } catch (e) {
    showAlert(context, 'Error: $e');
  }
}

Future<void> pingApi(BuildContext context) async {
  try {
    var baseUrl = await ApiConfig.instance.readBaseUrl();
    final response = await get(Uri.parse('$baseUrl/'),
        headers: {'api-key': 'Cokrok-kasir-apikey-098979'});

    if (response.statusCode == 200) {
      showAlert(context, 'Response: ${response.statusCode}');
    } else {
      showAlert(context, 'Response: ${response.statusCode}');
    }
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
                decoration: const InputDecoration(
                  hintText: 'Ex: https://example.com',
                  hintStyle: TextStyle(
                      fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    await writeJsonToFile(context, _apiController.text);
                    _apiController.clear();
                  },
                  child: const Text('Submit Api')),
              ElevatedButton(
                  onPressed: () async {
                    await readJsonFromFile(context);
                  },
                  child: const Text('Cek Api')),
              ElevatedButton(
                  onPressed: () async {
                    await pingApi(context);
                  },
                  child: const Text('Ping Api')),
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
