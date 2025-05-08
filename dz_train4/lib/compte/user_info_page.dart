import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserInfoPage({required this.userData, Key? key}) : super(key: key);

  final Color primaryColor = const Color(0x998BB1FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil utilisateur", style: TextStyle(color: Colors.black)),
        backgroundColor: primaryColor,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildInfoTile(Icons.person, "Nom", userData['nom'] ?? "Non renseigné"),
          _buildInfoTile(Icons.badge, "Prénom", userData['prenom'] ?? "Non renseigné"),
          _buildInfoTile(Icons.account_circle, "Nom d'utilisateur", userData['username'] ?? "Non renseigné"),
          _buildInfoTile(Icons.email, "Email", userData['email'] ?? "Non renseigné"),
          _buildInfoTile(Icons.wc, "Sexe", userData['sexe'] ?? "Non renseigné"),
          _buildInfoTile(Icons.work, "Emploi", userData['emploi'] ?? "Non renseigné"),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: primaryColor.withOpacity(0.2),
          child: const Icon(Icons.person, size: 50, color: Colors.black),
        ),
        const SizedBox(height: 12),
        Text(
          (userData['nom'] != null && userData['prenom'] != null)
              ? "${userData['prenom']} ${userData['nom']}"
              : "Utilisateur inconnu",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        subtitle: Text(value, style: const TextStyle(color: Colors.black87)),
      ),
    );
  }
}
