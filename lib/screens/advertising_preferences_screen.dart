import 'package:flutter/material.dart';

class AdvertisingPreferencesScreen extends StatelessWidget {
  const AdvertisingPreferencesScreen({super.key});

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
          'Advertising Preferences',
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
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                children: [
                  TextSpan(text: 'To ensure you have a personalized experience in our app, we and our '),
                  TextSpan(text: 'Ad Networks and their Partners', style: TextStyle(color: Color(0xFF4CAF50))),
                  TextSpan(text: ' want to store and access certain information from your device. This includes the device\'s advertising identifiers, which help us keep our apps free, tailor advertising and content specifically for you, and measure their effectiveness. It\'s important for us to be transparent about how we use this data to enhance your app experience.'),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Personalized Advertising is ON',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Managing Your Privacy Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'You have control over how your information is used. To manage your privacy settings and disable the sharing of your personal information with our partners, such as your device\'s advertising identifier, please follow these steps:',
              style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 15),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                children: [
                  TextSpan(text: '1. Open the '),
                  TextSpan(text: 'Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: ' on your Android device.\n2. Navigate down and select either '),
                  TextSpan(text: 'Privacy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: ' or '),
                  TextSpan(text: 'Google', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: ' (depending on your device\'s operating system).\n    a. If you selected '),
                  TextSpan(text: 'Privacy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: ', now choose '),
                  TextSpan(text: 'Ads', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: '.\n    b. If you selected '),
                  TextSpan(text: 'Google', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: ', select '),
                  TextSpan(text: 'Ads', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: ' under the All Services section.\n3. Tap on '),
                  TextSpan(text: 'Reset Advertising ID / Delete Advertising ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextSpan(text: ' accordingly.'),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Your Choice Matters',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                children: [
                  TextSpan(text: 'Remember, you can change these settings at any time. Disabling the advertising identifier will not remove ads from your experience but will result in advertisements that are less relevant to you. Additionally, your choice will not affect the number of ads you see. For more information, please visit our '),
                  TextSpan(text: 'Privacy Policy.', style: TextStyle(color: Color(0xFF4CAF50))),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
