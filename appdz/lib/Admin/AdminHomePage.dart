import 'package:dztrainfay/Admin/train_management_screen.dart';
import 'package:flutter/material.dart';

import 'AdminListScreen.dart';
import 'GareListScreen.dart';
import 'LigneListScreen.dart';
import 'UserListScreen.dart';

class AdminHomePage extends StatelessWidget {
  final String adminUsername;

  const AdminHomePage({required this.adminUsername});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Espace Administrateur'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue admin : $adminUsername',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            _buildMenuButton(context, "Gérer les Admins", AdminListScreen()),
            _buildMenuButton(context, "Gérer les Gares", GareManagementScreen()),
            _buildMenuButton(context, "Gérer les Lignes", LigneManagementScreen()),
            _buildMenuButton(context, "Gérer les Utilisateurs", UserListScreen()),
            _buildMenuButton(context, "Gérer les Trains", TrainManagementScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, Widget screen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, 50),
          backgroundColor: Colors.indigo,
        ),
        icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
        label: Text(label, style: TextStyle(fontSize: 16, color: Colors.white)),
        onPressed: () => _navigateTo(context, screen),
      ),
    );
  }
}












