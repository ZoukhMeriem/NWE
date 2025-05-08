import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';
import 'change_password_page.dart';
import 'delete_account_page.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(String) changeLanguage;
  final Function(bool) toggleTheme;
  final Function(bool) toggleNotifications;
  final String selectedLanguage;
  final bool isDarkMode;

  const SettingsPage({
    super.key,
    required this.userData,
    required this.changeLanguage,
    required this.toggleTheme,
    required this.toggleNotifications,
    required this.selectedLanguage,
    required this.isDarkMode,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool isDarkMode;
  bool areNotificationsEnabled = true;

  final Color primaryColor = const Color(0xFF998BB1FF);

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void changeLanguage(String language) {
    widget.changeLanguage(language);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("⚙️ Paramètres", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserCard(user),
            const SizedBox(height: 24),
            _buildSettingsSection("Compte", [
              _buildTile(Icons.edit, "Modifier le profil", onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => EditProfilePage(userData: widget.userData),
                ));
              }),
              _buildTile(Icons.lock, "Changer le mot de passe", onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ChangePasswordPage(userId: user['id']),
                ));
              }),
              _buildTile(Icons.delete_forever, "Supprimer mon compte", onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => DeleteAccountPage(userId: user['id']),
                ));
              }),
            ]),
            const SizedBox(height: 24),
            _buildSettingsSection("Préférences", [
              _buildTile(Icons.language, "Changer la langue", subtitle: widget.selectedLanguage, onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Choisir une langue"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLangTile("Français", 'fr'),
                        _buildLangTile("English", 'en'),
                        _buildLangTile("العربية", 'ar'),
                      ],
                    ),
                  ),
                );
              }),
              SwitchListTile(
                secondary: Icon(Icons.dark_mode, color: Colors.black87),
                title: const Text("Mode sombre", style: TextStyle(fontWeight: FontWeight.w500)),
                value: isDarkMode,
                activeColor: primaryColor,
                onChanged: (value) async {
                  setState(() => isDarkMode = value);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isDark', value);
                  widget.toggleTheme(value);
                },
              ),
              SwitchListTile(
                secondary: Icon(Icons.notifications_active, color: Colors.black87),
                title: const Text("Notifications", style: TextStyle(fontWeight: FontWeight.w500)),
                value: areNotificationsEnabled,
                activeColor: primaryColor,
                onChanged: (value) {
                  setState(() => areNotificationsEnabled = value);
                  widget.toggleNotifications(value);
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      color: Theme.of(context).cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: primaryColor,
          child: const Icon(Icons.person, color: Colors.white, size: 28),
        ),
        title: Text(
          "${user['prenom'] ?? ''} ${user['nom'] ?? ''}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(user['email'] ?? '', style: const TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey)) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLangTile(String label, String code) {
    return ListTile(
      title: Text(label),
      onTap: () {
        changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        )),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          color: Theme.of(context).cardColor,
          child: Column(
            children: tiles.map((tile) => Column(
              children: [
                tile,
                if (tile != tiles.last) const Divider(height: 1),
              ],
            )).toList(),
          ),
        ),
      ],
    );
  }
}
