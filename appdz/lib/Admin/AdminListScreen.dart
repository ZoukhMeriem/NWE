
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final adminsRef = FirebaseFirestore.instance.collection('Admin');

    return Scaffold(
      appBar: AppBar(title: Text('Liste des Admins')),
      body: StreamBuilder<QuerySnapshot>(
        stream: adminsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final admins = snapshot.data!.docs;

          return ListView.builder(
            itemCount: admins.length,
            itemBuilder: (context, index) {
              final admin = admins[index];
              return ListTile(
                title: Text(admin['Username']),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await adminsRef.doc(admin.id).delete();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tu peux ajouter une logique pour afficher un formulaire d’ajout
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
