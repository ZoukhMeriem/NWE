import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('User');

    return Scaffold(
      appBar: AppBar(title: Text('Liste des Utilisateurs'), backgroundColor: Colors.indigo),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return Center(child: Text("Aucun utilisateur trouvé"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final data = user.data() as Map<String, dynamic>;

              return ListTile(
                title: Text(data['username'] ?? 'Sans nom'),
                subtitle: Text(data['email'] ?? 'Pas d\'email'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await usersRef.doc(user.id).delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
