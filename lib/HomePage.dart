import 'package:flutter/material.dart';
import 'package:dztrainfay/SignInScreen.dart';
import 'package:dztrainfay/compte/compte_screen.dart';
import 'package:dztrainfay/home_screen.dart';
import 'package:dztrainfay/chat_screen.dart'; // 🔥 Import du Chat

class HomePage extends StatefulWidget {
  final String username;
  HomePage({required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(),
      ProfilePage(
        username: widget.username,
        toggleTheme: (isDark) {
          // Implémentation de la gestion du mode sombre
          print('Theme toggled: $isDark');
        },
        changeLanguage: (language) {
          // Implémentation du changement de langue
          print('Language changed to: $language');
        },
        toggleNotifications: (isEnabled) {
          // Implémentation de la gestion des notifications
          print('Notifications toggled: $isEnabled');
        },
      ),


      ChatScreen(), // 🔥 Ajout du Chat

    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _pages[_selectedIndex], // 🔥 Affiche la page sélectionnée
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Compte"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
        ],
      ),
    );
  }
}