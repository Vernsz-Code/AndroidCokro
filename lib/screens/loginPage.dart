import 'dart:convert';

import 'package:androidcokro/services/change_api.dart';
import 'package:flutter/material.dart';
import 'package:androidcokro/screens/produkKeluarPage.dart';
import 'package:http/http.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:androidcokro/services/ApiConfig.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _LoginPageState();
}

TextEditingController userController = TextEditingController();
TextEditingController passController = TextEditingController();

Login(String user, String pass) async {
  try {
    String baseUrl = await ApiConfig.instance.readBaseUrl();
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
  bool _isLoading = false;

  Future<void> checkConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Tidak Ada Koneksi Internet"),
            content: const Text(
                "Pastikan Anda terhubung ke internet untuk melanjutkan."),
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
    } else if (userController.text == 'api' &&
        passController.text == 'config') {
      userController.clear();
      passController.clear();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const changeApi(),
      ));
    } else {
      setState(() {
        _isLoading = true;
      });
      String response = await Login(userController.text, passController.text);
      if (response == "Login berhasil") {
        userController.clear();
        passController.clear();
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const produkKeluarPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              var begin = const Offset(1.0, 0.0);
              var end = Offset.zero;
              var curve = Curves.ease;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Memuat...')
                ],
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: screenHeight * 0.05,
                        left: 10.0,
                        right: 10.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image(
                            image: AssetImage("images/200.png"),
                            width: screenWidth * 0.2,
                            height: screenHeight * 0.2,
                            alignment: Alignment.topLeft,
                          ),
                          Expanded(
                            child: Container(
                              height: screenHeight * 0.8,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 56, 38, 150),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: SingleChildScrollView(
                                  child: Column(children: [
                                    Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.1,
                                        fontFamily: 'rubik',
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(height: screenHeight * 0.08),
                                        SizedBox(
                                          width: screenWidth * 0.5,
                                          child: TextField(
                                            controller: userController,
                                            autocorrect: false,
                                            cursorColor: Colors.blue,
                                            showCursor: true,
                                            textAlign: TextAlign.start,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            textCapitalization:
                                                TextCapitalization.none,
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 20.0,
                                            ),
                                            decoration: InputDecoration(
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
                                                  color: Colors.blue,
                                                  fontSize: 30.0),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.05),
                                        SizedBox(
                                          width: screenWidth * 0.5,
                                          child: TextField(
                                            controller: passController,
                                            autocorrect: false,
                                            cursorColor: Colors.blue,
                                            showCursor: true,
                                            textAlign: TextAlign.start,
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            textCapitalization:
                                                TextCapitalization.none,
                                            obscureText: _obscureText,
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 20.0,
                                            ),
                                            decoration: InputDecoration(
                                              icon: Icon(
                                                Icons.lock,
                                                size: 35,
                                                color: Colors.blue,
                                              ),
                                              suffix: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscureText =
                                                          !_obscureText;
                                                    });
                                                  },
                                                  icon: _obscureText
                                                      ? Icon(
                                                          Icons.visibility,
                                                          size: 25,
                                                          color: Colors.blue,
                                                        )
                                                      : Icon(
                                                          Icons.visibility_off,
                                                          size: 25,
                                                          color: Colors.blue,
                                                        )),
                                              hintText: 'Masukkan password',
                                              hintStyle: TextStyle(
                                                color: Colors.blue,
                                              ),
                                              border: OutlineInputBorder(),
                                              labelText: "Password",
                                              labelStyle: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 30.0),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.05),
                                        SizedBox(
                                          width: screenWidth * 0.5,
                                          child: Center(
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                await checkConnection();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 10,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                textStyle: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image(
                                                    image: AssetImage(
                                                        "images/k4.png"),
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
                          ),
                          Image(
                            image: AssetImage("images/smk.png"),
                            width: screenWidth * 0.2,
                            height: screenHeight * 0.2,
                            alignment: Alignment.topRight,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
