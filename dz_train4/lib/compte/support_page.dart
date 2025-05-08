import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';


class SupportPage extends StatefulWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final Color primaryColor = const Color(0xFF998BB1FF);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool showRatingBar = false;

  double _noteDonnee = 3.0; // note par défaut

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


  void _envoyerNote() async {
    try {
      await FirebaseFirestore.instance.collection('Evaluations').add({
        'note': _noteDonnee, // 🔥 ta note entre 0 et 5 avec des 0.5 possibles
        'date': Timestamp.now(), // tu ajoutes aussi la date
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Merci pour votre évaluation de $_noteDonnee/5 !')),
      );

      setState(() {
        showRatingBar = false; // cacher les étoiles après envoi
        _noteDonnee = 3.0; // reset la note pour la prochaine fois
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi de l\'évaluation.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Aide & Support",
          style: TextStyle(color: Colors.black), // Définit le texte en noir
        ),
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
                  const SizedBox(height: 20),
                  Text('Évaluez notre application :', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        showRatingBar = true; // 🔥 Quand on clique, on affiche les étoiles
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF4D9DE),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.star_rate),
                    label: const Text("Évaluez-nous"),
                  ),

                  if (showRatingBar) ...[
                    const SizedBox(height: 20),
                    Text('⭐ Donnez votre note :', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    RatingBar.builder(
                      initialRating: _noteDonnee,
                      minRating: 0,
                      maxRating: 5,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _noteDonnee = rating; // 🔥 sauver la note choisie
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _envoyerNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  Color(0xFFF4D9DE),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text("Envoyer mon évaluation"),
                    ),
                  ],


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
