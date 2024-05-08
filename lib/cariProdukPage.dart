import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class cariProdukPage extends StatefulWidget {
  const cariProdukPage({super.key});

  @override
  _cariProdukPageState createState() => _cariProdukPageState();
}

class _cariProdukPageState extends State<cariProdukPage> {
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
        throw Exception('Gagal memuat data dari API dengan status code: ${response.statusCode}');
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
      appBar: AppBar(
        title: Text('Cari Produk'),
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
                  subtitle: Text('Harga: ${produk['jual'].toString()} - Stok: ${produk['stok_akhir'].toString()}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

