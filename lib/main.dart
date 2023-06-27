import 'package:flutter/material.dart';
import 'package:market/produit.dart';
import 'package:market/settings.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF1C9521), // Couleur principale #1C9521
      ),
      home:  ProductsPage(),
      routes: {
        '/produit.dart':(context) => ProductsPage(),
        '/settings.dart':(context) => const Setting(),
      },
    );
  }
}
