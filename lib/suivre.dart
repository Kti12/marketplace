import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class FollowPage extends StatefulWidget {
  @override
  _FollowPageState createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  bool _isLoading = true;
  String _deliveryPersonName = '';
  String _deliveryPersonPhotoUrl = '';
  String _deliveryPersonNumber = '';
  int _arrivalTime = 20; // Temps d'arrivée du livreur en minutes
  Timer? _timer;
  bool _isDeliveryPersonArrived = false;

  @override
  void initState() {
    super.initState();
    // Simulate a loading delay
    Future.delayed(Duration(seconds: 2), () {
      _fetchDeliveryPersonData(); // Récupérer les informations du livreur depuis la base de données
      _startTimer(); // Lancer le compte à rebours
    });
  }

  void _startTimer() {
    const oneMinute = Duration(minutes: 1);
    _timer = Timer.periodic(oneMinute, (timer) {
      if (_arrivalTime > 0) {
        setState(() {
          _arrivalTime--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isDeliveryPersonArrived = true;
        });
      }
    });
  }

  Future<void> _fetchDeliveryPersonData() async {
    // Simuler une requête à la base de données
    await Future.delayed(Duration(seconds: 1));

    // Récupérer les informations du livreur (remplacez cette logique par votre propre code de requête)
    String deliveryPersonName = 'John Doe';
    String deliveryPersonPhotoUrl = 'https://example.com/delivery_person.jpg';
    String deliveryPersonNumber = '123456789';

    setState(() {
      _isLoading = false;
      _deliveryPersonName = deliveryPersonName;
      _deliveryPersonPhotoUrl = deliveryPersonPhotoUrl;
      _deliveryPersonNumber = deliveryPersonNumber;
    });
  }

  void _callDeliveryPerson() async {
    String url = 'tel:$_deliveryPersonNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Impossible de passer un appel.'),
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

  @override
  void dispose() {
    _timer?.cancel(); // Annuler le compte à rebours lorsque la page est supprimée
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivre le livreur'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: LatLng(0, 0), // Remplacez les coordonnées par celles du livreur
              zoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _isLoading ? 0 : 120.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                  ),
                ],
              ),
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10.0),
                        Text(
                          '$_deliveryPersonName',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10.0),
                        CircleAvatar(
                          radius: 30.0,
                          backgroundImage: NetworkImage(_deliveryPersonPhotoUrl),
                        ),
                        SizedBox(height: 10.0),
                        Text(
                          'Numéro du livreur: $_deliveryPersonNumber',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        SizedBox(height: 10.0),
                        if (!_isDeliveryPersonArrived)
                          Text(
                            'Livreur en route... Temps d\'arrivée estimé: $_arrivalTime minutes',
                            style: TextStyle(fontSize: 14.0),
                          ),
                        if (_isDeliveryPersonArrived)
                          Text(
                            'Le livreur est arrivé!',
                            style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                          ),
                        SizedBox(height: 10.0),
                        ElevatedButton(
                          onPressed: _callDeliveryPerson,
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(20.0),
                            primary: Colors.blue,
                          ),
                          child: Icon(
                            Icons.phone,
                            size: 30.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}


class ReviewDialog extends StatefulWidget {
  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  double _rating = 0;
  TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Noter le livreur'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Note'),
          SizedBox(height: 10.0),
          RatingBar(
            initialRating: _rating,
            onRatingChanged: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
          SizedBox(height: 10.0),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Laisser un commentaire (facultatif)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Fermer la boîte de dialogue
          },
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            // Enregistrer la note et le commentaire dans la base de données
            double rating = _rating;
            String comment = _commentController.text;
            // Ajoutez ici votre code pour enregistrer les données dans la base de données

            Navigator.pop(context); // Fermer la boîte de dialogue
          },
          child: Text('Envoyer'),
        ),
      ],
    );
  }
}

class RatingBar extends StatefulWidget {
  final double initialRating;
  final void Function(double rating) onRatingChanged;

  RatingBar({required this.initialRating, required this.onRatingChanged});

  @override
  _RatingBarState createState() => _RatingBarState();
}

class _RatingBarState extends State<RatingBar> {
  double _rating = 0;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  Widget _buildStarIcon(int index) {
    IconData iconData;
    if (_rating >= index + 1) {
      iconData = Icons.star;
    } else if (_rating > index) {
      iconData = Icons.star_half;
    } else {
      iconData = Icons.star_border;
    }
    return Icon(iconData);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
            widget.onRatingChanged(_rating);
          },
          child: _buildStarIcon(index),
        );
      }),
    );
  }
}

