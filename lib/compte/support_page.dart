import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final Color primaryColor = const Color(0xFF353C67);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, String>> faqData = [
    {
      "question": "Comment modifier mes informations ?",
      "answer": "Allez dans Paramètres > Modifier les informations."
    },
    {
      "question": "Comment activer le mode sombre ?",
      "answer": "Paramètres > Activer le thème sombre."
    },
    {
      "question": "Comment signaler un objet perdu ?",
      "answer": "Depuis la page d'accueil, accédez à la section 'Objets perdus'."
    },
    {
      "question": "Comment changer la langue de l'application ?",
      "answer": "Allez dans Paramètres > Changer la langue."
    },
    {
      "question": "Comment réinitialiser mon mot de passe ?",
      "answer": "Allez dans Paramètres > Changer le mot de passe."
    },
    {
      "question": "Comment supprimer mon compte ?",
      "answer": "Dans Paramètres, vous pouvez accéder à la section 'Supprimer le compte'."
    },
    {
      "question": "Comment contacter le support ?",
      "answer": "Utilisez le formulaire ci-dessous pour envoyer un message."
    },
  ];

  void _envoyerMessage() {
    if (_formKey.currentState!.validate()) {
      // Tu peux ici envoyer vers Firestore ou autre service
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Votre message a été envoyé avec succès !"),
          backgroundColor: Colors.green,
        ),
      );
      _emailController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aide & Support"),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "📌 Questions fréquentes",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...faqData.map((item) => ExpansionTile(
              title: Text(
                item['question']!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(item['answer']!),
                )
              ],
            )),
            const Divider(height: 40),
            const Text(
              "✉️ Contactez-nous",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Votre email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value != null && value.contains('@') ? null : "Email invalide",
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Votre message',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value != null && value.isNotEmpty ? null : "Message vide",
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _envoyerMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.send),
                    label: const Text("Envoyer"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
