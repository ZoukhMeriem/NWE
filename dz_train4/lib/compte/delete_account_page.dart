import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteAccountPage extends StatelessWidget {
  final String userId;

  const DeleteAccountPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0x998BB1FF);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🗑️ Supprimer le compte"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.warning_amber_rounded, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete),
              label: const Text("Supprimer mon compte"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () => _supprimerCompte(context),
            ),
          ],
        ),
      ),
    );
  }

  void _supprimerCompte(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('User').doc(userId).delete();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la suppression du compte")),
      );
    }
  }
}
