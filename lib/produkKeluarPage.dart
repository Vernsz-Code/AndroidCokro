import 'package:flutter/material.dart';

class produkKeluarPage extends StatelessWidget {
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          height: 70,
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
                onPressed: () => {
                  Scaffold.of(context).openDrawer()
                },
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
        child: ListView(

        ),
      ),
    );
  }
}
