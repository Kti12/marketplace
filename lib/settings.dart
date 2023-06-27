// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:market/settings.dart';
import 'package:market/produit.dart';

import 'body.dart';


class Setting extends StatelessWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réglages'),
        backgroundColor: const Color(0xFF1C9521),
        leading: IconButton(
          icon: Image.asset(
            'assets/images/back.png',
            width: 20,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  ProductsPage()),
            );
          },
          color: Colors.white,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(5),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: AssetImage("assets/images/logo_aisa.png"),
            ),
          ),
        ],
      ),
      body: const Body(),
    );
  }
}
