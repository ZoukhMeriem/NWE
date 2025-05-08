import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'CreatePasswordScreen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String verificationCode;
  final String email;

  VerifyEmailScreen({required this.verificationCode, required this.email});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyCode() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('PasswordResetCodes')
          .doc(widget.email)
          .get();

      if (doc.exists) {
        String savedCode = doc['code'];

        if (savedCode == codeController.text.trim()) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePasswordScreen(email: widget.email),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Code incorrect.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : code introuvable.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification du code",
          style: TextStyle(fontSize: 24, color: Colors.black87),
        ),
        backgroundColor: Color(0x998BB1FF),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0x998BB1FF),
              Color(0xFFF4D9DE),
              Color(0xFFDDD7E8),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.verified_user_rounded, size: 80, color: Colors.black87),
              const SizedBox(height: 20),
              const Text(
                'Vérifiez votre e-mail',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Un code a été envoyé à :',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                widget.email,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F51B5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Entrez le code de vérification',
                  labelStyle: const TextStyle(color: Colors.black),
                  prefixIcon: const Icon(Icons.pin, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0x998BB1FF)),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.95),
                ),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                onPressed: verifyCode,
                icon: const Icon(Icons.verified, color: Colors.white),
                label: const Text(
                  'Vérifier',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0x998BB1FF),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
