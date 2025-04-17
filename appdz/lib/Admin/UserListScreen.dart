import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance
        .collection('User')
        .orderBy('username'); // tri alphabétique

    return Scaffold(
      appBar: AppBar(title: Text('Liste des Utilisateurs')),
      body: Column(
        children: [
          // 🔍 Barre de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par username...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // 📄 Liste des utilisateurs
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: usersRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                final users = snapshot.data!.docs.where((doc) {
                  final username =
                  (doc['username'] ?? '').toString().toLowerCase();
                  return username.contains(searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return Center(child: Text('Aucun utilisateur trouvé.'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text("${user['nom']} ${user['prenom']}"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserDetailsScreen(user: user),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
class UserDetailsScreen extends StatelessWidget {
  final QueryDocumentSnapshot user;

  UserDetailsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    final data = user.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text("Détails de l'utilisateur")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nom : ${data['nom']}"),
            Text("Prénom : ${data['prenom']}"),
            Text("Email : ${data['email']}"),
            Text("Username : ${data['username']}"),
            Text("Sexe : ${data['sexe']}"),
            Text("Emploi : ${data['emploi']}"),
            Text("Mot de passe: ${user['password']}"),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.delete, color: Colors.white),
              label: Text("Supprimer"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                bool confirm = await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Confirmation"),
                    content:
                    Text("Voulez-vous vraiment supprimer cet utilisateur ?"),
                    actions: [
                      TextButton(
                        child: Text("Annuler"),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                      ElevatedButton(
                        child: Text("Supprimer"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ],
                  ),
                );

                if (confirm) {
                  await FirebaseFirestore.instance
                      .collection('User')
                      .doc(user.id)
                      .delete();
                  Navigator.pop(context); // retour à la liste
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
