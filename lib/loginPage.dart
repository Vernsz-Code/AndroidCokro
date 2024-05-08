import 'dart:convert';

import 'package:androidcokro/change_api.dart';
import 'package:flutter/material.dart';
import 'package:androidcokro/produkKeluarPage.dart';
import 'package:http/http.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _LoginPageState();
}

TextEditingController userController = TextEditingController();
TextEditingController passController = TextEditingController();

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

Login(String user, String pass) async {
  try {
    String baseUrl = await readBaseUrl();
    Response response = await get(Uri.parse('$baseUrl/user/login/$user/$pass'),
        headers: {'api-key': 'Cokrok-kasir-apikey-098979'});

    if (response.statusCode == 200) {
      return "Login berhasil";
    } else if (response.statusCode == 404) {
      final data = jsonDecode(response.body);
      final message = data['message'];
      return message;
    } else {
      return "Failed to fetch api!";
    }
  } catch (e) {
    print(e);
    return "Kesalahan koneksi atau kesalahan lainnya";
  }
}

class _LoginPageState extends State<loginPage> {
  bool _obscureText = true;
  final Connectivity _connectivity = Connectivity();

  Future<void> checkConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Tidak Ada Koneksi Internet"),
            content: const Text("Pastikan Anda terhubung ke internet untuk melanjutkan."),
            actions: <Widget>[
              TextButton(
                child: const Text('Oke'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      loginProcess();
    }
  }

  Future<void> loginProcess() async {
    if (userController.text.isEmpty || passController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Form Kosong"),
            content: const Text('Tolong isi user atau pass dengan benar!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Oke"),
              )
            ],
          );
        });
    } else if (userController.text == 'api' && passController.text == 'config') {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const changeApi(),
      ));
    } else {
      String response = await Login(userController.text, passController.text);
      if (response == "Login berhasil") {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const produkKeluarPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = const Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Login Gagal"),
              content: Text(response),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Oke"),
                )
              ],
            );
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 50.0,
                left: 10.0,
                right: 10.0), // Memberikan jarak dari bagian atas
            child: Row(
              // Mengatur lebar minimum
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Image(
                  image: AssetImage("images/200.png"),
                  width: 200.0,
                  height: 200.0,
                  alignment: Alignment.topLeft,
                ),
                Expanded(
                  child: Container(
                    height: 650.0,
                    width: 700.0,
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 56, 38, 150),
                        borderRadius: BorderRadius.circular(15)),
                    child: Center(
                      child: Column(children: [
                        const Text(
                          'LOGIN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 100.0,
                            fontFamily: 'rubik',
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 80.0),
                            SizedBox(
                              width: 500, // Lebar column
                              child: TextField(
                                controller: userController,
                                autocorrect: false,
                                cursorColor: Colors.blue,
                                showCursor: true,
                                textAlign: TextAlign.start,
                                textAlignVertical: TextAlignVertical.center,
                                textCapitalization: TextCapitalization.none,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20.0,
                                ),
                                decoration: const InputDecoration(
                                  icon: Icon(
                                    Icons.person,
                                    size: 35,
                                    color: Colors.blue,
                                  ),
                                  hintText: 'Masukkan username',
                                  hintStyle: TextStyle(
                                    color: Colors.blue,
                                  ),
                                  border: OutlineInputBorder(),
                                  labelText: "Username",
                                  labelStyle: TextStyle(
                                      color: Colors.blue, fontSize: 30.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 50.0),
                            SizedBox(
                              width: 500, // Lebar column
                              child: TextField(
                                controller: passController,
                                autocorrect: false,
                                cursorColor: Colors.blue,
                                showCursor: true,
                                textAlign: TextAlign.start,
                                textAlignVertical: TextAlignVertical.center,
                                textCapitalization: TextCapitalization.none,
                                obscureText: _obscureText,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20.0,
                                ),
                                decoration: InputDecoration(
                                  icon: const Icon(
                                    Icons.lock,
                                    size: 35,
                                    color: Colors.blue,
                                  ),
                                  suffix: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureText =
                                              !_obscureText; // Memperbarui status teks tersembunyi
                                        });
                                      },
                                      icon: _obscureText
                                          ? const Icon(
                                              Icons.visibility,
                                              size: 25,
                                              color: Colors.blue,
                                            )
                                          : const Icon(
                                              Icons.visibility_off,
                                              size: 25,
                                              color: Colors.blue,
                                            )),
                                  hintText: 'Masukkan password',
                                  hintStyle: const TextStyle(
                                    color: Colors.blue,
                                  ),
                                  border: const OutlineInputBorder(),
                                  labelText: "Password",
                                  labelStyle: const TextStyle(
                                      color: Colors.blue, fontSize: 30.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 55.0),
                            SizedBox(
                              width: 500,
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await checkConnection();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ), // Button padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // Button border radius
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16, // Text size
                                      fontWeight:
                                          FontWeight.bold, // Text weight
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image(
                                        image: AssetImage("images/k4.png"),
                                        width: 70.0,
                                        height: 70.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ]),
                    ),
                  ),
                ),
                const Image(
                  image: AssetImage("images/smk.png"),
                  width: 200.0,
                  height: 200.0,
                  alignment: Alignment.topRight,
                )
              ],
            ),
          ),
        ],
      )),
    ));
  }
}
