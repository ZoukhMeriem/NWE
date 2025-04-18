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
import 'package:dztrainfay/HomePage.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();

  final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String username = prefs.getString('username') ?? 'Utilisateur';

  runApp(MyApp(
    onboardingSeen: onboardingSeen,
    isLoggedIn: isLoggedIn,
    username: username,
  ));
}

class MyApp extends StatelessWidget {
  final bool onboardingSeen;
  final bool isLoggedIn;
  final String username;

  MyApp({
    required this.onboardingSeen,
    required this.isLoggedIn,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    // 🔒 On ne fait confiance qu'à SharedPreferences
    Widget startScreen;

    if (!onboardingSeen) {
      startScreen = OnboardingScreen(); // première ouverture
    } else if (isLoggedIn) {
      startScreen = HomePage(username: username); // ✅ utilisateur connecté (contrôlé par toi)
    } else {
      startScreen = SignInScreen(); // 🔐 pas connecté
    }

    return MaterialApp(
      title: 'DZ Train App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: startScreen,
      routes: {
        '/login': (context) => SignInScreen(),
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

// ✅ Déconnexion complète et sécurisée
Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();

  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
}

// ✅ Suppression de compte (optionnelle)
Future<void> deleteAccount(BuildContext context, String userId) async {
  try {
    await FirebaseFirestore.instance.collection('User').doc(userId).delete();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

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
