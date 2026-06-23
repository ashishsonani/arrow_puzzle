import 'package:flutter/material.dart';
import 'awards_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'about_game_screen.dart';
import 'privacy_rights_screen.dart';
import 'advertising_preferences_screen.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  Widget _buildListTile({
    String? imagePath,
    IconData? icon,
    required Color iconColor,
    required String title,
    bool showTrailing = true,
    double imageSize = 50.0,
    double translateX = 0.0,
    VoidCallback? onTap,
  }) {
    Widget leadingContent;

    if (imagePath != null) {
      leadingContent = Transform.translate(
        offset: Offset(translateX, 0),
        child: Image.asset(
          imagePath,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.contain,
        ),
      );
    } else {
      leadingContent = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      );
    }

    Widget leadingWidget = SizedBox(
      width: 50,
      height: 50,
      child: Center(
        child: leadingContent,
      ),
    );

    return ListTile(
      leading: leadingWidget,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: showTrailing
          ? const Icon(Icons.chevron_right, color: Colors.white38)
          : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Me',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 40),
        children: [
          // Awards
          _buildCard(
            child: SizedBox(
              height: 80, // Increased height
              child: Center(
                child: _buildListTile(
                  imagePath: 'assets/me1.png',
                  iconColor: Colors.amber,
                  title: 'Awards',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AwardsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Settings
          _buildCard(
            child: _buildListTile(
              icon: Icons.settings,
              iconColor: const Color(0xFF4CAF50),
              title: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),

          // Grouped Items
          _buildCard(
            child: Column(
              children: [
                _buildListTile(
                  icon: Icons.help_center,
                  iconColor: Colors.green,
                  title: 'Help',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.white12, height: 1, indent: 60),
                _buildListTile(
                  icon: Icons.info,
                  iconColor: const Color(0xFF4CAF50),
                  title: 'About Game',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutGameScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.white12, height: 1, indent: 60),
                _buildListTile(
                  icon: Icons.assignment_turned_in,
                  iconColor: Colors.purpleAccent,
                  title: 'Privacy Rights',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyRightsScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: Colors.white12, height: 1, indent: 60),
                _buildListTile(
                  icon: Icons.privacy_tip,
                  iconColor: Colors.tealAccent,
                  title: 'Privacy Preferences',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdvertisingPreferencesScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Remove Ads
          _buildCard(
            child: _buildListTile(
              icon: Icons.money_off,
              iconColor: Colors.redAccent,
              title: 'Remove Ads',
              showTrailing: false,
            ),
          ),
        ],
      ),
    );
  }
}
