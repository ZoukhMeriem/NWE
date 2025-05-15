import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'PasswordChangedScreen.dart';

class CreatePasswordScreen extends StatefulWidget {
  final String email;

  CreatePasswordScreen({required this.email});

  @override
  _CreatePasswordScreenState createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  final ButtonStyle myButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.indigo.shade700;
        }
        return Colors.indigo;
      },
    ),
    overlayColor: MaterialStateProperty.all(
      Colors.indigoAccent.withOpacity(0.2),
    ),
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
  );

  Future<void> updatePassword() async {
    setState(() {
      isLoading = true;
    });

    try {
      String nouveauMotDePasse = passwordController.text.trim();
      String email = widget.email.trim().toLowerCase();

      if (nouveauMotDePasse.isEmpty || nouveauMotDePasse.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez entrer un mot de passe valide (au moins 6 caractères).')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.set({
          'password': nouveauMotDePasse,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Mot de passe changé avec succès !')),
        );

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFe0eafc), // 🔵 Dégradé bleu clair
              Color(0xFFcfdef3), // 🔵 Bas bleu-gris très clair
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text(
                'Créer un nouveau mot de passe',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9), // 🔥 Champ avec fond léger blanc
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: updatePassword,
                style: myButtonStyle,
                child: Text(
                  'Changer le mot de passe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
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
