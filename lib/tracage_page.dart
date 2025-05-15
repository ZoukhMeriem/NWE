import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'SuiviTempsReelPage.dart';
class TracagePage extends StatelessWidget {
  const TracagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const
        Text(
          'Suivi du Trajet',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0x998BB1FF),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 🗺️ Carte ou animation de train en haut
          // 🗺️ Carte ou animation de train en haut dans un Card avec mesures modifiables
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // 🔧 Marge extérieure du Card
            child: Card(
              elevation: 24, // Ombre du cadre (entre 0 et 24 en général)
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // 🔧 Coins arrondis (ex: 12, 16, 20, etc.)
              ),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 320, // 🔧 Hauteur de l’image
                width: 350, // 🔧 Largeur (tu peux mettre un fixe genre 350 si tu veux)
                child: Image.asset(
                  'assets/images/train_on_map.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),


          // 💬 Message avec effet d'écriture et style soigné
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontFamily: 'Courier',
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  child: AnimatedTextKit(
                    isRepeatingAnimation: false,
                    totalRepeatCount: 1,
                    animatedTexts: [
                      TypewriterAnimatedText(
                        "Chers voyageurs, nous vous remercions d'avoir choisi ce trajet. "
                            "Pour recevoir tous les détails et notifications du trajet et tracer en temps réel le train, cliquez sur ",
                        speed: Duration(milliseconds: 50),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SuiviTempsReelPage()),
                    );
                  },
                  child: const Text(
                    "Tracker",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0x998BB1FF),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  "Nous vous souhaitons un agréable voyage.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
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
