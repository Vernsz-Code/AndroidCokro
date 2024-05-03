import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:learn/produkKeluarPage.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<loginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<loginPage> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                      borderRadius: BorderRadius.circular(15)
                    ),
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
                            Container(
                              width: 500, // Lebar column
                              child: const TextField(
                                autocorrect: false,
                                cursorColor: Colors.blue,
                                showCursor: true,
                                textAlign: TextAlign.start,
                                textAlignVertical: TextAlignVertical.center,
                                textCapitalization: TextCapitalization.none,
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
                                  hintText: 'Masukkan teks',
                                  border: OutlineInputBorder(),
                                  labelText: "Username",
                                  labelStyle: TextStyle(
                                      color: Colors.blue, fontSize: 30.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 80.0),
                            Container(
                              width: 500, // Lebar column
                              child: TextField(
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
                                    Icons.person,
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
                                              size: 35,
                                              color: Colors.blue,
                                            )
                                          : const Icon(
                                              Icons.visibility_off,
                                              size: 35,
                                              color: Colors.blue,
                                            )),
                                  hintText: 'Masukkan teks',
                                  border: const OutlineInputBorder(),
                                  labelText: "Password",
                                  labelStyle: const TextStyle(
                                      color: Colors.blue, fontSize: 30.0),
                                ),
                              ),
                            ),
                            const SizedBox(height: 55.0),
                            Container(
                              width: 500,
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                            secondaryAnimation) {
                                          return produkKeluarPage();
                                        },
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          var begin = Offset(1.0, 0.0);
                                          var end = Offset.zero;
                                          var curve = Curves.ease;
                                          var tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));
                                          var offsetAnimation =
                                              animation.drive(tween);

                                          return SlideTransition(
                                            position: offsetAnimation,
                                            child: child,
                                          );
                                        },
                                        transitionDuration:
                                            Duration(milliseconds: 500),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ), // Button padding
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10), // Button border radius
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 16, // Text size
                                      fontWeight:
                                          FontWeight.bold, // Text weight
                                    ),
                                  ),
                                  child: Row(
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
    );
  }
}
