import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePasswordPage extends StatefulWidget {
  final String userId;

  const ChangePasswordPage({super.key, required this.userId});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Color mainColor = const Color(0xFF353C67);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Changer le mot de passe"),
        backgroundColor: mainColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Modifiez votre mot de passe",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: mainColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(_currentPasswordController, "Mot de passe actuel", Icons.lock_outline),
                  const SizedBox(height: 16),
                  _buildPasswordField(_newPasswordController, "Nouveau mot de passe", Icons.lock),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: _inputDecoration("Confirmer le mot de passe", Icons.lock),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return "Les mots de passe ne correspondent pas";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _changePassword,
                    label: const Text("Enregistrer"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: mainColor),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: _inputDecoration(label, icon),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Veuillez remplir ce champ";
        }
        return null;
      },
    );
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userDoc = await _firestore.collection('User').doc(widget.userId).get();

        if (!userDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Utilisateur non trouvé.")),
          );
          return;
        }

        String currentPassword = userDoc['password'].toString().trim();
        String enteredPassword = _currentPasswordController.text.trim();

        if (enteredPassword == currentPassword) {
          await _firestore.collection('User').doc(widget.userId).update({
            'password': _newPasswordController.text.trim(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("🔒 Mot de passe modifié avec succès")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ Mot de passe actuel incorrect.")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Erreur : $e")),
        );
      }
    }
  }
}
