// ignore_for_file: depend_on_referenced_packages, prefer_const_constructors
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:market/paiementpro.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:market/settings.dart';
import 'package:market/suivre.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class Product {
  final int id;
  final String image;
  final String name;
  final String description;
  final int price;

  Product({
    required this.id,
    required this.image,
    required this.name,
    required this.description,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      image: json['imageProduit'],
      name: json['nomProduit'],
      description: json['descriptionProduit'],
      price: json['prixProduit'],
    );
  }
}

class Cart {
  List<Product> products = [];

  void addToCart(Product product) {
    products.add(product);
  }

  void removeFromCart(Product product) {
    products.remove(product);
  }

  int get cartItemCount => products.length;

  double getTotalPrice() {
    double totalPrice = 0.0;
    for (var product in products) {
      totalPrice += product.price;
    }
    return totalPrice;
  }
}

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String address = "Votre adresse";
  String deliveryTime = "17 : 00";
  String contactNumber = "0102030405";
  String defaultPaymentOption = "en espèce";
  List<Product> products = [];
  Cart cart = Cart();
  int cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  static const String baseUrl = 'http://192.168.10.25:8000/api/produits';

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        products = data.map((json) {
          // Récupérer le nom de l'image du produit
          String imageName = json['imageProduit'];

          // Construire l'URL complète de l'image
          String imageUrl = '$imageName';

          // Créer une instance de Product avec tous les attributs
          return Product(
            id: json['id'],
            image: imageUrl,
            name: json['nomProduit'],
            description: json['descriptionProduit'],
            price: json['prixProduit'],
          );
        }).toList();
        print('products');
        fetchClient();
      });
    } else {
      throw Exception('Echec de chargement des produits');
    }
  }

  static const String baseUrl2 = 'http://192.168.10.25:8000/api/clients/1';

  Future<void> fetchClient() async {
    final response = await http.get(Uri.parse('$baseUrl2'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        address = data['AdresseClient'];
        contactNumber = data['NuméroClient'];
        defaultPaymentOption = 'En espèce';
      });
    } else {
      throw Exception('Echec de chargement des produits');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketplace'),
        backgroundColor: Color(0xFF1C9521),
        leading: const Padding(
          padding: EdgeInsets.all(5),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: AssetImage("assets/images/logo_aisa.png"),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.add_shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(
                        cart: cart,
                        address: address,
                        deliveryTime: deliveryTime,
                        contactNumber: contactNumber,
                        defaultPaymentOption: defaultPaymentOption,
                      ),
                    ),
                  );
                },
              ),
              cartItemCount > 0
                  ? Positioned(
                      top: 4.0,
                      right: 4.0,
                      child: Container(
                        padding: EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: Color(0xFF1C9521),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          cartItemCount.toString(),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, id) {
          final product = products[id];

          return Column(
            children: [
              SizedBox(height: 15),
              ListTile(
                leading: Image.network(
                  'http://192.168.10.25:8000/' + product.image,
                  width: 80.0,
                  height: 80.0,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.description),
                    Text(
                      '\fcfa${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF1C9521)),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () {
                    cart.addToCart(product);
                    setState(() {
                      cartItemCount = cart.cartItemCount;
                    });
                  },
                  child: Text('Acheter'),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.person),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page d'accueil
                },
              ),
              IconButton(
                icon: Icon(Icons.search),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page du panier
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page du profil
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Setting()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApiService {
  Future<void> addToCart(Product product) async {
    final url = Uri.parse('http://192.168.10.25:8000/api/cart/add');
    final body = jsonEncode({
      'productId': product.id,
      'productName': product.name,
      // Ajoutez d'autres champs nécessaires à votre endpoint
    });

    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        // Gérez la réponse réussie
      } else {
        // Gérez les erreurs de la requête
      }
    } catch (e) {
      // Gérez les erreurs de connexion ou autres erreurs
    }
  }

  Future<void> removeFromCart(Product product) async {
    final url = Uri.parse('http://192.168.10.25:8000/api/cart/remove');
    final body = jsonEncode({
      'productId': product.id,
      // Ajoutez d'autres champs nécessaires à votre endpoint
    });

    try {
      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        // Gérez la réponse réussie
      } else {
        // Gérez les erreurs de la requête
      }
    } catch (e) {
      // Gérez les erreurs de connexion ou autres erreurs
    }
  }
}

class CartPage extends StatefulWidget {
  final Cart cart;
  final String address;
  final String deliveryTime;
  final String contactNumber;
  final String defaultPaymentOption;

