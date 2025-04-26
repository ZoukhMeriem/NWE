import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trajet_principal_widget.dart';

class HoraireTrainPage extends StatefulWidget {
  @override
  _HoraireTrainPageState createState() => _HoraireTrainPageState();
}

class _HoraireTrainPageState extends State<HoraireTrainPage> {
  bool showTrajet = false;
  final Color primaryColor = const Color(0xFF353C67);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Horaires de trains"),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: Icon(Icons.train),
              label: Text("Trajet 1", style: TextStyle(fontSize: 16)),
              onPressed: () {
                setState(() {
                  showTrajet = !showTrajet;
                });
              },
            ),
            SizedBox(height: 20),
            if (showTrajet) Expanded(child: TrajetPrincipalWidget()),
          ],
        ),
      ),
    );
  }
}
