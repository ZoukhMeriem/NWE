import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color mainColor = Color(0xFF353C67); // Remplace indigo par Color(0xFF353C67)

class LostObjectStatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Suivi des objets perdus",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainColor, // Utilisation de Color(0xFF353C67)
        elevation: 5,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('lost_objects').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: mainColor), // Utilisation de Color(0xFF353C67)
                  SizedBox(height: 10),
                  Text("Chargement...", style: TextStyle(fontSize: 16, color: mainColor)), // Utilisation de Color(0xFF353C67)
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('❌ Erreur : ${snapshot.error}', style: TextStyle(color: Colors.red)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Aucun objet perdu signalé.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String objectName = data['name'] ?? 'Nom inconnu';
              String status = data['status'] ?? 'En cours';
              String description = data['description'] ?? 'Aucune description';
              String date = data['date'] ?? 'Date inconnue';
              String? imageUrl = data['imageUrl']; // Image optionnelle

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                margin: EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 🔹 Image de l'objet perdu
                          if (imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                            ),
                          SizedBox(width: 12),

                          // 🔹 Infos sur l'objet
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  objectName,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainColor), // Utilisation de Color(0xFF353C67)
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "📌 Description : $description",
                                  style: TextStyle(fontSize: 14, color: Colors.black87),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "📅 Date : $date",
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15),

                      // 🔹 Statut de l'objet avec une couleur spécifique
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(status),
                          Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Fonction pour afficher le statut avec une couleur spécifique
  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'trouvé':
        badgeColor = Colors.green;
        break;
      case 'non trouvé':
        badgeColor = Colors.red;
        break;
      default:
        badgeColor = Colors.orange; // "En cours de traitement"
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: badgeColor),
          SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: badgeColor),
          ),
        ],
      ),
    );
  }
}
