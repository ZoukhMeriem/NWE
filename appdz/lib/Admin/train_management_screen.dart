import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TrainManagementScreen extends StatefulWidget {
  @override
  _TrainManagementScreenState createState() => _TrainManagementScreenState();
}

class _TrainManagementScreenState extends State<TrainManagementScreen> {
  final trainRef = FirebaseFirestore.instance.collection('TRAIN');

  void showTrainDetails(Map<String, dynamic> data) {
    final lat = data['position']?['lat'];
    final lng = data['position']?['lng'];
    final lastUpdated = data['lastUpdated'] != null
        ? DateFormat('dd MMM yyyy à HH:mm').format((data['lastUpdated'] as Timestamp).toDate())
        : 'Non défini';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Détails du Train"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Numéro du train : ${data['numtrain']}"),
            Text("ID de la ligne : ${data['lineId']}"),
            Text("Statut : ${data['status']}"),
            Text("Latitude : ${lat ?? '---'}"),
            Text("Longitude : ${lng ?? '---'}"),
            Text("Mis à jour : $lastUpdated"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fermer"),
          ),
        ],
      ),
    );
  }

  void showTrainForm({DocumentSnapshot? train}) {
    final numController = TextEditingController(text: train?['numtrain'] ?? '');
    final lineController = TextEditingController(text: train?['lineId'] ?? '');
    final statusController = TextEditingController(text: train?['status'] ?? '');
    final latController = TextEditingController(text: train?['position']?['lat']?.toString() ?? '');
    final lngController = TextEditingController(text: train?['position']?['lng']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(train == null ? 'Ajouter un Train' : 'Modifier le Train'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: numController,
                decoration: InputDecoration(labelText: 'Numéro du train'),
              ),
              TextField(
                controller: lineController,
                decoration: InputDecoration(labelText: 'ID de la ligne'),
              ),
              TextField(
                controller: statusController,
                decoration: InputDecoration(labelText: 'Statut'),
              ),
              TextField(
                controller: latController,
                decoration: InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: lngController,
                decoration: InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'numtrain': numController.text,
                'lineId': lineController.text,
                'status': statusController.text,
                'lastUpdated': FieldValue.serverTimestamp(),
                'position': {
                  'lat': double.tryParse(latController.text) ?? 0.0,
                  'lng': double.tryParse(lngController.text) ?? 0.0,
                }
              };

              if (train == null) {
                await trainRef.add(data);
              } else {
                await trainRef.doc(train.id).update(data);
              }

              Navigator.pop(context);
            },
            child: Text(train == null ? 'Ajouter' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestion des Trains'), backgroundColor: Color(0xFFB3CDE0),),
      body: StreamBuilder<QuerySnapshot>(
        stream: trainRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final trains = snapshot.data!.docs;

          if (trains.isEmpty) {
            return Center(child: Text("Aucun train trouvé."));
          }

          return ListView.builder(
            itemCount: trains.length,
            itemBuilder: (context, index) {
              final train = trains[index];
              final data = train.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('${data['numtrain'] ?? 'Train inconnu'}'),
                  onTap: () => showTrainDetails(data),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => showTrainForm(train: train),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Confirmer la suppression"),
                              content: Text("Supprimer ce train ?"),
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
                            await trainRef.doc(train.id).delete();
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
        onPressed: () => showTrainForm(),
        child: Icon(Icons.add),
        backgroundColor: Color(0xFFB3CDE0),
      ),
    );
  }
}
