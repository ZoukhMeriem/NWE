import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'user_info_page.dart';
import 'settings_page.dart';
import 'support_page.dart';
import 'HoraireTrainPage.dart';
import 'logout_helper.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final Function(bool) toggleTheme;
  final Function(String) changeLanguage;
  final Function(bool) toggleNotifications;

  const ProfilePage({
    required this.username,
    required this.toggleTheme,
    required this.changeLanguage,
    required this.toggleNotifications,
    Key? key,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, String>? userData;
  String _language = 'fr';
  bool _isDark = false;

  final Color primaryColor = const Color(0xFF353C67);

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('username', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var doc = snapshot.docs.first;
        setState(() {
          userData = {
            'id': doc.id,
            'username': doc['username'] ?? '',
            'email': doc['email'] ?? '',
            'nom': doc['nom'] ?? '',
            'prenom': doc['prenom'] ?? '',
            'emploi': doc['emploi'] ?? '',
            'sexe': doc['sexe'] ?? '',
          };
        });
      }
    } catch (e) {
      print("Erreur Firestore : $e");
    }
  }

  void changeLanguage(String language) {
    setState(() {
      _language = language;
    });
    widget.changeLanguage(language);
  }

  void toggleTheme(bool isDark) {
    setState(() {
      _isDark = isDark;
    });
    widget.toggleTheme(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Mon Compte'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildListTile(Icons.person, 'Informations personnelles', () {
                    if (userData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserInfoPage(userData: userData!),
                        ),
                      );
                    }
                  }),
                  _buildListTile(Icons.settings, 'Paramètres', () {
                    if (userData != null && userData!['username'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(
                            userData: userData!,
                            changeLanguage: widget.changeLanguage,
                            toggleTheme: widget.toggleTheme,
                            toggleNotifications: widget.toggleNotifications,
                            selectedLanguage: _language,
                            isDarkMode: _isDark,
                          ),
                        ),
                      );
                    }
                  }),
                  _buildListTile(Icons.notifications, 'Notifications', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notifications à venir.")),
                    );
                  }),
                  _buildListTile(Icons.history, 'Historique des trajets', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Historique en développement.")),
                    );
                  }),
                  _buildListTile(Icons.train, 'Horaires des trains', () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HoraireTrainPage()),
                    );
                  }),
                  _buildListTile(Icons.help_outline, 'Aide et support', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SupportPage()),
                    );
                  }),
                  const Divider(),
                  _buildListTile(Icons.logout, 'Déconnexion', () {
                    LogoutHelper.showLogoutDialog(context);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: primaryColor,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/logo3.png'),
          ),
          const SizedBox(height: 10),
          Text(
            userData?['username'] ?? "Nom inconnu",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            userData?['email'] ?? "Email inconnu",
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }
}
