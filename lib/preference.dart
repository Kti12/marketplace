import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesPage extends StatefulWidget {
  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  TextEditingController addressController = TextEditingController();
  TextEditingController deliveryTimeController = TextEditingController();
  TextEditingController paymentMethodController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPreferences(); // Récupérer les préférences au démarrage de la page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Préférences de livraison'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse de livraison',
                ),
              ),
              TextFormField(
                controller: deliveryTimeController,
                decoration: InputDecoration(
                  labelText: 'Heure de livraison',
                ),
              ),
              TextFormField(
                controller: paymentMethodController,
                decoration: InputDecoration(
                  labelText: 'Mode de paiement',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  savePreferences(); // Enregistrer les préférences
                },
                child: Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      addressController.text = prefs.getString('address') ?? '';
      deliveryTimeController.text = prefs.getString('deliveryTime') ?? '';
      paymentMethodController.text = prefs.getString('paymentMethod') ?? '';
    });
  }

  Future<void> savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('address', addressController.text);
    await prefs.setString('deliveryTime', deliveryTimeController.text);
    await prefs.setString('paymentMethod', paymentMethodController.text);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Préférences enregistrées'),
          content: Text('Vos préférences de livraison ont été enregistrées.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
