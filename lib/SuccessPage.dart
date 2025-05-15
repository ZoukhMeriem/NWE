import 'package:flutter/material.dart';
import 'package:dztrainfay/SignInScreen.dart';

import 'HomePage.dart';

class SuccessPage extends StatelessWidget {
  final String username;

  SuccessPage({required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Color(0xFFCBD9E7), // Fond bleu clair 🎨
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              SizedBox(height: 20),
              Text(
                "Votre compte a été créé avec succès !",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage(username: username)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF87AFC7), // Bleu pastel ✨
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text("Se connecter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
