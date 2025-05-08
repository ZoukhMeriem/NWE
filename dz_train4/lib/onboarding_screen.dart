import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'SignInScreen.dart';


class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == 2; // Vérifie si c'est la dernière page
              });
            },
            children: [
              buildPage("Bienvenue sur DZTrain !", "Suivez en temps réel les trains de la banlieue d'Alger et voyagez en toute sérénité.", 'assets/images/screen1.png'),
              buildPage("Ne manquez jamais un train !", "Consultez les horaires en direct, les retards et l'état du trafic ferroviaire.", 'assets/images/screen2.png'),
              buildPage("Optimisez vos déplacements", "Trouvez le meilleur itinéraire et recevez des notifications en cas de perturbations.", 'assets/images/screen3.png'),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: isLastPage
                ? ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('onboarding_seen', true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SignInScreen()), // Rediriger vers SignInScreen
                );
              },
              child: Text("Commencer"),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _controller.jumpToPage(2),
                  child: Text("Passer"),
                ),
                FloatingActionButton(
                  onPressed: () {
                    _controller.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease);
                  },
                  child: Icon(Icons.arrow_forward),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildPage(String title, String subtitle, String imagePath) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image en fond d'écran
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover, // S'assure que l'image remplit tout l'écran
            ),
          ),
        ),

        // Overlay sombre pour une meilleure lisibilité du texte
        Container(
          color: Colors.black.withOpacity(0.4), // Opacité de 40%
        ),

        // Texte centré sur l'image
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Titre animé
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    title,
                    textStyle: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat', // Assure-toi d'ajouter cette police
                    ),
                    speed: Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
              ),
              SizedBox(height: 15),

              // Explication animée avec un effet Scale pour un effet progressif
              AnimatedTextKit(
                animatedTexts: [
                  ScaleAnimatedText(
                    subtitle,
                    textStyle: TextStyle(
                      fontSize: 18, // Taille légèrement plus petite que le titre
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                    ),
                    duration: Duration(seconds: 20),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}