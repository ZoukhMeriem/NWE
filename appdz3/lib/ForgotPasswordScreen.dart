import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';

import 'VerifyEmailScreen.dart'; // Assure-toi que ce fichier existe et est bien importé

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  // 🔥 Fonction pour générer un code aléatoire 6 chiffres
  String generateResetCode() {
    Random random = Random();
    int code = 100000 + random.nextInt(900000); // Entre 100000 et 999999
    return code.toString();
  }

  // 🔥 Fonction pour envoyer un e-mail via SendGrid
  Future<void> sendResetCodeByEmail(String email, String code) async {
    const String sendGridApiKey = 'SG.RDhm4ry3R5KyvqHlrvUGUg.hvCSfxTwhhbHmOcUun5kwo3pHAsTbfu4hHwwSRVhUSY'; // 🔥 remplace ici
    const String senderEmail = 'dztrains@gmail.com'; // 🔥 ton adresse d'expéditeur validée dans SendGrid

    final url = Uri.parse('https://api.sendgrid.com/v3/mail/send');

    final emailContent = {
      "personalizations": [
        {
          "to": [
            {"email": email}
          ],
          "subject": "Votre code de réinitialisation DzTrain"
        }
      ],
      "from": {
        "email": senderEmail
      },
      "content": [
        {
          "type": "text/plain",
          "value": "Bonjour,\n\nVoici votre code de réinitialisation : $code\n\nMerci d'utiliser DzTrain."
        }
      ]
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $sendGridApiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode(emailContent),
    );

    if (response.statusCode == 202) {
      print('✅ Email envoyé avec succès à $email');
    } else {
      print('❌ Erreur lors de l\'envoi: ${response.statusCode} ${response.body}');
    }
  }

  // 🔥 Fonction principale pour envoyer le code
  Future<void> sendResetCode() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer une adresse e-mail valide.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String code = generateResetCode();

      // 1️⃣ Stocker le code dans Firestore
      await FirebaseFirestore.instance.collection('PasswordResetCodes').doc(email).set({
        'code': code,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2️⃣ Envoyer l'email avec le code
      await sendResetCodeByEmail(email, code);

      // 3️⃣ Naviguer vers la page de saisie du code
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyEmailScreen(
            verificationCode: code,
            email: email,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mot de passe oublié')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFe0eafc), // 🔵 Bleu très clair en haut
              Color(0xFFcfdef3), // 🔵 Bleu-gris clair en bas
            ],
          ),
        ),
        child: SingleChildScrollView( // 🔥 Ajoute pour éviter l'overflow clavier
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Veuillez entrer votre adresse e-mail pour recevoir un code de réinitialisation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // 🔥 Texte plus élégant
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Adresse e-mail',
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10), // 🔥 Bords arrondis élégants
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9), // 🔥 Fond léger sur TextField
                ),
              ),
              SizedBox(height: 30),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: sendResetCode,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.indigo.shade700;
                      }
                      return Colors.indigo;
                    },
                  ),
                  overlayColor: MaterialStateProperty.all(
                      Colors.indigoAccent.withOpacity(0.2)),
                  padding: MaterialStateProperty.resolveWith<EdgeInsets>(
                        (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return EdgeInsets.symmetric(horizontal: 45, vertical: 10);
                      }
                      return EdgeInsets.symmetric(horizontal: 50, vertical: 12);
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                child: Text(
                  'Envoyer le code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
