import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'lost_object_status_screen.dart';

// Remplacer ici avec la couleur que tu utilises
const Color mainColor = Color(0x998BB1FF); // Remplacée par la couleur demandée

class LostObjectFormScreen extends StatefulWidget {
  @override
  _LostObjectFormScreenState createState() => _LostObjectFormScreenState();
}

class _LostObjectFormScreenState extends State<LostObjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _trainLineController = TextEditingController();
  final TextEditingController _trainNumberController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child("lost_objects/$fileName.jpg");
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("❌ Erreur lors de l'upload de l'image : $e");
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      await FirebaseFirestore.instance.collection('lost_objects').add({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'trainLine': _trainLineController.text,
        'trainNumber': _trainNumberController.text,
        'date': _dateController.text,
        'imageUrl': imageUrl,
        'status': 'En cours de traitement',
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Objet signalé avec succès !")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Nom de l'objet", Icons.business, _nameController, true),
              SizedBox(height: 15),
              _buildTextField("Description", Icons.description, _descriptionController, true),
              SizedBox(height: 15),
              _buildTextField("Ligne de train (optionnel)", Icons.train, _trainLineController, false),
              SizedBox(height: 15),
              _buildTextField("Numéro du train (optionnel)", Icons.confirmation_number, _trainNumberController, false),
              SizedBox(height: 15),

              // 🔹 Date Picker
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: "Date et heure",
                  prefixIcon: Icon(Icons.calendar_today, color:Colors.black87),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2030),
                  );
                  if (pickedDate != null) {
                    _dateController.text = pickedDate.toString().split(" ")[0];
                  }
                },
              ),

              SizedBox(height: 20),

              // 🔹 Bouton pour ajouter une image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:Colors.black87.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color:Colors.black87),
                      SizedBox(width: 8),
                      Text("Ajouter une photo", style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                ),
              ),

              if (_image != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Image.file(_image!, height: 150, fit: BoxFit.cover),
                ),

              SizedBox(height: 20),

              // 🔹 Bouton envoyer plus compact
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text("Envoyer", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),

              SizedBox(height: 10),

              // 🔹 Lien vers l'état des objets perdus plus optimisé
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LostObjectStatusScreen()));
                  },
                  child: Text("Consulter les objets perdus", style: TextStyle(color:Colors.black87, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, bool required) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color:Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: required
          ? (value) {
        if (value == null || value.isEmpty) {
          return "Ce champ est obligatoire";
        }
        return null;
      }
          : null,
    );
  }
}
