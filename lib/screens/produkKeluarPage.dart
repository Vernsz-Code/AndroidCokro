import 'package:androidcokro/model/fakMod.dart';
import 'package:androidcokro/splash/SplashScreen.dart';
import 'package:androidcokro/screens/cariProdukPage.dart';
import 'package:androidcokro/credits/credit.dart';
import 'package:androidcokro/screens/produk.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:androidcokro/services/ApiConfig.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';

class produkKeluarPage extends StatefulWidget {
  const produkKeluarPage({super.key});

  @override
  State<produkKeluarPage> createState() => _produkKeluarPageState();
}

class _produkKeluarPageState extends State<produkKeluarPage> {
  final TextEditingController _controllerKode = TextEditingController();
  late NetworkPrinter printer;
  NumberFormat rupiahFormat = NumberFormat.decimalPattern('id');

  int kembalian = 0;
  int totalbayar = 0;
  int faktur = 0;

  bool isLoading = false;

  List<Map<String, dynamic>> tableData = [];

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
            if (newItem['stok_akhir'] > 0) {
              var existingItem = tableData.firstWhere(
                (item) => item['kode_brg'] == newItem['kode_brg'],
                orElse: () => <String, dynamic>{},
              );
              if (existingItem.isNotEmpty) {
                if (existingItem['quantity'] < newItem['stok_akhir']) {
                  existingItem['quantity'] +=
                      1; // Menambah quantity jika kode barang sama
                } else {
                  notice(context,
                      'Stok ${newItem['nama_brg']} tidak mencukupi, Stok : ${newItem['stok_akhir']}');
                }
              } else {
                newItem['quantity'] = 1; // Set quantity awal jika barang baru
                tableData.add(newItem);
              }
            } else {
              notice(context, 'Stok ${newItem['nama_brg']} sudah habis!');
            }
          }
          Kembalian(totalbayar, getTotalHarga());
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
          builder: (BuildContext context) =>
              AlertDialog(title: const Text('Gagal mengambil data.'), actions: [
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
                    content: Text(
                        'Gagal mendapatkan faktur, Status Code: ${response.statusCode}'),
                    actions: [
                      TextButton(
                          child: const Text('Oke'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => produkKeluarPage()));
                          })
                    ]));
        throw Exception(
            'Failed to load data with status code: ${response.statusCode}');
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                  title: const Text('Gagal mengambil data.'),
                  content: Text(
                      'Gagal mendapatkan faktur, Status Code: ${response.statusCode}'),
                  actions: [
                    TextButton(
                        child: const Text('Oke'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => produkKeluarPage()));
                        })
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
                int newQuantity = int.tryParse(quantityController.text) ?? 0;
                if (newQuantity <= 0) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                              title: const Text('Quantity tidak valid'),
                              content:
                                  const Text('Quantity harus lebih dari 0.'),
                              actions: [
                                TextButton(
                                    child: const Text('Oke'),
                                    onPressed: () =>
                                        Navigator.of(context).pop())
                              ]));
                } else if (newQuantity > item['stok_akhir']) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                              title: const Text('Quantity melebihi stok'),
                              content:
                                  Text('Stok tersedia: ${item['stok_akhir']}'),
                              actions: [
                                TextButton(
                                    child: const Text('Oke'),
                                    onPressed: () =>
                                        Navigator.of(context).pop())
                              ]));
                } else {
                  setState(() {
                    int index = tableData.indexOf(item);
                    tableData[index]['quantity'] = newQuantity;
                    Kembalian(totalbayar, getTotalHarga());
                  });
                  Navigator.of(context).pop();
                }
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

  bool tambahKeTabel(Map<String, dynamic> produkBaru) {
    var index = tableData
        .indexWhere((item) => item['kode_brg'] == produkBaru['kode_brg']);

    if (index != -1) {
      if (tableData[index]['quantity'] < produkBaru['stok_akhir']) {
        setState(() {
          tableData[index]['quantity'] += 1;
          Kembalian(totalbayar, getTotalHarga());
        });
        return true;
      } else {
        return false; // Stok tidak mencukupi
      }
    } else {
      if (produkBaru['stok_akhir'] > 0) {
        setState(() {
          produkBaru['quantity'] = 1;
          tableData.add(produkBaru);
          Kembalian(totalbayar, getTotalHarga());
        });
        return true;
      } else {
        return false; // Stok habis
      }
    }
  }

  Future<void> printReceipt() async {
    // int nomorFaktur = faktur;
    String totalHargaRupiah = rupiahFormat.format(getTotalHarga());

    List<FakturItem> items = tableData
        .map((item) => FakturItem(
            description: item['nama_brg'],
            price: item['jual'],
            quantity: item['quantity']))
        .toList();

    final profile = await CapabilityProfile.load();
    final printer = NetworkPrinter(PaperSize.mm80, profile);

    final result = await printer.connect('192.168.232.2', port: 9100);

    if (result == PosPrintResult.success) {
      try {
        // Muat gambar BMP dari assets
        // final ByteData data = await rootBundle.load('images/tech.bmp');
        // final buffer = data.buffer;
        // final imageBytes =
        //     buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        // final image = img.decodeBmp(imageBytes);

        // // Pastikan gambar tidak null
        // if (image != null) {
        //   int newWidth = 150; // Lebar baru dalam piksel
        //   int newHeight = 150; // Tinggi baru dalam piksel
        //   img.Image resizedImage =
        //       img.copyResize(image, width: newWidth, height: newHeight);

        //   // Print gambar yang telah diubah ukurannya
        //   printer.image(resizedImage);
        // }

        printer.text('Cokro4Mart',
            styles: const PosStyles(
              align: PosAlign.center,
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            ),
            linesAfter: 1);

        printer.text('Jl. Hos Cokroaminoto No 102,',
            styles: PosStyles(align: PosAlign.center));
        printer.text('Enggal, Bandar Lampung',
            styles: PosStyles(align: PosAlign.center), linesAfter: 1);

        printer.hr();

        printer.row([
          PosColumn(text: 'Jumlah', width: 2),
          PosColumn(text: 'Nama Barang', width: 5),
          PosColumn(
              text: 'Price',
              width: 2,
              styles: PosStyles(align: PosAlign.right)),
          PosColumn(
              text: 'Total',
              width: 3,
              styles: PosStyles(align: PosAlign.right)),
        ]);

        for (FakturItem item in items) {
          printer.row([
            PosColumn(text: item.quantity.toString(), width: 2),
            PosColumn(text: item.description, width: 4),
            PosColumn(
                text: rupiahFormat.format(item.price),
                width: 3,
                styles: PosStyles(align: PosAlign.right)),
            PosColumn(
                text: rupiahFormat.format(item.price * item.quantity),
                width: 3,
                styles: PosStyles(align: PosAlign.right)),
          ]);
        }

        printer.hr();

        printer.row([
          PosColumn(
              text: 'TOTAL',
              width: 4,
              styles: PosStyles(
                height: PosTextSize.size2,
                width: PosTextSize.size2,
              )),
          PosColumn(
              text: '\ ${totalHargaRupiah}',
              width: 8,
              styles: PosStyles(
                align: PosAlign.right,
                height: PosTextSize.size2,
                width: PosTextSize.size2,
              )),
        ]);

        printer.hr(ch: '=', linesAfter: 1);

        printer.row([
          PosColumn(
              text: 'Tunai :',
              width: 8,
              styles:
                  PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
          PosColumn(
              text: '\ ${rupiahFormat.format(totalbayar)}',
              width: 4,
              styles:
                  PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
        ]);
        printer.row([
          PosColumn(
              text: 'Kembalian :',
              width: 8,
              styles:
                  PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
          PosColumn(
              text: '\ ${rupiahFormat.format(kembalian)}',
              width: 4,
              styles:
                  PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
        ]);

        printer.feed(2);
        printer.text('TERIMAKASIH TELAH BERBELANJA DI COKRO4MART',
            styles: PosStyles(align: PosAlign.center, bold: true));

        final now = DateTime.now();
        final formatter = DateFormat('MM/dd/yyyy H:m');
        final String timestamp = formatter.format(now);
        printer.text(timestamp,
            styles: PosStyles(align: PosAlign.center), linesAfter: 2);

        printer.cut();
      } finally {
        printer.disconnect();
      }
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text('Failed to connect to printer: $result'),
                  actions: [
                    TextButton(
                        child: Text('Oke'),
                        onPressed: () => Navigator.of(context).pop())
                  ]));
    }
  }

  Future<void> updateStok() async {
    var base = await ApiConfig.instance.readBaseUrl();
    var url = '$base/update-data/product';

    // Mengumpulkan data yang akan dikirim
    List<Map<String, dynamic>> updatedData = tableData.map((item) {
      return {
        'kode': item['kode_brg'],
        'qty': item[
            'quantity'], // Misalnya, field yang ingin di-update adalah quantity
        // Tambahkan field lain jika diperlukan
      };
    }).toList();

    // Mengubah data ke JSON
    String jsonData = jsonEncode(updatedData);

    // Mengirim request PUT
    var response = await put(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'api-key': 'Cokrok-kasir-apikey-098979'
        },
        body: jsonData);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['data'][0]['success'] == true) {
        print("Data berhasil diupdate");
        tambahTransaksi();
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text(
                        '${jsonResponse['data'][0]['message']} , Status Code: ${response.statusCode}'),
                    actions: [
                      TextButton(
                          child: Text('Oke'),
                          onPressed: () => Navigator.of(context).pop())
                    ]));
      }
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text(
                      'Terjadi error saat melakukan update stok ke api!, Status Code: ${response.statusCode}'),
                  actions: [
                    TextButton(
                        child: Text('Oke'),
                        onPressed: () => Navigator.of(context).pop())
                  ]));
    }
  }

  Future<void> tambahTransaksi() async {
    var base = await ApiConfig.instance.readBaseUrl();
    var url = '$base/set-data/transaksi_out';

    // Mengumpulkan data yang akan dikirim
    List<Map<String, dynamic>> tambahTransaksi = tableData.map((item) {
      return {
        'no_faktur': faktur,
        'kode': item['kode_brg'],
        'nama': item['nama_brg'],
        'qty': item['quantity'],
        'harga': item['jual'],
        'subtotal': item['jual'] * item['quantity'],
        'mark_up': item['mark_up'],
        'laba': item['laba'],
        'payment': 'tunai',
        'Tunai': totalbayar,
        'status': 'Lunas',
        'retur': 0,
      };
    }).toList();

    // Mengubah data ke JSON
    String jsonData = jsonEncode(tambahTransaksi);

    // Mengirim request PUT
    var response = await post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'api-key': 'Cokrok-kasir-apikey-098979'
        },
        body: jsonData);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['data'][0]['success'] == true) {
        print("Data berhasil di tambah");
        printReceipt();
        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => produkKeluarPage()),
        );
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text('Error'),
                    content: Text(
                        '${jsonResponse['data'][0]['message']} , Status Code: ${response.statusCode}'),
                    actions: [
                      TextButton(
                          child: Text('Oke'),
                          onPressed: () => Navigator.of(context).pop())
                    ]));
      }
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text('Error'),
                  content: Text(
                      'Terjadi error saat melakukan tambah transaksi ke api!,Status Code: ${response.statusCode}'),
                  actions: [
                    TextButton(
                        child: Text('Oke'),
                        onPressed: () => Navigator.of(context).pop())
                  ]));
    }
  }

  @override
  void initState() {
    super.initState();
    getFaktur();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                if (tableData.isNotEmpty) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Confirm"),
                            content: Text(
                                "Sudah ada data di tabel, yakin mau pindah?"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Tidak')),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const produkKeluarPage()),
                                    );
                                  },
                                  child: Text('Yakin')),
                            ],
                          ));
                } else {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const produkKeluarPage()),
                  );
                }
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
                if (tableData.isNotEmpty) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text("Confirm"),
                            content: Text(
                                "Sudah ada data di tabel, yakin mau pindah?"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Tidak')),
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                            secondaryAnimation) {
                                          return const Produk();
                                        },
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          var begin = const Offset(1.0, 0.0);
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
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                  },
                                  child: Text('Yakin')),
                            ],
                          ));
                } else {
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
                }
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
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Proses...')
                ],
              ),
            )
          : Center(
              child: Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        child: Row(
                          children: [
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                'No Faktur : $faktur',
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w800,
                                    fontSize: screenHeight * 0.020),
                              ),
                            )),
                            Expanded(flex: 4, child: Container()),
                            Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 30,
                                  width: screenWidth * 0.1,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 22, 219, 101),
                                        padding:
                                            const EdgeInsets.only(left: 3)),
                                    child: Text("Cetak",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenHeight * 0.018,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400)),
                                    onPressed: () {
                                      if (totalbayar == 0) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Notice'),
                                              content: Text(
                                                  'Anda belum menginputkan total bayar'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Okay'),
                                                  onPressed: () => {
                                                    Navigator.of(context).pop()
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else if (totalbayar < getTotalHarga()) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Notice'),
                                              content: Text(
                                                  'Total bayar tidak mencukupi'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Okay'),
                                                  onPressed: () => {
                                                    Navigator.of(context).pop()
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else if (tableData.isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Notice'),
                                              content: Text(
                                                  'Belum ada produk yang di pilih'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Okay'),
                                                  onPressed: () => {
                                                    Navigator.of(context).pop()
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Konfirmasi'),
                                              content: Text(
                                                  'Apakah Anda yakin ingin mencetak faktur ini?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text('Batal'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text('Cetak'),
                                                  onPressed: () {
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    Navigator.of(context).pop();
                                                    updateStok();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                  ),
                                )),
                          ],
                        ),
                      )),
                  Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Total Produk : ${rupiahFormat.format(getTotalProduk())}',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w800,
                                        fontSize: screenHeight * 0.020),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Total Harga : ${rupiahFormat.format(getTotalHarga())}',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w800,
                                        fontSize: screenHeight * 0.020),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Total Diskon : 0',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w800,
                                        fontSize: screenHeight * 0.020),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Total Bayar : ${rupiahFormat.format(totalbayar)}',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w800,
                                        fontSize: screenHeight * 0.020),
                                  )
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Kembalian : ${rupiahFormat.format(kembalian)}',
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w800,
                                        fontSize: screenHeight * 0.020),
                                  )
                                ],
                              )
                            ]),
                      )),
                  Expanded(
                      child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
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
                              style: TextStyle(
                                  fontSize: screenHeight * 0.019,
                                  fontFamily: 'Poppins'),
                              decoration: InputDecoration(
                                hintText: "Kode Barang...",
                                hintStyle: TextStyle(
                                    fontSize: screenHeight * 0.018,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30)),
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
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: screenHeight * 0.019,
                                      fontFamily: 'Poppins'),
                                  decoration: InputDecoration(
                                      hintText: "Bayar Rp.",
                                      hintStyle: TextStyle(
                                          fontSize: screenHeight * 0.018,
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
                          ],
                        )
                      ],
                    ),
                  )),
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: screenWidth * 0.08,
                        columns: [
                          DataColumn(
                              label: Text(
                            'Kode Barang',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: screenHeight * 0.017),
                          )),
                          DataColumn(
                              label: Text(
                            'Nama Barang',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: screenHeight * 0.017),
                          )),
                          DataColumn(
                              label: Text(
                            'Quantity',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: screenHeight * 0.017),
                          )),
                          DataColumn(
                              label: Text(
                            'Harga (pcs)',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: screenHeight * 0.017),
                          )),
                          DataColumn(
                              label: Text(
                            'Aksi',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: screenHeight * 0.017),
                          )),
                        ],
                        rows: tableData
                            .map((item) => DataRow(
                                  cells: [
                                    DataCell(Text(
                                      item['kode_brg'],
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: screenHeight * 0.017),
                                    )),
                                    DataCell(Text(
                                      item['nama_brg'],
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: screenHeight * 0.017),
                                    )),
                                    DataCell(
                                        Text(
                                          item['quantity'].toString(),
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w400,
                                              fontSize: screenHeight * 0.017),
                                        ),
                                        onTap: () => editQuantity(
                                            item)), // Menampilkan quantity
                                    DataCell(Text(
                                      item['jual'].toString(),
                                      style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400,
                                          fontSize: screenHeight * 0.017),
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
                                  return cariProdukPage(
                                      tambahKeTabel: tambahKeTabel);
                                },
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var begin = const Offset(
                                      0.0, 1.0); // Ubah dari bawah ke atas
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
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05),
                              backgroundColor:
                                  const Color.fromARGB(255, 22, 219, 101)),
                          child: Text(
                            'Cari Barang',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenHeight * 0.018,
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
