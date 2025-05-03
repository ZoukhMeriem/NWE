import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart' as df;
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainbotChatScreen extends StatefulWidget {
  @override
  _TrainbotChatScreenState createState() => _TrainbotChatScreenState();
}

class _TrainbotChatScreenState extends State<TrainbotChatScreen> {
  late df.DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  bool isReady = false;
  final String userId = "invité";

  @override
  void initState() {
    super.initState();
    initDialogFlowtter();
  }

  Future<void> initDialogFlowtter() async {
    debugPrint("🔄 Initialisation de Dialogflow...");
    try {
      final instance = await df.DialogFlowtter.fromFile(
        path: 'assets/dialogflow-auth.json',
      );
      debugPrint("✅ Dialogflow initialisé avec succès !");
      setState(() {
        dialogFlowtter = instance;
        isReady = true;
      });
    } catch (e) {
      debugPrint("❌ Erreur d'initialisation Dialogflow: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (!isReady) {
      debugPrint("⚠️ Dialogflow n'est pas prêt !");
      return;
    }

    if (_controller.text.trim().isEmpty) {
      debugPrint("⚠️ Message vide, rien à envoyer.");
      return;
    }

    String userMessage = _controller.text.trim();
    _controller.clear();
    debugPrint("➡️ Message utilisateur : $userMessage");

    try {
      // Sauvegarder le message utilisateur dans Firestore
      await FirebaseFirestore.instance.collection('Assistant_message').add({
        'text': userMessage,
        'sender': 'user',
        'timestamp': FieldValue.serverTimestamp(),
        'userId': userId,
      });
      debugPrint("✅ Message utilisateur enregistré dans Firestore");

    } catch (e) {
      debugPrint("❌ Erreur en enregistrant le message utilisateur : $e");
    }

    // Envoyer à Dialogflow
    try {
      debugPrint("📨 Envoi à Dialogflow...");
      final response = await dialogFlowtter.detectIntent(
        queryInput: df.QueryInput(text: df.TextInput(text: userMessage)),
      );

      debugPrint("📩 Réponse Dialogflow reçue : ${response.message}");

      String botResponse = "Désolée, je n'ai pas compris. Pouvez-vous reformuler ?";
      if (response.message != null &&
          response.message!.text != null &&
          response.message!.text!.text!.isNotEmpty) {
        botResponse = response.message!.text!.text![0];
      }

      debugPrint("🤖 Réponse bot : $botResponse");

      // Sauvegarder la réponse du bot dans Firestore
      try {
        await FirebaseFirestore.instance.collection('Assistant_message').add({
          'text': botResponse,
          'sender': 'bot',
          'timestamp': FieldValue.serverTimestamp(),
          'userId': userId,
        });
        debugPrint("✅ Réponse bot enregistrée dans Firestore");

      } catch (e) {
        debugPrint("❌ Erreur en enregistrant la réponse bot : $e");
      }

    } catch (e) {
      debugPrint("❌ Erreur lors de la communication avec Dialogflow : $e");
    }
  }

  Widget _buildMessages() {
    return Container(
      color: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Assistant_message')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            debugPrint("📡 Chargement des messages...");
            return Center(child: CircularProgressIndicator());
          }

          var messages = snapshot.data!.docs;
          debugPrint("📥 ${messages.length} messages chargés depuis Firestore");

          if (messages.isEmpty) {
            return Center(
              child: Text(
                "Aucun message pour l'instant",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var messageData = messages[index];
              return ChatMessage(
                text: messageData['text'],
                isUser: messageData['sender'] == 'user',
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TrainBot - ${isReady ? 'Prêt ✅' : 'Chargement...'}"),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Flexible(child: _buildMessages()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.indigo,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        padding: EdgeInsets.all(14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Colors.indigo : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: isUser ? Radius.circular(20) : Radius.zero,
            bottomRight: isUser ? Radius.zero : Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
