import 'package:flutter/material.dart';

class SuiviTempsReelPage extends StatelessWidget {
  const SuiviTempsReelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Suivi en Temps Réel"),
        backgroundColor: Color(0x998BB1FF),
      ),
      body: const Center(
        child: Text(
          "Ici s'affichera la carte de suivi en temps réel du train.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
