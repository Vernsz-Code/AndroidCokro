import 'package:androidcokro/splash/SplashScreen.dart';
import 'package:androidcokro/screens/cariProdukPage.dart';
import 'package:androidcokro/credits/credit.dart';
import 'package:androidcokro/screens/produk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:androidcokro/services/ApiConfig.dart';

class produkKeluarPage extends StatefulWidget {
  const produkKeluarPage({super.key});

  @override
  State<produkKeluarPage> createState() => _produkKeluarPageState();
}


class _produkKeluarPageState extends State<produkKeluarPage> {
  final TextEditingController _controllerKode = TextEditingController();

  int kembalian = 0;
  int totalbayar = 0;
  int faktur = 0;

  bool kredit = false;

  List<Map<String, dynamic>> tableData = [];

  Future<void> fetchData(String kodeBarang) async {
    var base = await ApiConfig.instance.readBaseUrl();
    var url = '$base/get-data/products/$kodeBarang';
    var response = await get(Uri.parse(url),
        headers: {'api-key': 'Cokrok-kasir-apikey-098979'});

    if (response.statusCode == 200 || response.statusCode == 404) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['message'] == "Success fetch data" &&
          jsonResponse['data'] is List) {
        List<Map<String, dynamic>> newData = List<Map<String, dynamic>>.from(
            jsonResponse['data']
                .map((item) => Map<String, dynamic>.from(item)));
        setState(() {
          for (var newItem in newData) {
            var existingItem = tableData.firstWhere(
              (item) => item['kode_brg'] == newItem['kode_brg'],
              orElse: () => <String, dynamic>{},
            );
            if (existingItem.isNotEmpty) {
              existingItem['quantity'] +=
                  1; // Menambah quantity jika kode barang sama
            } else {
              newItem['quantity'] = 1; // Set quantity awal jika barang baru
              tableData.add(newItem);
            }
          }
        });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                    title: const Text('Tidak ada barang dengan kode itu!'),
                    actions: [
                      TextButton(
                          child: const Text('Oke'),
                          onPressed: () => Navigator.of(context).pop())
                    ]));
        throw Exception('Data fetch was successful but no data found');
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                  title: const Text('Gagal mengambil data.'),
                  actions: [
                    TextButton(
                        child: const Text('Oke'),
                        onPressed: () => Navigator.of(context).pop())
                  ]));
      throw Exception(
          'Failed to load data with status code: ${response.statusCode}');
    }
  }

  Future<void> getFaktur() async {
    var base = await ApiConfig.instance.readBaseUrl();
    var url = '$base/get-data/no_faktur';
    var response = await get(Uri.parse(url),
        headers: {'api-key': 'Cokrok-kasir-apikey-098979'});

    if (response.statusCode == 200) {
      var jsonDec = json.decode(response.body);
      if (jsonDec['message'] == 'Success fetch data') {
        setState(() {
          faktur = (jsonDec['data'][0]['MAX(no_faktur)'] ?? 0) + 1;
        });
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                    title: const Text('Gagal mengambil data.'),
                    actions: [
                      TextButton(
                          child: const Text('Oke'),
                          onPressed: () => Navigator.of(context).pop())
                    ]));
        throw Exception(
            'Failed to load data with status code: ${response.statusCode}');
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                  title: const Text('Gagal mengambil data.'),
                  actions: [
                    TextButton(
                        child: const Text('Oke'),
                        onPressed: () => Navigator.of(context).pop())
                  ]));
      throw Exception(
          'Failed to load data with status code: ${response.statusCode}');
    }
  }

  void editQuantity(Map<String, dynamic> item) {
    TextEditingController quantityController =
        TextEditingController(text: item['quantity'].toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Quantity'),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Masukkan Quantity"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Oke'),
              onPressed: () {
                setState(() {
                  if (quantityController.text.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                                title: const Text('Quantity tidak boleh kosong'),
                                actions: [
                                  TextButton(
                                      child: const Text('Oke'),
                                      onPressed: () =>
                                          Navigator.of(context).pop())
                                ]));
                  }
                  int index = tableData.indexOf(item);
                  tableData[index]['quantity'] =
                      int.parse(quantityController.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  int getTotalProduk() {
    int total = 0;
    for (var item in tableData) {
      total += item['quantity'] as int;
    }
    return total;
  }

  int getTotalHarga() {
    int total = 0;
    for (var item in tableData) {
      total += item['jual'] * item['quantity'] as int;
    }
    return total;
  }

  void updateTotalBayar(int total) {
    setState(() {
      totalbayar = total;
      Kembalian(totalbayar, getTotalHarga());
    });
  }

  void Kembalian(int Totalbayar, int totalHarga) {
    setState(() {
      kembalian = Totalbayar - totalHarga;
    });
  }

  void hapusItem(Map<String, dynamic> item) {
    setState(() {
      tableData.remove(item);
    });
  }

  void tambahKeTabel(Map<String, dynamic> produkBaru) {
    setState(() {
      // Cari produk dalam tableData berdasarkan 'kode_brg'
      var index = tableData
          .indexWhere((item) => item['kode_brg'] == produkBaru['kode_brg']);

      if (index != -1) {
        // Produk sudah ada, tingkatkan quantity
        tableData[index]['quantity'] += 1;
      } else {
        // Produk belum ada, tambahkan dengan quantity 1
        produkBaru['quantity'] = 1;
        tableData.add(produkBaru);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getFaktur();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              title: const Text("Produk Keluar",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400)),
              trailing: IconButton(
                icon: const Icon(
                  Icons.exit_to_app_outlined,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () => {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const splashScreen()),
                  )
                },
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
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            ListTile(
              title: const Text('Produk Keluar',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const produkKeluarPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Produk',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400)),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return const Produk();
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
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacement(
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
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          'No Faktur : $faktur',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800,
                              fontSize: 20),
                        ),
                      )),
                      Expanded(flex: 4, child: Container()),
                      Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 30,
                            width: 10,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 22, 219, 101),
                                  padding: const EdgeInsets.only(left: 3)),
                              child: const Text("Cetak",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400)),
                              onPressed: () => {},
                            ),
                          )),
                    ],
                  ),
                )),
            Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Total Produk : ${getTotalProduk()}',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Total Harga : ${getTotalHarga()}',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20),
                            )
                          ],
                        ),
                        const Column(
                          children: [
                            Text(
                              'Total Diskon : 0',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Total Bayar : $totalbayar',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20),
                            )
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Kembalian : $kembalian',
                              style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20),
                            )
                          ],
                        )
                      ]),
                )),
            Expanded(
                child: Container(
              padding: const EdgeInsets.only(left: 30, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: 200,
                      child: TextField(
                        controller: _controllerKode,
                        autocorrect: false,
                        cursorColor: Colors.green,
                        showCursor: true,
                        textAlign: TextAlign.start,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: "Kode Barang...",
                          hintStyle: const TextStyle(
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: () {
                              fetchData(_controllerKode.text);
                              _controllerKode.clear();
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          fetchData(value);
                          _controllerKode.clear();
                        },
                      )),
                  Row(
                    children: [
                      SizedBox(
                          width: 200,
                          child: TextField(
                            autocorrect: false,
                            cursorColor: Colors.green,
                            showCursor: true,
                            textAlign: TextAlign.start,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                                hintText: "Bayar Rp.",
                                hintStyle: const TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                icon: const Icon(Icons.payment)),
                            onChanged: (String value) {
                              updateTotalBayar(int.tryParse(value) ?? 0);
                            },
                          )),
                      Checkbox(
                        value: kredit,
                        onChanged: (bool? newValue) {
                          setState(() {
                            kredit = newValue ?? false;
                          });
                        },
                      ),
                      const Text("Credit")
                    ],
                  )
                ],
              ),
            )),
            Expanded(
              flex: 6,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 160,
                  columns: const [
                    DataColumn(
                        label: Text(
                      'Kode Barang',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                    )),
                    DataColumn(
                        label: Text(
                      'Nama Barang',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                    )),
                    DataColumn(
                        label: Text(
                      'Quantity',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                    )),
                    DataColumn(
                        label: Text(
                      'Harga (pcs)',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                    )),
                    DataColumn(
                        label: Text(
                      'Aksi',
                      style: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w400),
                    )),
                  ],
                  rows: tableData
                      .map((item) => DataRow(
                            cells: [
                              DataCell(Text(
                                item['kode_brg'],
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400),
                              )),
                              DataCell(Text(
                                item['nama_brg'],
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400),
                              )),
                              DataCell(
                                  Text(
                                    item['quantity'].toString(),
                                    style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400),
                                  ),
                                  onTap: () => editQuantity(
                                      item)), // Menampilkan quantity
                              DataCell(Text(
                                item['jual'].toString(),
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400),
                              )),
                              DataCell(const Icon(Icons.delete),
                                  onTap: () => hapusItem(item)),
                            ],
                          ))
                      .toList(),
                ),
              ),
            ),
            Expanded(
                child: Row(children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) {
                            return cariProdukPage(tambahKeTabel: tambahKeTabel);
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
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        backgroundColor:
                            const Color.fromARGB(255, 22, 219, 101)),
                    child: const Text(
                      'Cari Barang',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400),
                    )),
              )
            ]))
          ],
        ),
      ),
    );
  }
}
