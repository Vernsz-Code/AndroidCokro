import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class credit extends StatelessWidget {
  const credit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200,
                height: 200,
                child: Image(image: AssetImage("images/1.png")),
              ),
              SizedBox(width: 8), // Jarak antara gambar
              Container(
                width: 200,
                height: 200,
                child: Image(image: AssetImage("images/2.png")),
              ),
              SizedBox(width: 8), // Jarak antara gambar
              Container(
                width: 200,
                height: 200,
                child: Image(image: AssetImage("images/3.png")),
              ),
              SizedBox(width: 8), // Jarak antara gambar
              Container(
                width: 200,
                height: 200,
                child: Image(image: AssetImage("images/4.png")),
              ),
              SizedBox(width: 8), // Jarak antara gambar
              Container(
                width: 200,
                height: 200,
                child: Image(image: AssetImage("images/5.png")),
              ),
              SizedBox(width: 8), // Jarak antara gambar
              Container(
                width: 200,
                height: 200,
                child: Image(image: AssetImage("images/6.png")),
              ),
              // Tambahkan lebih banyak widget Container gambar jika diperlukan
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 100),
              Container(
                width: 200,
                height: 200,
                child: Image(image: AssetImage("images/7.png")),
              ),
              SizedBox(width: 8), // Jarak antara gambar
              Container(
                width: 200,
                height: 200,
                child: Image(image: AssetImage("images/8.png")),
              ),
              SizedBox(width: 8), // Jarak antara gambar
              Container(
                width: 200,
                height: 200,
                child: Image(image: AssetImage("images/9.png")),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: Image(image: AssetImage("images/10.png")),
                  ), // Jarak antara gambar
                  Container(
                    width: 200,
                    height: 200,
                    child: Image(image: AssetImage("images/13.png")),
                  ), // Jarak antara gambar
                  Container(
                    width: 200,
                    height: 200,
                    child: Image(image: AssetImage("images/12.png")),
                  )
                ],
              )
            ],
          ),
          Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                Text(
                  'CREDIT',
                  style: TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                  textAlign: TextAlign.center,
                )
              ],
            )
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'APLIKASI INI DI BUAT DENGAN PENUH CINTA OLEH VERNSZ DAN KEPOLAU, PT RPL 1 JAYA ABADI 2024',
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900]),
            )
          ]),
          Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Easter Egg mWHEHEH"),
                        content: Text("RESTART UNTUK KEMBALI WKWKW"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Batalkan"),
                          ),
                        ],
                      );
                    });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Button border radius
                ),
                textStyle: TextStyle(
                  fontSize: 16, // Text size
                  fontWeight: FontWeight.bold, // Text weight
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('KEMBALI',
                      style: TextStyle(
                        fontSize: 50,
                      ))
                ],
              ),
            ),
          ])
        ],
      ),
    );
  }
}
