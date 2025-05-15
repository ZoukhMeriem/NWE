import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:dztrainfay/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final String username = prefs.getString('username') ?? 'Utilisateur';
  final bool isDarkMode = prefs.getBool('isDarkMode') ?? false;

  bool loggedIn = false;
  await prefs.setString('username', username);
  await prefs.setBool('isLoggedIn', true);

  if (username.isNotEmpty) {
    final doc = await FirebaseFirestore.instance
        .collection('CompteUser')
        .doc(username)
        .get();

    if (doc.exists) {
      loggedIn = doc['loggedIn'] ?? false;
    }
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: MyApp(
        onboardingSeen: onboardingSeen,
        isLoggedIn: loggedIn,
        username: username,
        isDarkMode: isDarkMode,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool onboardingSeen;
  final bool isLoggedIn;
  final String username;
  final bool isDarkMode;

  MyApp({
    required this.onboardingSeen,
    required this.isLoggedIn,
    required this.username,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    Widget startScreen;
    final provider = Provider.of<LocaleProvider>(context);

    if (!onboardingSeen) {
      startScreen = OnboardingScreen();
    } else if (isLoggedIn) {
      startScreen = HomePage(username: username);
    } else {
      startScreen = SignInScreen();
    }

    return MaterialApp(
      title: 'DzTrain',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: provider.locale,
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('ar'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      theme: ThemeData.light().copyWith(
        primaryColor: Color(0xFF353C67),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF353C67),
          foregroundColor: Colors.white,
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Color(0xFF353C67),
        scaffoldBackgroundColor: Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF353C67),
          foregroundColor: Colors.white,
        ),
        cardColor: Color(0xFF1E1E2E),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge:
          TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.blueGrey),
        listTileTheme: ListTileThemeData(
          iconColor: Colors.purpleAccent,
          textColor: Colors.white,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.purpleAccent),
          trackColor:
          MaterialStateProperty.all(Colors.purple.withOpacity(0.5)),
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: startScreen,
      routes: {
        '/login': (context) => SignInScreen(),
        '/signup': (context) => RegisterPage(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
        '/password-changed': (context) => PasswordChangedScreen(),
      },
    );
  }
}

// Déconnexion complète et sécurisée
Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final String username = prefs.getString('username') ?? '';

  try {
    if (username.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('CompteUser')
          .doc(username)
          .set({'loggedIn': false}, SetOptions(merge: true));

      print("✅ loggedIn mis à false pour $username");
    }
  } catch (e) {
    print("❌ Erreur lors de la mise à jour de loggedIn: $e");
  }

  await prefs.clear();
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();

  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
}

// Suppression de compte (optionnelle)
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
