import 'package:flutter/material.dart';

class LogoutHelper {
  static Future<void> showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            child: const Text("Annuler"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text("Déconnexion"),
            onPressed: () {
              Navigator.of(context).pop(); // Ferme la boîte de dialogue
              _logout(context);
            },
          ),
        ],
      ),
    );
  }

  static void _logout(BuildContext context) {
    // Si tu utilises SharedPreferences pour sauvegarder des infos utilisateur, ajoute ici leur suppression

    // Redirige vers la page de login et supprime l'historique de navigation
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
