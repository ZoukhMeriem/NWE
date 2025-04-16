import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dztrainfay/HomePage.dart';
import 'package:dztrainfay/SignUpScreen.dart';
import 'package:dztrainfay/ForgotPasswordScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'AdminHomePage.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void handleGoogleSignIn() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userName = user.displayName ?? 'Utilisateur';
        final userEmail = user.email;

        // Appel de la fonction EmailJS
        await sendWelcomeEmail(userName, userEmail);
      }
    } catch (error) {
      print('Erreur de connexion Google : $error');
    }
  }

  Future<void> sendWelcomeEmail(String userName, String userEmail) async {
    const serviceId = 'service_u2yoj5q';
    const templateId = 'template_xzkkyh6';
    const userId = 'oqcAyNlyd8meS-bZo3'; // EmailJS user ID (public key)

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'user_name': userName,
          'user_email': userEmail,
        },
      }),
    );

    if (response.statusCode == 200) {
      print('E-mail envoyé avec succès');
    } else {
      print('Erreur lors de l’envoi de l’e-mail : ${response.body}');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFCBD9E7),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image en haut qui couvre toute la largeur
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.23,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/signIn.jpg'),
                  fit: BoxFit.cover, // Assure que l'image couvre sans être déformée
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  _buildTextField(usernameController, "Nom d'utilisateur", Icons.person),
                  SizedBox(height: 16.0),
                  _buildTextField(passwordController, "Mot de passe", Icons.lock, isPassword: true),
                  SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                        );
                      },
                      child: Text(
                        'Mot de passe oublié ?',
                        style: TextStyle(color: Colors.indigo),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () async {
                      final username = usernameController.text.trim();
                      final password = passwordController.text.trim();

                      try {
                        // 🔹 Vérifier si l'utilisateur est un admin
                        QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
                            .collection('Admin')
                            .where('Username', isEqualTo: username)
                            .where('Password', isEqualTo: password)
                            .get();

                        if (adminSnapshot.docs.isNotEmpty) {
                          // ✅ Connexion admin réussie
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => AdminHomePage(adminUsername: username)),
                          );
                          return; // on quitte ici si c'est un admin
                        }

                        // 🔹 Sinon, on vérifie dans la collection des utilisateurs normaux
                        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
                            .collection('User')
                            .where('username', isEqualTo: username)
                            .where('password', isEqualTo: password)
                            .get();

                        if (userSnapshot.docs.isNotEmpty) {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('isLoggedIn', true);
                          await prefs.setString('username', username);

                          final sharedPrefs = await SharedPreferences.getInstance();
                          await sharedPrefs.setBool('isLoggedIn', true);
                          await sharedPrefs.setString('username', username);


                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage(username: username)),
                          );
                        }
                        else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Nom d'utilisateur ou mot de passe incorrect")),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur lors de la connexion: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(horizontal: 110.0, vertical: 12.0),
                    ),
                    child: Text(
                      'Se connecter',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),

                  SizedBox(height: 10.0),



                  // 🔹 Bouton Google en rectangle avec le même style que "Se connecter"
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Center(child: CircularProgressIndicator()),
                        );

                        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

                        if (googleUser == null) {
                          Navigator.of(context).pop(); // Ferme le dialog si annulation
                          return;
                        }

                        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

                        final credential = GoogleAuthProvider.credential(
                          accessToken: googleAuth.accessToken,
                          idToken: googleAuth.idToken,
                        );

                        await FirebaseAuth.instance.signInWithCredential(credential);
                        final user = await FirebaseAuth.instance.authStateChanges().first;

                        final username = user?.displayName ?? "Utilisateur";
                        final email = user?.email ?? "";

                        await sendWelcomeEmail(username, email);

                        Navigator.of(context).pop(); // Ferme le dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage(username: username)),
                        );
                      } catch (e) {
                        Navigator.of(context).pop(); // Ferme le dialog en cas d'erreur
                        print("Erreur de connexion Google : $e");
                      }
                    },


                    icon: FaIcon(FontAwesomeIcons.google, color: Colors.white),
                    label: Text(
                      "Se connecter avec Google",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 12.0),
                    ),
                  ),





                  SizedBox(height: 30.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    child: Text(
                      "Vous n'avez pas de compte ? Inscrivez-vous",
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          prefixIcon: Icon(icon, color: Colors.indigo),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.indigo,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
        ),
      ),
    );
  }
}