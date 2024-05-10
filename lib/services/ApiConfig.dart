import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ApiConfig {
  ApiConfig._privateConstructor();
  static final ApiConfig _instance = ApiConfig._privateConstructor();
  static ApiConfig get instance => _instance;

  Future<String> readBaseUrl() async {
  try {
    final directory = await getExternalStorageDirectory();
    final file = File('${directory?.path}/data.json');
    final data = await file.readAsString();
    final jsonData = jsonDecode(data);
    final String baseUrl = jsonData['base_url'];
    return baseUrl;
  } catch (e) {
    print(e);
    return 'Eror';
  }
}

}

