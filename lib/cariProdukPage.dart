import 'package:flutter/material.dart';

class cariProdukPage extends StatelessWidget {
  const cariProdukPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(),
        body: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            children: [
              Expanded(
                  flex: 1,
                  child: Align(
                      alignment: Alignment.topRight,
                      child: SizedBox(
                          width: 300,
                          child: TextField(
                            decoration: InputDecoration(
                                hintText: "Masukan Kode Atau Nama Barang"),
                          )))),
              Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Table(
                        border: TableBorder.all(color: Colors.black, width: 3),
                        children: [
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
                                )
                              ])
                        ],
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }
}
