import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dztrainfay/SuccessPage.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController autreEmploiController = TextEditingController();

  String selectedEmploi = "Étudiant";
  String selectedSexe = "Homme";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Créer un compte")),
      backgroundColor: Color(0xFFCBD9E7),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "Bienvenue ! Remplissez vos informations.",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildLineTextField(prenomController, "Prénom")),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLineTextField(nomController, "Nom")),
                  ],
                ),
                _buildLineTextField(emailController, "Adresse e-mail", isEmail: true),
                DropdownButtonFormField<String>(
                  value: selectedSexe,
                  items: ["Homme", "Femme"].map((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(color: Colors.black), // 👈 Texte des options
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedSexe = newValue!;
                    });
                  },
                  style: TextStyle(color: Colors.black), // 👈 Texte sélectionné
                  decoration: InputDecoration(
                    labelText: "Sexe",
                    labelStyle: TextStyle(color: Colors.black), // 👈 Label en noir
                    border: UnderlineInputBorder(),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),

                DropdownButtonFormField<String>(
                  value: selectedEmploi,
                  items: ["Étudiant", "Employé", "Autre"].map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(color: Colors.black), // 👈 Options du menu en noir
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedEmploi = newValue!;
                    });
                  },
                  style: TextStyle(color: Colors.black), // 👈 Texte sélectionné en noir
                  decoration: InputDecoration(
                    labelText: "Type d'emploi",
                    labelStyle: TextStyle(color: Colors.black), // 👈 Label en noir
                    border: UnderlineInputBorder(),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                ),

                if (selectedEmploi == "Autre")
                  _buildLineTextField(autreEmploiController, "Précisez votre emploi"),
                _buildLineTextField(usernameController, "Nom d'utilisateur"),
                _buildLineTextField(passwordController, "Mot de passe", isPassword: true),
                _buildLineTextField(
                  confirmPasswordController,
                  "Confirmer le mot de passe",
                  isPassword: true,
                  isConfirmPassword: true,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        String username = usernameController.text.trim();
                        String emploiFinal = selectedEmploi == "Autre" ? autreEmploiController.text.trim() : selectedEmploi;
                        await FirebaseFirestore.instance.collection('User').add({
                          'prenom': prenomController.text.trim(),
                          'nom': nomController.text.trim(),
                          'email': emailController.text.trim(),
                          'sexe': selectedSexe,
                          'emploi': emploiFinal,
                          'username': username,
                          'password': passwordController.text.trim(),
                        });
                        await FirebaseFirestore.instance.collection('CompteUser').doc(username).set({
                          'username': username,
                          'password': passwordController.text.trim(),
                          'loggedIn': true,
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuccessPage(username: username),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erreur lors de la création du compte: $e")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 120.0, vertical: 12.0),
                  ),
                  child: const Text("Créer un compte"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineTextField(TextEditingController controller, String label,
      {bool isPassword = false, bool isConfirmPassword = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        style: TextStyle(color: Colors.black),

        controller: controller,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: UnderlineInputBorder(),
          filled: true,
          fillColor: Colors.transparent,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Veuillez entrer $label";
          }
          if (isEmail && !value.endsWith("@gmail.com")) {
            return "Veuillez entrer une adresse Gmail valide";
          }
          if (isPassword && value.length < 6) {
            return "Le mot de passe doit contenir au moins 6 caractères";
          }
          if (isConfirmPassword && value != passwordController.text) {
            return "Les mots de passe ne correspondent pas";
          }
          return null;
        },
      ),
    );
  }
}
