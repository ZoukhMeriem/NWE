import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserInfoPage({required this.userData, Key? key}) : super(key: key);

  final Color mainColor = const Color(0xFF353C67);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Informations personnelles"),
        backgroundColor: mainColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildInfoCard(Icons.person, "Nom", userData['nom'] ?? "Non renseigné"),
            _buildInfoCard(Icons.badge, "Prénom", userData['prenom'] ?? "Non renseigné"),
            _buildInfoCard(Icons.account_circle, "Nom d'utilisateur", userData['username'] ?? "Non renseigné"),
            _buildInfoCard(Icons.email, "Email", userData['email'] ?? "Non renseigné"),
            _buildInfoCard(Icons.wc, "Sexe", userData['sexe'] ?? "Non renseigné"),
            _buildInfoCard(Icons.work, "Emploi", userData['emploi'] ?? "Non renseigné"),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: mainColor.withOpacity(0.1),
          child: Icon(Icons.person, size: 50, color: mainColor),
        ),
        const SizedBox(height: 10),
        Text(
          userData['nom'] != null && userData['prenom'] != null
              ? "${userData['nom']} ${userData['prenom']}"
              : "Utilisateur inconnu",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainColor),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: mainColor),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: mainColor)),
        subtitle: Text(value, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
