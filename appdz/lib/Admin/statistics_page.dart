import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Statistiques"),
        backgroundColor: Color(0xFF607D8B),
      ),
      body: Center(
        child: Text(
          "📊 Statistiques en cours de développement...",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
