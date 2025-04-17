import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminListScreen extends StatelessWidget {
  final CollectionReference adminsRef =
  FirebaseFirestore.instance.collection('Admin');

  void _showAddAdminDialog(BuildContext context) {
    final TextEditingController nomController = TextEditingController();
    final TextEditingController prenomController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ajouter un admin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomController, decoration: InputDecoration(labelText: "Nom")),
            TextField(controller: prenomController, decoration: InputDecoration(labelText: "Prénom")),
            TextField(controller: usernameController, decoration: InputDecoration(labelText: "Nom d'utilisateur")),
            TextField(controller: passwordController, obscureText: true, decoration: InputDecoration(labelText: "Mot de passe")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              final nom = nomController.text.trim();
              final prenom = prenomController.text.trim();
              final username = usernameController.text.trim();
              final password = passwordController.text.trim();

              if (nom.isNotEmpty && prenom.isNotEmpty && username.isNotEmpty && password.isNotEmpty) {
                await adminsRef.add({
                  'Nom': nom,
                  'Prénom': prenom,
                  'Username': username,
                  'Password': password,
                });
                Navigator.pop(context);
              }
            },
            child: Text("Ajouter"),
          ),
        ],
      ),
    );
  }


  void _showAdminDetailsDialog(BuildContext context, DocumentSnapshot adminDoc) {
    final data = adminDoc.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Informations de l'admin"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nom : ${data['Nom']}"),
            Text("Prénom : ${data['Prénom']}"),
            Text("Nom d'utilisateur : ${data['Username']}"),
            Text("Mot de passe : ${data['Password']}"),
            Text("Email : ${data['Email']}"),

            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Fermer cette boîte
                _showDeleteConfirmation(context, adminDoc.id);
              },
              icon: Icon(Icons.delete, color: Colors.white),
              label: Text("Supprimer", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            )
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

  void _showDeleteConfirmation(BuildContext context, String adminId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmer la suppression"),
        content: Text("Voulez-vous vraiment supprimer cet admin ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              await adminsRef.doc(adminId).delete();
              Navigator.pop(context);
            },
            child: Text("Supprimer"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              final data = admin.data() as Map<String, dynamic>;
              final nom = data['Nom'] ?? '';
              final prenom = data['Prénom'] ?? '';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: ListTile(
                    title: Text("$nom $prenom"),
                    onTap: () => _showAdminDetailsDialog(context, admin),
                  ),
                ),
              );
            },
          );


        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAdminScreen()),
          );
        },
        child: Icon(Icons.add),
      ),

    );
  }
}



//add admin
class AddAdminScreen extends StatefulWidget {
  @override
  _AddAdminScreenState createState() => _AddAdminScreenState();
}

class _AddAdminScreenState extends State<AddAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _addAdmin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('Admin').add({
          'Prénom': _prenomController.text.trim(),
          'Nom': _nomController.text.trim(),
          'Username': _usernameController.text.trim(),
          'Email': _emailController.text.trim(),
          'Password': _passwordController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Administrateur ajouté avec succès')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter un admin")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) =>
                value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
                validator: (value) =>
                value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Champ obligatoire';
                  } else if (!value.endsWith('@gmail.com')) {
                    return 'Email doit se terminer par @gmail.com';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) =>
                value!.isEmpty ? 'Champ obligatoire' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addAdmin,
                child: Text('Ajouter l\'admin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
