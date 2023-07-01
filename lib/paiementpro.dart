import 'package:http/http.dart' as http;
    import 'dart:convert';


    class PaiementPro {
     
      String merchantId = '';
      int amount = 0; /* Montant a payer */
      String description = ''; /* Description pour le paiement obligatoire */
      String channel = ''; /* Mode paiment consulter l'espace paiment pour les different provider */
      String countryCurrencyCode = '952'; /* Code de la devise: FCFA par default */
      String referenceNumber = ''; /* Reference de la transaction obligatoire et unique */
      String customerEmail = ''; /* Email de l'utilisateur obligatoire */
      String customerFirstName = ''; /* Nom de l'utilisateur obligatoire */
      String customerLastname = ''; /* Prénoms de l'utilisateur obligatoire */
      String customerPhoneNumber = ''; /* Contact de l'utilisateur obligatoire */
      String notificationURL = ''; /* URL de notication dans le cas ou vous enregistrer les donnée sur votre espace */
      String returnURL = ''; /* URL de retour après paiement: Il es conseiller d'utiliser le même que notificationURL  */
      String returnContext = ''; /* Donnée prensent dans returnURL Ex: {utilisateur_id:1,data:true}  */
      String url = ''; /* Message */
      String message = ''; /* Url de paiement */
      bool success = false; /* initialisation du paiement  */

      PaiementPro(this.merchantId);

      getUrlPayment() async {
       
        var url = Uri.https('paiementpro.net', 'webservice/onlinepayment/init/curl-init.php');
        var response = await http.post(url, body: jsonEncode({
          "merchantId":this.merchantId,
          "amount":this.amount,
          "description":this.description,
          "channel":this.channel,
          "countryCurrencyCode":this.countryCurrencyCode,
          "referenceNumber":this.referenceNumber,
          "customerEmail":this.customerEmail,
          "customerFirstName":this.customerFirstName,
          "customerLastname":this.customerLastname,
          "customerPhoneNumber":this.customerPhoneNumber,
          "notificationURL":this.notificationURL,
          "returnURL":this.returnURL,
          "returnContext":this.returnContext,
        }));
       
        var data = jsonDecode(response.body);
       
        if(data['url']!= null){
          this.url = data['url'];
          this.success = data['success'];
        }else{
          this.message = data['message'];
          this.success = data['success'];
        }
         
      }

    }