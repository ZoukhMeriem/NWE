import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LigneManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ligneRef = FirebaseFirestore.instance.collection('LIGNE');

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Lignes'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ligneRef.snapshots(),
        builder: (context, snapshot) {
          // Afficher erreur Firestore
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }

          // Afficher loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final lignes = snapshot.data!.docs;

          // Si la collection est vide
          if (lignes.isEmpty) {
            return Center(child: Text("Aucune ligne trouvée."));
          }

          return ListView.builder(
            itemCount: lignes.length,
            itemBuilder: (context, index) {
              final ligne = lignes[index];
              final data = ligne.data() as Map<String, dynamic>;

              final String nom = data['nom'] ?? 'Sans nom';
              final String code = data['code'] ?? 'Aucun code';
              final List gares = data['gares'] ?? [];

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('$nom ($code)'),
                  subtitle: Text("Gares : ${gares.join(', ')}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () {
                          // TODO: ouvrir formulaire de modification
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Confirmer la suppression"),
                              content: Text("Supprimer cette ligne ?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text("Annuler"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text("Supprimer"),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ligneRef.doc(ligne.id).delete();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: ouvrir formulaire d'ajout
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
