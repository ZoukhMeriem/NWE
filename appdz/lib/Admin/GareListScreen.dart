import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GareManagementScreen extends StatefulWidget {
  @override
  _GareManagementScreenState createState() => _GareManagementScreenState();
}

class _GareManagementScreenState extends State<GareManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _gares = [];
  List<DocumentSnapshot> _filteredGares = [];
  List<DocumentSnapshot> _lignes = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final gareSnapshot =
    await FirebaseFirestore.instance.collection('Gare').get();
    final ligneSnapshot =
    await FirebaseFirestore.instance.collection('LIGNE').get();

    setState(() {
      _gares = gareSnapshot.docs;
      _filteredGares = _gares;
      _lignes = ligneSnapshot.docs;
    });
  }

  void _filterGares(String query) {
    setState(() {
      _filteredGares = _gares
          .where((gare) => gare['name']
          .toString()
          .toLowerCase()
          .contains(query.toLowerCase()))
          .toList();
    });
  }

  String _getLigneName(String id) {
    try {
      final ligne = _lignes.firstWhere((ligne) => ligne.id == id);
      return ligne['nom'];
    } catch (e) {
      return id; // ou "Inconnue"
    }
  }


  void _showGareDetails(DocumentSnapshot gare) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(gare['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${gare['id']}'),
            Text(
                'Lignes: ${(gare['lineId'] as List).map((id) => _getLigneName(id)).join(', ')}'),
            Text('Latitude: ${gare['location']['lat']}'),
            Text('Longitude: ${gare['location']['lng']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showEditGareDialog(DocumentSnapshot gare) {
    final nameController = TextEditingController(text: gare['name']);
    final _latController =
    TextEditingController(text: gare['location']['lat'].toString());
    final _lngController =
    TextEditingController(text: gare['location']['lng'].toString());
    List<String> selectedLines = List<String>.from(gare['lineId']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Modifier la gare",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _lngController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              const Text("Sélectionnez les lignes :"),
              ..._lignes.map((ligne) {
                final id = ligne.id;
                final nom = ligne['nom'];
                return CheckboxListTile(
                  title: Text(nom),
                  value: selectedLines.contains(id),
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        selectedLines.add(id);
                      } else {
                        selectedLines.remove(id);
                      }
                    });
                  },
                );
              }).toList(),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      _latController.text.isEmpty ||
                      _lngController.text.isEmpty ||
                      selectedLines.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Veuillez remplir tous les champs")),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection('Gare')
                      .doc(gare.id)
                      .update({
                    'name': nameController.text,
                    'location': {
                      'lat': double.tryParse(_latController.text) ?? 0,
                      'lng': double.tryParse(_lngController.text) ?? 0
                    },
                    'lineId': selectedLines
                  });
                  Navigator.pop(context);
                  _fetchData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gare modifiée avec succès")),
                  );
                },
                child: const Text("Enregistrer"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showAddGareDialog() {
    final nameController = TextEditingController();
    final _latController = TextEditingController();
    final _lngController = TextEditingController();
    List<String> selectedLines = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text("Ajouter une nouvelle gare",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _lngController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              const Text("Sélectionnez les lignes :"),
              ..._lignes.map((ligne) {
                final id = ligne.id;
                final nom = ligne['nom'];
                return CheckboxListTile(
                  title: Text(nom),
                  value: selectedLines.contains(id),
                  onChanged: (value) {
                    setState(() {
                      if (value!) {
                        selectedLines.add(id);
                      } else {
                        selectedLines.remove(id);
                      }
                    });
                  },
                );
              }).toList(),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty ||
                      _latController.text.isEmpty ||
                      _lngController.text.isEmpty ||
                      selectedLines.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Veuillez remplir tous les champs")),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance.collection('Gare').add({
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'name': nameController.text,
                    'location': {
                      'lat': double.tryParse(_latController.text) ?? 0,
                      'lng': double.tryParse(_lngController.text) ?? 0
                    },
                    'lineId': selectedLines
                  });
                  Navigator.pop(context);
                  _fetchData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Gare ajoutée avec succès")),
                  );
                },
                child: const Text("Ajouter"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _deleteGare(DocumentSnapshot gare) async {
    await FirebaseFirestore.instance.collection('Gare').doc(gare.id).delete();
    _fetchData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gare supprimée")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Gares'),
          backgroundColor: Color(0xFFA7C7E7)
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Rechercher une gare',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterGares,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredGares.length,
              itemBuilder: (context, index) {
                final gare = _filteredGares[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(gare['name']),

                    onTap: () => _showGareDetails(gare),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            _showEditGareDialog(gare);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteGare(gare['name']);
                          },
                        ),
                      ],
                    ),

                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGareDialog,
        child: const Icon(Icons.add),
        backgroundColor: Color(0xFFB3CDE0), // Bleu pastel
      ),
    );
  }
}
