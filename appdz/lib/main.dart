import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:dztrainfay/CreatePasswordScreen.dart';
import 'package:dztrainfay/ForgotPasswordScreen.dart';
import 'package:dztrainfay/PasswordChangedScreen.dart';
import 'package:dztrainfay/SignInScreen.dart';
import 'package:dztrainfay/SignUpScreen.dart';
import 'package:dztrainfay/VerifyEmailScreen.dart';
import 'package:dztrainfay/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

  runApp(MyApp(onboardingSeen: onboardingSeen));
}

class MyApp extends StatelessWidget {
  final bool onboardingSeen;

  MyApp({required this.onboardingSeen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: onboardingSeen ? SignInScreen() : OnboardingScreen(),
      routes: {
        '/login': (context) => SignInScreen(), // Ajout de route pour déconnexion
        '/signup': (context) => RegisterPage(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/verify-email': (context) => VerifyEmailScreen(
          verificationCode: 0,
          email: '',
        ),
        '/create-password': (context) => CreatePasswordScreen(),
        '/password-changed': (context) => PasswordChangedScreen(),
      },
    );
  }
}

// ✅ Fonction de déconnexion
Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
}

// ✅ Fonction de suppression de compte
Future<void> deleteAccount(BuildContext context, String userId) async {
  try {
    await FirebaseFirestore.instance.collection('User').doc(userId).delete();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Compte supprimé avec succès')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur lors de la suppression du compte')),
    );
  }
}
