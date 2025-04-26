import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
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
    loadThemePreference();
  }

  void loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDark = prefs.getBool('isDarkMode') ?? false;
    });
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

  void toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);

    setState(() {
      _isDark = isDark;
    });

    SwitchListTile(
      title: Text('🌙 Mode sombre'),
      value: _isDark,
      onChanged: (value) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', value);

        setState(() {
          _isDark = value;
        });

        // 🔁 Recharge l'application avec le thème mis à jour
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MyApp(
              onboardingSeen: true,
              isLoggedIn: true,
              username: widget.username,
              isDarkMode: value,
            ),
          ),
        );
      },
      secondary: Icon(Icons.brightness_6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // backgroundColor: Colors.grey[200],
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,

               //color: Colors.white,
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

                  SwitchListTile(
                    title: Text('Mode sombre'),
                    value: _isDark,
                    onChanged: (value) {
                      setState(() {
                        _isDark = value;
                      });
                      toggleTheme(value);
                    },
                    secondary: Icon(Icons.dark_mode),
                  ),



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
                 // _buildListTile(Icons.logout, 'Déconnexion', () {
                   // LogoutHelper.showLogoutDialog(context);

                    _buildListTile(Icons.logout, 'Déconnexion', () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            "Déconnexion",
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          content: Text("Voulez-vous vraiment vous déconnecter ?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text("Annuler"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text("Déconnexion"),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await logout(context); // ✅ ici on applique la mise à jour du loggedIn à false
                      }
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
