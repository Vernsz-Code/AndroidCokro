import 'package:flutter/material.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(),
      body: Center(
        child: Container(
          padding: EdgeInsets.only(top: 20, left: 10, right: 10),
          height: 700,
          width: 600,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 60, 205, 65),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "CokroApp",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      child: Text("Login"),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Judul Dialog"),
                              content: Text("Ini adalah konten dari dialog."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Tutup"),
                                ),
                                TextButton(onPressed: (){
                                    Navigator.of(context).pop();
                                }, child: Text("Batalkan"))
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              Container(
                height: 5,
                width: 580,
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
