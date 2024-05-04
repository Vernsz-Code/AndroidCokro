import 'package:androidcokro/credit.dart';
import 'package:flutter/material.dart';

class produk extends StatelessWidget {
  const produk({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 22, 219, 101),
          ),
          child: SafeArea(
              child: Center(
            child: ListTile(
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(
                    Icons.menu_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: () => {Scaffold.of(context).openDrawer()},
                ),
              ),
              title: const Text("Produk"),
              trailing: IconButton(
                icon: const Icon(
                  Icons.exit_to_app_outlined,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () => {},
              ),
            ),
          )),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 100.0,
              color: const Color.fromARGB(255, 22, 178, 84),
              child: const DrawerHeader(
                child: Text(
                  'Cokro4Mart Cashier',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Produk Keluar'),
              onTap: () {
                // Add your logic here
              },
            ),
            ListTile(
              title: const Text('Produk'),
              onTap: () {
                // Add your logic here
              },
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return const credit();
                          },
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = const Offset(1.0, 0.0);
                            var end = Offset.zero;
                            var curve = Curves.ease;
                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    },
                    child: const Text(
                      'Credit',
                      style: TextStyle(
                        color: Color.fromARGB(255, 226, 225, 225),
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Row(
                    children: [
                      Expanded(flex: 4, child: Container()),
                      Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 50,
                            width: 10,
                            child: TextField(
                              autocorrect: false,
                              cursorColor: Colors.green,
                              showCursor: true,
                              textAlign: TextAlign.start,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                hintText: "Kode Barang",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50)),
                              )),
                          )),
                    ],
                  ),
                )),
            Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Table(
                    border: TableBorder.all(color: Colors.black, width: 1),
                    children: const [
                      TableRow(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 22, 219, 101),
                          ),
                          children: [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(3),
                                child: Text(
                                  "Text 1",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(3),
                                child: Text(
                                  "Text 2",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(3),
                                child: Text(
                                  "Text 3",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ]),
                    ],
                  ),
                )),
            Expanded(
                child: Row(children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        backgroundColor: const Color.fromARGB(255, 22, 219, 101)),
                    child: const Text(
                      'Cari Barang',
                      style: TextStyle(fontSize: 15.0, color: Colors.white),
                    )),
              )
            ]))
          ],
        ),
      ),
    );
  }
}
