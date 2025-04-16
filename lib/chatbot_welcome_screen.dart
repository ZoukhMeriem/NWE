import 'package:flutter/material.dart';
import 'tainbot_chat_screen.dart';

class ChatbotWelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // GIF en arrière-plan qui prend toute la page
          Positioned.fill(
            child: Image.asset(
              "assets/images/chat_animation.gif",
              fit: BoxFit.cover, // Pour couvrir toute la page
            ),
          ),
          // Contenu (texte + bouton) au centre
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Bienvenue dans Tainbot !",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Texte en blanc pour la visibilité
                    shadows: [
                      Shadow(
                        blurRadius: 5,
                        color: Colors.black54,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TrainbotChatScreen()),
                    );
                  },
                  child: Text("Commencer", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

