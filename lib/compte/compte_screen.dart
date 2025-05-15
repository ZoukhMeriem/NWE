import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'user_info_page.dart';
import 'settings_page.dart';
import 'support_page.dart';
import 'HoraireTrainPage.dart';
import 'logout_helper.dart';
import 'historique_trajets_page.dart';

// Ajoute l'import des localisations générées (exemple avec flutter gen-l10n)
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  final Color primaryColor = const Color(0xFF1E1E1E);// couleur principale
  final List<Color> gradientColors = [
    Color(0x998BB1FF),// vert doux
    Color(0xFFF4D9DE),   // rose clair
    Color(0xFFDDD7E8),   // lavande
  ];

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

    // Recharge l'application avec le thème mis à jour
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MyApp(
          onboardingSeen: true,
          isLoggedIn: true,
          username: widget.username,
          isDarkMode: isDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x99D2E5FD),
                  Color(0xFFF4D9DE),
                  Color(0xFFDDD7E8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          centerTitle: true,
          title: Text(
            loc.profile_page_title, // "Mon profil"
            style: TextStyle(
              color: Color(0xFF1E1E1E),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          _buildHeader(loc),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildListTile(Icons.person, loc.personal_info_tile, () {
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
                    title: Text(loc.dark_mode_tile),
                    value: _isDark,
                    onChanged: (value) {
                      setState(() {
                        _isDark = value;
                      });
                      toggleTheme(value);
                    },
                    secondary: Icon(Icons.dark_mode, color: primaryColor),
                  ),
                  _buildListTile(Icons.settings, loc.settings_tile, () {
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
                  _buildListTile(Icons.notifications, loc.notifications_tile, () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(loc.profile_notifications + " à venir.")),
                    );
                  }),
                  _buildListTile(Icons.history, loc.history_tile, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoriqueTrajetsPage()),
                    );
                  }),
                  _buildListTile(Icons.train, loc.train_schedule_tile, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HoraireTrainPage()),
                    );
                  }),
                  _buildListTile(Icons.help_outline, loc.support_tile, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SupportPage()),
                    );
                  }),
                  const Divider(),
                  _buildListTile(Icons.logout, loc.logout_tile, () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          loc.logout_dialog_title,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        content: Text(loc.logout_dialog_message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(loc.logout_cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(loc.logout_confirm),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await logout(context);
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

  Widget _buildHeader(AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/logo3.png'),
          ),
          const SizedBox(height: 10),
          Text(
            userData?['username'] ?? loc.profile_username,
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            userData?['email'] ?? loc.profile_email,
            style: TextStyle(
              color: Color(0xFF1E1E1E),
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
