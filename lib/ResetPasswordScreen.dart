import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'PasswordChangedScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔥 N'oublie cet import en haut

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  ResetPasswordScreen({required this.email});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;


  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
    });

    try {
      String nouveauMotDePasse = passwordController.text.trim();

      if (nouveauMotDePasse.isEmpty || nouveauMotDePasse.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez entrer un mot de passe valide (minimum 6 caractères).')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // 🔥 Chercher l'utilisateur dans Firestore grâce à son email
      final snapshot = await FirebaseFirestore.instance
          .collection('User') // ⚡ bien sûr, c'est la collection User
          .where('email', isEqualTo: widget.email) // 🔥 Trouver par email
          .get();

      if (snapshot.docs.isNotEmpty) {
        // 🔥 Mettre à jour le champ 'password'
        await snapshot.docs.first.reference.update({
          'password': nouveauMotDePasse,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Mot de passe changé avec succès !')),
        );

        // 🔥 Rediriger vers l'écran de confirmation
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PasswordChangedScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Utilisateur non trouvé avec cet email.')),
        );
      }
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
      appBar: AppBar(title: Text('Créer un nouveau mot de passe')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              child: Text('Changer mot de passe'),
            ),
          ],
        ),
      ),
    );
  }
}