  CartPage(
      {required this.cart,
      required this.address,
      required this.deliveryTime,
      required this.contactNumber,
      required this.defaultPaymentOption});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int cartItemCount = 0;
  List<Product> products = [];
  double totalPrice = 0.0;
  List<Product> remainingProducts = [];

  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    cartItemCount = widget.cart.cartItemCount;
    calculateTotalPrice();
    fetchRemainingProducts();
  }

  void updateCartItemCount(Product product) {
    setState(() {
      widget.cart.removeFromCart(product);
      cartItemCount = widget.cart.cartItemCount;
      calculateTotalPrice();
    });
  }

  void fetchRemainingProducts() {
    remainingProducts = products
        .where((product) => !widget.cart.products.contains(product))
        .toList();
  }

  void calculateTotalPrice() {
    double total = 0.0;
    for (Product product in widget.cart.products) {
      total += product.price;
    }
    totalPrice = total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
        backgroundColor: Color(0xFF1C9521),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Produits ajoutés au panier:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cart.products.length,
                itemBuilder: (context, index) {
                  final product = widget.cart.products[index];
                  return ListTile(
                    leading: Image.network(
                      'http://192.168.10.25:8000/' + product.image,
                      width: 80.0,
                      height: 80.0,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.description),
                        Text('\fcfa${product.price.toStringAsFixed(2)}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_shopping_cart),
                      color: const Color(0xFF1C9521),
                      onPressed: () {
                        apiService.removeFromCart(product);
                        updateCartItemCount(product);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeliveryInfoPage(
                        cart: widget.cart,
                        address: widget.address,
                        deliveryTime: widget.deliveryTime,
                        contactNumber: widget.contactNumber,
                        defaultPaymentOption: widget.defaultPaymentOption),
                  ),
                );
              },
              child: Text('Commander (${totalPrice.toStringAsFixed(2)})'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF1C9521),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Autres produits:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: remainingProducts.length,
                itemBuilder: (context, index) {
                  final product = remainingProducts[index];
                  if (!widget.cart.products.contains(product)) {
                    return ListTile(
                      leading: Image.network(
                        'http://192.168.10.25:8000/' + product.image,
                        width: 80.0,
                        height: 80.0,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.description),
                          Text('\fcfa${product.price.toStringAsFixed(2)}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          apiService.addToCart(product);
                          updateCartItemCount(product);
                        },
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.person),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page de recherche
                },
              ),
              IconButton(
                icon: Icon(Icons.search),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page des paramètres
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page du profil
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Setting()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeliveryInfoPage extends StatefulWidget {
  final Cart cart;

  DeliveryInfoPage(
      {required this.cart,
      required this.address,
      required this.deliveryTime,
      required this.contactNumber,
      required this.defaultPaymentOption});

  final String address;
  final String deliveryTime;
  final String contactNumber;
  final String defaultPaymentOption;

  @override
  _DeliveryInfoPageState createState() => _DeliveryInfoPageState();
}

class _DeliveryInfoPageState extends State<DeliveryInfoPage> {
  TextEditingController addressController = TextEditingController();
  TextEditingController hourController = TextEditingController();
  String currentPosition = 'Partager ma position';

  @override
  void initState() {
    super.initState();
    fetchClient();
  }

  static const String baseUrl = 'http://192.168.10.25:8000/api/clients/1';
  var client;
  var paymentOption = '';

  Future<void> fetchClient() async {
    final response = await http.get(Uri.parse('$baseUrl'));
    if (response.statusCode == 200) {
      client = jsonDecode(response.body);
      setState(() {
        print(client);
        addressController.text = client['AdresseClient'];
        paymentOption = client['ModePaiementClient'] == 'En ligne'
            ? 'en_ligne'
            : 'en_especes';
      });
    } else {
      throw Exception('Echec de chargement des produits');
    }
  }

  @override
  /* void initState() {
    super.initState();
    getAddressAndHourFromPreferences(); // Récupérer l'adresse et l'heure par défaut au démarrage de la page
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informations de livraison'),
        backgroundColor: Color(0xFF1C9521),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Text(
                'Les frais de livraison sont fixé à 1200 cfa',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15.0),
              ),
              SizedBox(
                height: 10,
              ),
              Text('Pour poursuivre, remplissez les champs suivants',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 18.0)),
              SizedBox(
                height: 10,
              ),
              Text(
                'Adresse de livraison:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  hintText: 'Entrez votre adresse',
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Heure de livraison:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                readOnly: true,
                controller: hourController,
                decoration: InputDecoration(
                  hintText: 'Entrez l\'heure de livraison',
                ),
                onTap: () async {
                  var pickedTime = await showTimePicker(
                    initialTime: TimeOfDay.now(),
                    context: context,
                  );

                  setState(() {
                    if (pickedTime != null) {
                      var houre = pickedTime.toString().replaceAll("(", "");
                      houre = houre.toString().replaceAll(")", "");
                      houre = houre.toString().replaceAll("TimeOfDay", "");
                      hourController.text = houre;
                    }
                  });
                },
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 30,
              ),
              Column(
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          _getCurrentLocation();
                        },
                        icon: Icon(Icons.location_on),
                        iconSize: 50.0,
                        color: Color(0xFF1C9521),
                      ),
                      Text(
                        currentPosition,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Choisissez une option de paiement:',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15.0),
                  ListTile(
                    title: Text('Payer en ligne'),
                    leading: Radio(
                      value: 'en_ligne',
                      groupValue: paymentOption,
                      onChanged: (value) {
                        setState(() {
                          paymentOption = value.toString();
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Payer en espèces'),
                    leading: Radio(
                      value: 'en_especes',
                      groupValue: paymentOption,
                      onChanged: (value) {
                        setState(() {
                          paymentOption = value.toString();
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 50.0),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Color(0xFF1C9521)),
                    ),
                    onPressed: () {
                      // if (paymentOption == 'en_ligne') {
                      //   // Rediriger vers le formulaire Mobile Money
                      //   Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //       builder: (context) => OrderSummaryPage(
                      //         cart: widget.cart,
                      //         address: widget.address,
                      //         deliveryTime: hourController.text,
                      //         contactNumber: widget.contactNumber,
                      //         paymentOption: 'none',
                      //       ),
                      //     ),
                      //   );
                      // } else if (paymentOption == 'en_especes') {
                      //   // Afficher la page de récapitulatif de commande pour paiement en espèces

                      // }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderSummaryPage(
                            cart: widget.cart,
                            address: widget.address,
                            deliveryTime: hourController.text,
                            paymentOption: paymentOption,
                            contactNumber: widget.contactNumber,
                          ),
                        ),
                      );
                    },
                    child: Text('Envoyer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.person),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page de recherche
                },
              ),
              IconButton(
                icon: Icon(Icons.search),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page des paramètres
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page du profil
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Setting()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    var baseUrl = 'http://192.168.10.25:8000/api/set-postion';
    var response = await http.post(
      Uri.parse(baseUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'client_id': 1
      }),
    );
    // print(response.body);
    var data = jsonDecode(response.body);
    Fluttertoast.showToast(
      msg: data['message'],
      toastLength: Toast
          .LENGTH_SHORT, // Duration for which the toast should be displayed
      gravity:
          ToastGravity.BOTTOM, // Position of the toast message on the screen
      timeInSecForIosWeb:
          1, // Specific to iOS/Web, the time for which the toast should be displayed
      backgroundColor: Colors.black54, // Background color of the toast
      textColor: Colors.white, // Text color of the toast
      fontSize: 16.0, // Font size of the toast message
    );
    setState(() {
      currentPosition = 'Votre position été partager avec succès';
      // print(currentPosition);
    });
  }
}

class MobileMoneyFormPage extends StatefulWidget {
  final Cart cart;
  final String address;
  final String deliveryTime;
  final String contactNumber;

  MobileMoneyFormPage(
      {required this.cart,
      required this.address,
      required this.deliveryTime,
      required this.contactNumber});

  @override
  _MobileMoneyFormPageState createState() => _MobileMoneyFormPageState();
}

class _MobileMoneyFormPageState extends State<MobileMoneyFormPage> {
  final _formKey = GlobalKey<FormState>();

  String mobileMoneyInfo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile Money'),
        backgroundColor: Color(0xFF1C9521),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Text(
                'Prix total de la commande: \fcfa${(widget.cart.getTotalPrice() + 1200).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Informations Mobile Money'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir les informations Mobile Money';
                  }
                  return null;
                },
                onSaved: (value) {
                  mobileMoneyInfo = value!;
                },
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Color(0xFF1C9521)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderSummaryPage(
                            cart: widget.cart,
                            address: widget.address,
                            deliveryTime: widget.deliveryTime,
                            contactNumber: widget.contactNumber,
                            paymentOption: '',
                            mobileMoneyInfo: mobileMoneyInfo),
                      ),
                    );
                  }
                },
                child: Text('Envoyer'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.person),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page de recherche
                },
              ),
              IconButton(
                icon: Icon(Icons.search),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page des paramètres
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                color: Color(0xFF1C9521),
                onPressed: () {
                  // Naviguer vers la page du profil
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Setting()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderSummaryPage extends StatelessWidget {
  final Cart cart;
  final String address;
  final String deliveryTime;
  final String contactNumber;
  final String? mobileMoneyInfo;
  final String? paymentOption;

  OrderSummaryPage(
      {required this.cart,
      required this.address,
      required this.deliveryTime,
      required this.contactNumber,
      required this.paymentOption,
      this.mobileMoneyInfo});

  var produits = [];
  var reference =
      'REF-' + (new DateTime.now().microsecondsSinceEpoch).toString();

  function_paiement() async {
    PaiementPro paiment_pro = new PaiementPro('PP-F324');

    paiment_pro.amount = cart.getTotalPrice().toInt() + 1200;
    paiment_pro.channel = 'MOMOCI';
    paiment_pro.referenceNumber = reference;
    reference = paiment_pro.referenceNumber;
    paiment_pro.customerEmail = 'marketplace@gmail.com';
    paiment_pro.customerFirstName = 'Market';
    paiment_pro.customerLastname = 'Place';
    paiment_pro.customerPhoneNumber = this.contactNumber;
    paiment_pro.description = this.address;
    paiment_pro.notificationURL =
        'http://192.168.10.25:8000/api/return-paiementpro';
    paiment_pro.returnURL = 'http://192.168.10.25:8000/api/return-paiementpro';

    await paiment_pro.getUrlPayment();

    if (paiment_pro.success) {
      print(paiment_pro.url);

      final Uri _url = Uri.parse(paiment_pro.url);

      Future<void> _launchUrl() async {
        if (!await launchUrl(_url)) {
          throw 'Could not launch $_url';
        }
      }

      // success open in browser
      _launchUrl();
    } else {
      // error init
      print(paiment_pro.message);
    }
  }

  Future<void> fetchCommande() async {
    var baseUrl2 = 'http://192.168.10.25:8000/api/commandes';

    final response = await http.post(Uri.parse(baseUrl2),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'client_id': 1,
          'produits': produits,
          'AdresseClient': address,
          'HeureLivraison': deliveryTime,
          'ModePaiement': paymentOption,
          'reference': reference
        }));

    // print(response.body);

    print(paymentOption);

    if (paymentOption == 'en_ligne') {
      function_paiement();
    } else {
      Fluttertoast.showToast(
        msg:
            'Votre commande a été enregistré avec succès merci pour votre confiance.                                ',
        toastLength: Toast
            .LENGTH_SHORT, // Duration for which the toast should be displayed
        gravity:
            ToastGravity.BOTTOM, // Position of the toast message on the screen
        timeInSecForIosWeb:
            1, // Specific to iOS/Web, the time for which the toast should be displayed
        backgroundColor: Colors.black54, // Background color of the toast
        textColor: Colors.white, // Text color of the toast
        fontSize: 16.0, // Font size of the toast message
      );
    }

    // if (response.statusCode == 200) {
    //   // var data = jsonDecode(response.body);
    // } else {
    //   throw Exception('Echec de chargement des produits');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Récapitulatif de la commande'),
        backgroundColor: Color(0xFF1C9521),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Détails de la commande:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Mode de paiement: ' +
                  paymentOption.toString().replaceAll("_", " "),
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Adresse de livraison: $address',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 14.0),
            Text(
              'Heure de livraison: $deliveryTime',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 14.0),
            Text(
              'Numéro de contact: $contactNumber',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Produits commandés:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cart.products.length,
                itemBuilder: (context, index) {
                  final product = cart.products[index];
                  produits.add(product.id);
                  return ListTile(
                    leading: Image.network(
                      'http://192.168.10.25:8000/' + product.image,
                      width: 80.0,
                      height: 80.0,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.description),
                        Text('\fcfa${product.price.toStringAsFixed(2)}'),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Frais de la livraison: 1200 fcfa',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Prix total de la commande: \fcfa${(cart.getTotalPrice() + 1200).toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            if (mobileMoneyInfo != null)
              Text(
                'Informations Mobile Money: $mobileMoneyInfo',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xFF1C9521)),
              ),
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => FollowPage()),
                // );
                fetchCommande();
              },
              child: Text('Valider'),
            ),
          ],
        ),
      ),
    );
  }
}
