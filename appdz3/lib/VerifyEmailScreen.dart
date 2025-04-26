import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatelessWidget {
  final int verificationCode; // Code de vérification reçu
  final String email; // Adresse e-mail liée

  VerifyEmailScreen({required this.verificationCode, required this.email}); // Constructeur

  final TextEditingController codeController = TextEditingController(); // Ajoutez un contrôleur pour le champ de code

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vérifiez votre e-mail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Veuillez entrer le code à 4 chiffres envoyé à'),
            Text(email, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: codeController,
              maxLength: 4,
              decoration: InputDecoration(labelText: 'Entrez le code'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Vérifiez si le code entré correspond au code envoyé
                if (int.tryParse(codeController.text) == verificationCode) {
                  // Code valide, redirigez vers la page de réinitialisation du mot de passe ou autre action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Code vérifié avec succès !')),
                  );
                  // Par exemple, naviguer vers une page de réinitialisation de mot de passe
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Code invalide, veuillez réessayer.')),
                  );
                }
              },
              child: Text('Vérifier'),
            ),
          ],
        ),
      ),
    );
  }
}