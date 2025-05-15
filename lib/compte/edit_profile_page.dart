import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color mainColor = const Color(0xFF353C67);

  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController emploiController;
  String selectedSexe = "Homme";

  @override
  void initState() {
    super.initState();
    nomController = TextEditingController(text: widget.userData['nom'] ?? '');
    prenomController = TextEditingController(text: widget.userData['prenom'] ?? '');
    usernameController = TextEditingController(text: widget.userData['username'] ?? '');
    emailController = TextEditingController(text: widget.userData['email'] ?? '');
    emploiController = TextEditingController(text: widget.userData['emploi'] ?? '');
    selectedSexe = widget.userData['sexe'] ?? 'Homme';
  }

  Future<void> saveChanges() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(widget.userData['id'])
            .update({
          'nom': nomController.text.trim(),
          'prenom': prenomController.text.trim(),
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'emploi': emploiController.text.trim(),
          'sexe': selectedSexe,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Profil mis à jour avec succès")),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur de mise à jour : $e")),
        );
      }
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: mainColor),
          labelStyle: TextStyle(color: mainColor),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: mainColor, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$label ne peut pas être vide";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Modifier le profil"),
        backgroundColor: mainColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(nomController, "Nom", Icons.person),
              _buildTextField(prenomController, "Prénom", Icons.person_outline),
              _buildTextField(usernameController, "Nom d'utilisateur", Icons.account_circle),
              _buildTextField(emailController, "Email", Icons.email),
              _buildTextField(emploiController, "Emploi", Icons.work_outline),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: DropdownButtonFormField<String>(
                  value: selectedSexe,
                  decoration: InputDecoration(
                    labelText: "Sexe",
                    prefixIcon: Icon(Icons.wc, color: mainColor),
                    labelStyle: TextStyle(color: mainColor),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "Homme", child: Text("Homme")),
                    DropdownMenuItem(value: "Femme", child: Text("Femme")),
                  ],
                  onChanged: (value) {
                    setState(() => selectedSexe = value!);
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: saveChanges,
                  icon: const Icon(Icons.save),
                  label: const Text("Enregistrer", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
