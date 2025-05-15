import 'package:flutter/material.dart';
import 'SignInScreen.dart';

class PasswordChangedScreen extends StatelessWidget {
  final ButtonStyle myButtonStyle = ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return Colors.indigo.shade700;
        }
        return Colors.indigo;
      },
    ),
    overlayColor: MaterialStateProperty.all(
      Colors.indigoAccent.withOpacity(0.2),
    ),
    padding: MaterialStateProperty.resolveWith<EdgeInsets>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.pressed)) {
          return EdgeInsets.symmetric(horizontal: 45, vertical: 10);
        }
        return EdgeInsets.symmetric(horizontal: 50, vertical: 12);
      },
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mot de passe changé')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFe0eafc), // 🔵 Dégradé bleu clair
              Color(0xFFcfdef3), // 🔵 Bleu-gris en bas
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Votre mot de passe\n a été changé avec succès !',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                  style: myButtonStyle,
                  child: Text(
                    'Se connecter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
