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

  @override
  void initState() {
    super.initState();
    initDialogFlowtter();
  }

  Future<void> initDialogFlowtter() async {
    try {
      await df.DialogFlowtter.fromFile(path: 'assets/dialogflow-auth.json')
          .then((instance) => setState(() => dialogFlowtter = instance));
    } catch (e) {
      debugPrint("Erreur d'initialisation Dialogflow: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      String userMessage = _controller.text;

      // Enregistrer le message utilisateur dans Firestore
      await FirebaseFirestore.instance.collection('Assistant_message').add({
        'text': userMessage,
        'sender': 'user',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _controller.clear();

      // Envoyer le message à Dialogflow
      df.DetectIntentResponse response = await dialogFlowtter.detectIntent(
        queryInput: df.QueryInput(text: df.TextInput(text: userMessage)),
      );

      if (response.message != null) {
        // Enregistrer la réponse du bot dans Firestore
        await FirebaseFirestore.instance.collection('Assistant_message').add({
          'text': response.message!.text!.text![0],
          'sender': 'bot',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Widget _buildMessages() {
    return Container(
      color: Colors.grey[200], // Fond gris léger
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Assistant_message')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var messages = snapshot.data!.docs;

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
        title: Text("Trainbot", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF353C67),  // Couleur modifiée ici
        elevation: 5,
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
                  backgroundColor: Color(0xFF353C67), // Couleur modifiée ici
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
          color: isUser ? Color(0xFF353C67) : Colors.grey[300], // Couleur modifiée ici
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
