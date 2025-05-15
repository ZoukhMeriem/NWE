import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart' as df;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainbotChatScreen extends StatefulWidget {
  @override
  _TrainbotChatScreenState createState() => _TrainbotChatScreenState();
}

class _TrainbotChatScreenState extends State<TrainbotChatScreen> {
  late df.DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();
  bool isReady = false;
  String? username;

  String get chatId => FirebaseAuth.instance.currentUser?.uid ?? "invité";

  @override
  void initState() {
    super.initState();
    initDialogFlowtter();
    loadUsername();
    _ensureUserDocument();
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'Utilisateur';
    });
  }

  Future<void> _ensureUserDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('User').doc(user.uid);
      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists && docSnapshot.data()!.containsKey('username')) {
        await FirebaseFirestore.instance.collection('TrainbotPrivateChats').doc(user.uid).set({
          'username': docSnapshot['username'],
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> initDialogFlowtter() async {
    debugPrint("\u{1F504} Initialisation de Dialogflow...");
    try {
      final instance = await df.DialogFlowtter.fromFile(
        path: 'assets/dialogflow-auth.json',
      );
      debugPrint("\u{2705} Dialogflow initialisé avec succès !");
      setState(() {
        dialogFlowtter = instance;
        isReady = true;
      });
    } catch (e) {
      debugPrint("\u{274C} Erreur d'initialisation Dialogflow: $e");
    }
  }

  Future<void> _sendMessage() async {
    if (!isReady || _controller.text.trim().isEmpty) return;

    String userMessage = _controller.text.trim();
    _controller.clear();

    await FirebaseFirestore.instance
        .collection('TrainbotPrivateChats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': userMessage,
      'sender': username,
      'owner': username, // 🆕 pour filtrer plus tard
      'timestamp': FieldValue.serverTimestamp(),
    });


    try {
      final response = await dialogFlowtter.detectIntent(
        queryInput: df.QueryInput(text: df.TextInput(text: userMessage)),
      );

      String botResponse = "Désolée, je n'ai pas compris.";
      if (response.message != null &&
          response.message!.text != null &&
          response.message!.text!.text!.isNotEmpty) {
        botResponse = response.message!.text!.text![0];
      }

      await FirebaseFirestore.instance
          .collection('TrainbotPrivateChats')
          .doc(chatId)
          .collection('messages')
          .add({
        'text': botResponse,
        'sender': 'bot',
        'owner': username, // 🆕 propriété du message
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      debugPrint("\u{274C} Erreur avec Dialogflow : $e");
    }
  }

  Widget _buildMessages() {
    return Container(
      color: Colors.white,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('TrainbotPrivateChats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var messages = snapshot.data!.docs;
          if (messages.isEmpty) {
            return Center(
              child: Text("Aucun message pour l'instant",
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var messageData = messages[index];

              // ❗️On vérifie que le message appartient à l'utilisateur connecté
              if (messageData['owner'] != username) {
                return SizedBox.shrink();
              }

              return ChatMessage(
                text: messageData['text'],
                isUser: messageData['sender'] == username,
              );
            },
          );


        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: Text("TrainBot - ${isReady ? 'Prêt \u{2705}' : 'Chargement...'}"),
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
                    style: TextStyle(
                      color: isLight ? Colors.black : Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      hintStyle: TextStyle(
                        color: isLight ? Colors.grey[600] : Colors.grey[300],
                      ),
                      filled: true,
                      fillColor: isLight ? Colors.white : Colors.grey[800],
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