import 'package:androidcokro/credit.dart';
import 'package:androidcokro/produkKeluarPage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  _ProdukState createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  List<dynamic> produkList = [];
  List<dynamic> filteredProdukList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

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

  Future<void> fetchProduk() async {
    try {
      String baseUrl = await readBaseUrl();
      final response = await get(Uri.parse('$baseUrl/get-data/products/all'),
          headers: {'api-key': 'Cokrok-kasir-apikey-098979'});
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        if (decodedResponse['data'] != null) {
          setState(() {
            produkList = decodedResponse['data'];
            filteredProdukList = produkList;
          });
        } else {
          throw Exception('Data produk tidak ditemukan dalam respons');
        }
      } else {
        throw Exception(
            'Gagal memuat data dari API dengan status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Terjadi kesalahan saat memuat data: $e');
    }
  }

  void searchProduct(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredProdukList = produkList;
      });
    } else {
      List<dynamic> tempSearchList = [];
      for (var item in produkList) {
        // Periksa apakah query terdapat dalam kode_brg atau nama_brg
        if (item['nama_brg'].toLowerCase().contains(query.toLowerCase()) ||
            item['kode_brg'].toLowerCase().contains(query.toLowerCase())) {
          tempSearchList.add(item);
        }
      }
      setState(() {
        filteredProdukList = tempSearchList;
      });
    }
  }

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
              title: const Text("Produk Keluar"),
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
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return const produkKeluarPage();
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
            ListTile(
              title: const Text('Produk'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Produk()),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Cari Produk',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: searchProduct,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProdukList.length,
              itemBuilder: (context, index) {
                var produk = filteredProdukList[index];
                return ListTile(
                  title: Text('${produk['kode_brg']} - ${produk['nama_brg']}'),
                  subtitle: Text(
                      'Harga: ${produk['jual'].toString()} - Stok: ${produk['stok_akhir'].toString()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
