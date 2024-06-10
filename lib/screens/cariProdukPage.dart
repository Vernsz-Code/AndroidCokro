import 'package:androidcokro/screens/produkKeluarPage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:androidcokro/services/ApiConfig.dart';

class cariProdukPage extends StatefulWidget {
  final Function(Map<String, dynamic>) tambahKeTabel;

  const cariProdukPage({super.key, required this.tambahKeTabel});

  @override
  _cariProdukPageState createState() => _cariProdukPageState();
}

class _cariProdukPageState extends State<cariProdukPage> {
  List<dynamic> produkList = [];
  List<dynamic> filteredProdukList = [];
  TextEditingController searchController = TextEditingController();
  final Connectivity _connectivity = Connectivity();
  bool isLoading = false;

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

  void notice(BuildContext context, String msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
                title: const Text('Notice!'),
                content: Text(msg),
                actions: [
                  TextButton(
                      child: const Text('Oke'),
                      onPressed: () => Navigator.of(context).pop())
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Cari Produk',
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400)),
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Cari Produk',
                      labelStyle: TextStyle(
                          fontFamily: 'Poppins', fontWeight: FontWeight.w400),
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
                            onTap: () {
                              bool result = widget.tambahKeTabel(produk);
                              if (!result) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Stok Tidak Mencukupi'),
                                      content: Text(
                                          'Stok produk tidak mencukupi. Stok : ${produk['stok_akhir']}'),
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
                                Navigator.pop(
                                    context); // Kembali ke halaman sebelumnya jika berhasil
                              }
                            });
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
                            onTap: () {
                              notice(context,
                                  'Stok produk sudah habis. Mohon restock dahulu!');
                            });
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
