import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'SignInScreen.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfilePage({required this.userData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController prenomController;
  late TextEditingController nomController;
  late TextEditingController emailController;
  late TextEditingController emploiController;
  late TextEditingController passwordController;
  late TextEditingController usernameController;
  String selectedSexe = "Homme";
  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    prenomController = TextEditingController(text: widget.userData['prenom']);
    nomController = TextEditingController(text: widget.userData['nom']);
    emailController = TextEditingController(text: widget.userData['email']);
    emploiController = TextEditingController(text: widget.userData['emploi']);
    passwordController = TextEditingController(text: widget.userData['password']);
    usernameController = TextEditingController(text: widget.userData['username']);
    selectedSexe = widget.userData['sexe'] ?? "Homme";
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('User').doc(widget.userData['email']).update({
          'prenom': prenomController.text.trim(),
          'nom': nomController.text.trim(),
          'email': emailController.text.trim(),
          'sexe': selectedSexe,
          'emploi': emploiController.text.trim(),
          'username': usernameController.text.trim(),
          'password': passwordController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Profil mis à jour avec succès !')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur de mise à jour : $e')),
        );
      }
    }
  }

  void deleteAccount() async {
    try {
      String email = widget.userData['email'];
      await FirebaseFirestore.instance.collection('User').doc(email).delete();
      await FirebaseAuth.instance.currentUser?.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Compte supprimé avec succès !')),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur lors de la suppression du compte : $e')),
      );
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
      return AlertDialog(
          title: Text("Modifier le profil"),
    content: SingleChildScrollView(
    child: Form(
    key: _formKey,
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    _buildTextField(nomController, "Nom", Icons.person),
    _buildTextField(prenomController, "Prénom", Icons.person),
    _buildTextField(emailController, "Email", Icons.email),
    _buildTextField(emploiController, "Emploi", Icons.work),
    DropdownButtonFormField(
    value: selectedSexe,
    items: ["Homme", "Femme"].map((sexe) {
    return DropdownMenuItem(value: sexe, child: Text(sexe));
    }).toList(),
    onChanged: (value) => setState(() => selectedSexe = value!),
    decoration: InputDecoration(labelText: "Sexe"),
    ),
    _buildTextField(passwordController, "Mot de passe", Icons.lock, obscureText: true),
    ],
    ),
    ),
    ),
        actions: [
          TextButton(
            child: Text("Annuler"),
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialogue
            },
          ),
          TextButton(
            child: Text("Enregistrer"),
            onPressed: () {
              Navigator.of(context).pop(); // Fermer le dialogue
              updateProfile(); // Appeler la fonction pour mettre à jour le profil
            },
          ),
        ],
      );
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: Text("Modifier le profil")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Photo de profil et nom d'utilisateur placés à l'extérieur
            Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null ? Icon(Icons.camera_alt, size: 50) : null,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.userData['username'],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
              ],
            ),

            // Informations personnelles
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Informations personnelles", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    ListTile(title: Text("Email: ${widget.userData['email']}")),
                    ListTile(title: Text("Nom: ${widget.userData['nom']}")),
                    ListTile(title: Text("Prénom: ${widget.userData['prenom']}")),
                    ListTile(title: Text("Emploi: ${widget.userData['emploi']}")),
                    TextButton(
                      onPressed: () => _showEditDialog(context), // Afficher le dialogue
                      child: Text("Modifier", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ),

            // Suppression de compte
            SizedBox(height: 20),
            Card(
              color: Colors.red[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "⚠️ Suppression du compte",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "En supprimant votre compte, vous perdrez toutes vos données. Cette action est irréversible.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: deleteAccount,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Supprimer mon compte", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          prefixIcon: Icon(icon), // Ajout de l'icône
        ),
        obscureText: obscureText,
        validator: (value) => value == null || value.isEmpty ? '$label ne peut pas être vide' : null,
      ),
    );
  }
}