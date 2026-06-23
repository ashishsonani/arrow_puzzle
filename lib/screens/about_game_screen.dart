import 'package:flutter/material.dart';
import 'generic_article_screen.dart';

class AboutGameScreen extends StatelessWidget {
  const AboutGameScreen({super.key});

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

  Widget _buildListTile(String title, {VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'About Game',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // Header Card
          _buildCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: const DecorationImage(
                        image: AssetImage('assets/puzzle logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Arrow Puzzle',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Version 1.6.0',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '© 2025-2026 Easybrain Ltd.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          'All rights reserved.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Links Group 2
          _buildCard(
            child: Column(
              children: [
                _buildListTile(
                  'Terms of Service',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericArticleScreen(
                      title: 'Terms of Service',
                      children: [
                        Text('Last updated: [Current Date]', style: TextStyle(fontSize: 14, color: Colors.white54)),
                        SizedBox(height: 20),
                        Text('1. Acceptance of Terms', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('By accessing or using the Arrow Puzzle application, you agree to be bound by these Terms of Service. If you do not agree, please do not use the application.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                        SizedBox(height: 20),
                        Text('2. User Conduct', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('You agree to use the application for lawful purposes only and in a way that does not infringe the rights of or restrict anyone else\'s use of the app.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                        SizedBox(height: 20),
                        Text('3. Intellectual Property', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('All content included in this application, such as text, graphics, logos, and images, is the property of the developer and is protected by copyright laws.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                        SizedBox(height: 20),
                        Text('4. Modifications to Terms', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('We reserve the right to modify these terms at any time. Your continued use of the application following any changes indicates your acceptance of the new terms.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      ],
                    )));
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                _buildListTile(
                  'Privacy Policy',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericArticleScreen(
                      title: 'Privacy Policy',
                      children: [
                        Text('Last updated: [Current Date]', style: TextStyle(fontSize: 14, color: Colors.white54)),
                        SizedBox(height: 20),
                        Text('1. Information Collection', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('We collect information from you when you use our app, including device information, gameplay data, and crash reports. This data is collected to improve your experience.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                        SizedBox(height: 20),
                        Text('2. Use of Information', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('The information we collect may be used to personalize your experience, improve our application, or provide customer service and support.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                        SizedBox(height: 20),
                        Text('3. Data Security', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('We implement a variety of security measures to maintain the safety of your personal information when you access our application.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                        SizedBox(height: 20),
                        Text('4. Third-Party Services', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('We may use third-party services that collect, monitor, and analyze data to help improve our app\'s functionality and advertising relevance.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      ],
                    )));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
