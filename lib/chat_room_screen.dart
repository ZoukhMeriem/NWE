import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:async';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  ChatRoomScreen({required this.chatId});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _startAutoDelete(); // Démarrer la suppression automatique
  }

  void _sendMessage({String? imageUrl}) async {
    if (_messageController.text.trim().isEmpty && imageUrl == null) return;
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).collection('messages').add({
      'text': imageUrl ?? _messageController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'isImage': imageUrl != null,
      'sender': _currentUser?.uid ?? 'unknown',
    });
    _messageController.clear();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('chat_images/$fileName');
      await ref.putFile(file);
      String imageUrl = await ref.getDownloadURL();
      _sendMessage(imageUrl: imageUrl);
    }
  }

  void _deleteOldMessages() async {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(hours: 24));
    final querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
        DateTime messageTime = (data['timestamp'] as Timestamp).toDate();
        if (messageTime.isBefore(cutoff)) {
          await doc.reference.delete();
        }
      }
    }
  }

  void _startAutoDelete() {
    Timer.periodic(Duration(hours: 1), (timer) {
      _deleteOldMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF353C67), // Remplace indigo par Color(0xFF353C67)
        elevation: 5,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var message = snapshot.data!.docs[index];
                    bool isMe = message['sender'] == _currentUser?.uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFF353C67) : Colors.grey.shade300, // Remplace indigo par Color(0xFF353C67)
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: message['isImage']
                            ? Image.network(message['text'], width: 200)
                            : Text(
                          message['text'],
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image, color: Color(0xFF353C67)), // Remplace indigo par Color(0xFF353C67)
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Écrire un message...',
                      border: InputBorder.none,
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF353C67)), // Remplace indigo par Color(0xFF353C67)
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF353C67)), // Remplace indigo par Color(0xFF353C67)
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
