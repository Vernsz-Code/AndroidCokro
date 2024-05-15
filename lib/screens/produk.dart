import 'package:androidcokro/splash/SplashScreen.dart';
import 'package:androidcokro/credits/credit.dart';
import 'package:androidcokro/screens/produkKeluarPage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:androidcokro/services/ApiConfig.dart';

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  _ProdukState createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  List<dynamic> produkList = [];
  List<dynamic> filteredProdukList = [];
  TextEditingController searchController = TextEditingController();
  final Connectivity _connectivity = Connectivity();
  bool isLoading = false;
  String dropdownValue = 'Stok Terbanyak';

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

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
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const produkKeluarPage()));
                },
              ),
            ],
          );
        },
      );
    } else {
      fetchProduk();
    }
  }

  Future<void> fetchProduk() async {
    setState(() {
      isLoading = true;
    });
    try {
      String baseUrl = await ApiConfig.instance.readBaseUrl();
      final response = await get(Uri.parse('$baseUrl/get-data/products/all'),
          headers: {'api-key': 'Cokrok-kasir-apikey-098979'});
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body);
        if (decodedResponse['data'] != null) {
          setState(() {
            produkList = decodedResponse['data'];
            filteredProdukList = produkList;
            isLoading = false;
          });
        } else {
          isLoading = false;
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                      title: const Text('Data Produk Tidak Ditemukan.'),
                      actions: [
                        TextButton(
                            child: const Text('Oke'),
                            onPressed: () => Navigator.of(context).pop())
                      ]));
          throw Exception('Data produk tidak ditemukan dalam respons');
        }
      } else {
        isLoading = false;
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(
                    'Gagal memuat data dari API dengan status code: ${response.statusCode}, Coba lagi dalam 1 menit.'),
                actions: [
                  TextButton(
                    child: const Text('Oke'),
                    onPressed: () => {
                      Navigator.of(context).pop(),
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const produkKeluarPage()))
                    },
                  ),
                ],
              );
            });
        throw Exception(
            'Gagal memuat data dari API dengan status code: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
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

  void applyFilter() {
    List<dynamic> tempProdukList =
        List<dynamic>.from(produkList); // Buat salinan dari produkList asli

    switch (dropdownValue) {
      case 'Stok Terbanyak':
        tempProdukList
            .sort((a, b) => b['stok_akhir'].compareTo(a['stok_akhir']));
        break;
      case 'Stok Terdikit':
        tempProdukList
            .sort((a, b) => a['stok_akhir'].compareTo(b['stok_akhir']));
        break;
      case 'A-Z':
        tempProdukList.sort((a, b) => a['nama_brg'].compareTo(b['nama_brg']));
        break;
      case 'Z-A':
        tempProdukList.sort((a, b) => b['nama_brg'].compareTo(a['nama_brg']));
        break;
      case 'Stok Kosong':
        tempProdukList =
            tempProdukList.where((produk) => produk['stok_akhir'] < 0).toList();
        break;
    }

    setState(() {
      filteredProdukList =
          tempProdukList; // Gunakan tempProdukList yang sudah difilter
    });
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
              title: const Text(
                "Produk",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400),
              ),
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
              title: const Text('Produk',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Produk()),
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
                        color: Color.fromARGB(255, 240, 240, 240),
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
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
          : Column(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
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
                      flex: 1,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: dropdownValue,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownValue = newValue!;
                              applyFilter();
                            });
                          },
                          items: <String>[
                            'Stok Terbanyak',
                            'Stok Terdikit',
                            'A-Z',
                            'Z-A',
                            'Stok Kosong'
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProdukList.length,
                    itemBuilder: (context, index) {
                      var produk = filteredProdukList[index];
                      if (produk['stok_akhir'] > 0) {
                        return ListTile(
                          title: Text(
                            '${produk['kode_brg']} - ${produk['nama_brg']}',
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400),
                          ),
                          subtitle: Text(
                            'Harga: ${produk['jual'].toString()} - Stok: ${produk['stok_akhir'].toString()}',
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400),
                          ),
                        );
                      } else {
                        return ListTile(
                          title: Text(
                            '${produk['kode_brg']} - ${produk['nama_brg']}',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.red,
                                decorationThickness: 2,
                                color: Colors.grey.shade600),
                          ),
                          subtitle: Text(
                            'Harga: ${produk['jual'].toString()} - Stok: ${produk['stok_akhir'].toString()}',
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
