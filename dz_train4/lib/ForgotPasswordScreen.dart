import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';

import 'VerifyEmailScreen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  String generateResetCode() {
    Random random = Random();
    int code = 100000 + random.nextInt(900000);
    return code.toString();
  }

  Future<void> sendResetCodeByEmail(String email, String code) async {
    const String sendGridApiKey = 'SG.RDhm4ry3R5KyvqHlrvUGUg.hvCSfxTwhhbHmOcUun5kwo3pHAsTbfu4hHwwSRVhUSY';
    const String senderEmail = 'dztrains@gmail.com';

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

      await FirebaseFirestore.instance.collection('PasswordResetCodes').doc(email).set({
        'code': code,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await sendResetCodeByEmail(email, code);

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
      appBar: AppBar(
        title: const Text("Mot de passe oublié",
        style: TextStyle(
          fontSize: 24,
          color: Colors.black87,
        ),
      ),
        backgroundColor: Color(0x998BB1FF),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x998BB1FF),// vert doux
              Color(0xFFF4D9DE),   // rose clair
              Color(0xFFDDD7E8),   // lavande
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Icon(Icons.lock_reset_rounded, size: 80, color: Colors.black87),
              const SizedBox(height: 20),
              const Text(
                'Réinitialisation du mot de passe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Veuillez entrer votre adresse e-mail pour recevoir un code de réinitialisation.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Adresse e-mail',
                  labelStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.email, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color:Color(0x998BB1FF)),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.95),
                ),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: sendResetCode,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text(
                  'Envoyer le code',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0x998BB1FF),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
