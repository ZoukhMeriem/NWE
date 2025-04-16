import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'chatbot_welcome_screen.dart';
import 'lost_object_screen.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedIndex = 0;

  final Map<String, String> chatNameMapping = {
    "chat_ligne1": "chat Alger - Aéroport Houari-Boumediene",
    "chat_ligne3": "chat Alger - Zéralda",
    "chat_ligne4": "chat Alger - Thénia",
    "chat_ligne5": "chat Alger - El Affroun",
  };

  final Map<String, String> ligneImages = {
    "chat Alger - Aéroport Houari-Boumediene": "assets/images/ligne1.png",
    "chat Alger - Zéralda": "assets/images/ligne3.png",
    "chat Alger - Thénia": "assets/images/ligne4.png",
    "chat Alger - El Affroun": "assets/images/ligne5.png",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // 🟦 Titre Discussions
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 20),
              color: Color(0xFF353C67),
              child: Center(
                child: Text(
                  'Discussions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ⚪ Boutons
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopButton("Salons", 0),
                  _buildTopButton("Assistant", 1),
                  _buildTopButton("Objets perdus", 2),
                ],
              ),
            ),

            // 📜 Contenu selon l'onglet sélectionné
            Expanded(
              child: _selectedIndex == 0
                  ? _buildChatList()
                  : _selectedIndex == 1
                  ? ChatbotWelcomeScreen()
                  : LostObjectFormScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopButton(String label, int index) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Color(0xFF353C67) : Colors.white,
            foregroundColor: isSelected ? Colors.white : Colors.black,
            side: BorderSide(color: Colors.grey.shade400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chats').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildPlaceholder();
        }

        var chats = snapshot.data!.docs;
        var filteredChats =
        chats.where((chat) => chat.id != "chat_ligne2").toList();

        if (filteredChats.isEmpty) {
          return _buildPlaceholder();
        }

        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            var chat = filteredChats[index];
            String chatId = chat.id;
            String ligne = chatNameMapping[chatId] ?? "Chat inconnu";

            return StreamBuilder(
              stream: chat.reference
                  .collection("messages")
                  .orderBy("timestamp", descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> messageSnapshot) {
                if (!messageSnapshot.hasData ||
                    messageSnapshot.data!.docs.isEmpty) {
                  return _buildChatCard(ligne, "Aucun message", "--:--", chatId);
                }

                var lastMessage = messageSnapshot.data!.docs.first;
                String message = lastMessage["text"] ?? "Aucun message";
                String time = lastMessage["timestamp"] != null
                    ? DateFormat('HH:mm')
                    .format(lastMessage["timestamp"].toDate())
                    : "--:--";

                return _buildChatCard(ligne, message, time, chatId);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildChatCard(
      String ligne, String message, String time, String chatId) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.asset(
            ligneImages[ligne] ?? 'assets/images/default.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          ligne,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF353C67),
          ),
        ),
        subtitle: Text(
          message,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Text(
          time,
          style: TextStyle(color: Colors.grey),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(chatId: chatId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Text(
        "Aucune discussion disponible.",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
