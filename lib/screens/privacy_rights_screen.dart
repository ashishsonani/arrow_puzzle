import 'package:flutter/material.dart';

class PrivacyRightsScreen extends StatelessWidget {
  const PrivacyRightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF4CAF50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Rights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Rights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'We care about your privacy and are committed to helping you manage your privacy rights. The settings you choose can be changed at any time. To learn more about how we use your data and our commitment towards protecting your privacy, visit our Privacy Policy.',
              style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 25),
            const Text(
              'Manage Data Rights',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'To manage your preferences, request a copy of data collected from this device, request data be deleted, or make any other request regarding your data, such as restrict processing you the fullest extent, click on the relevant button.',
              style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 25),
            const Text(
              'Personalized Experience',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Providing your consent will help us keep our app free and it also means that the ads you see are tailored to your interests, general location, device or advertising identifiers, and other demographic information. It also helps us improve our games, understand our user\'s engagement, and identify areas where we can create a better experience for our users. To control this, tap on Privacy Preferences, otherwise tap on Learn More to see more information about our purposes, our partners, your rights, and how to contact us. Your choice will not affect the number of ads you see, only their relevance.',
              style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
