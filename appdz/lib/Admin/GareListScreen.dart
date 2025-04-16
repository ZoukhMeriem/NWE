import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GareManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gareRef = FirebaseFirestore.instance.collection('Gare');

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Gares'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: gareRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final gares = snapshot.data!.docs;

          return ListView.builder(
            itemCount: gares.length,
            itemBuilder: (context, index) {
              final gare = gares[index];
              final data = gare.data() as Map<String, dynamic>;

              final name = data['name'] ?? 'Nom inconnu';
              final id = data['id'] ?? 'ID inconnu';
              final location = data['location'] ?? {};
              final lat = location['lat'] ?? 0.0;
              final lng = location['lng'] ?? 0.0;
              final lignes = List<String>.from(data['lineId'] ?? []);

              return ListTile(
                title: Text(name),
                subtitle: Text('ID: $id | ${lignes.join(', ')}\nLat: $lat, Lng: $lng'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {
                        // TODO: formulaire de modification
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await gareRef.doc(gare.id).delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: formulaire d'ajout
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
