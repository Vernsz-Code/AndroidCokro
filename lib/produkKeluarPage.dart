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
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container()
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 30,
                        width: 10,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 22, 219, 101),
                            padding: EdgeInsets.only(left: 3)
                          ),
                          child: Text("Cetak",
                          textAlign: TextAlign.right, style: TextStyle(
                            color: Colors.white
                          ),),
                          onPressed: () => {},
                        ),
                      )
                    ),
                  ],
                ),
              )
            ),
            Expanded(
              flex: 6,
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Table(
                  border: TableBorder.all(color: Colors.black, width: 1),
                  children: const [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 22, 219, 101),
                      ),
                      children:[ 
                        TableCell(
                          
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: Text("Text 1", style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: Text("Text 2", style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: Text("Text 3", style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        
                      ]
                    ),
                  ],
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}
