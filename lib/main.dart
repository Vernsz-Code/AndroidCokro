import "package:flutter/material.dart";

main() => runApp(MainPage());

class MainPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title:  Text ("Home Page")),
        body: TextField(
          maxLength: 20,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(color: Colors.red)
            ),
            labelText: "Username",
            filled: true,
            fillColor: Colors.white,
            hintText: "Masukan Username",
            helperText: "Batas Karakter 20 Huruf",
            prefixIcon: Icon(Icons.supervisor_account_outlined)
          ),
        ),
      ),
    );
  }
}