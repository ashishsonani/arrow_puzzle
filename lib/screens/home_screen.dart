import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'daily_challenges_screen.dart';
import 'me_screen.dart';
import 'game_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ad_manager.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int currentLevel = 1;
  Key _dailyKey = UniqueKey();

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadLevel();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = AdManager.createBannerAd(() {
      setState(() {
        _isBannerAdLoaded = true;
      });
    });
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadLevel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentLevel = prefs.getInt('current_level') ?? 1;
    });
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      _dailyKey = UniqueKey();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Stack(
            children: [
          // Main Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Daily Challenge Card - High Level Professional Design
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onTap: () {
                      final now = DateTime.now();
                      int levelSeed = now.year * 10000 + now.month * 100 + now.day;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            initialLevel: levelSeed,
                            isDailyChallenge: true,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616), // Subtle dark gray
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Icon Container
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              color: Color(0xFF4CAF50),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Texts
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DAILY CHALLENGE',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][DateTime.now().month - 1]} ${DateTime.now().day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Play Button
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Title Group
                Column(
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: 'Draw',
                            style: TextStyle(color: Colors.white), // Dark color
                          ),
                          TextSpan(
                            text: 'Link',
                            style: TextStyle(color: Color(0xFF4CAF50)), // Soft green
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Left line with dot
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 30,
                              height: 2,
                              color: const Color(0xFF4CAF50),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'ONE LINE. SOLVE IT.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Right line with dot
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 2,
                              color: const Color(0xFF4CAF50),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // New Game Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameScreen(initialLevel: currentLevel)),
                      );
                      _loadLevel(); // Refresh level when coming back
                    },
                    child: Container(
                      width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6), // Further reduced vertical padding
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50), // Soft green
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'New Game',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Level $currentLevel',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
      // Daily Tab
      DailyChallengesScreen(key: _dailyKey),
      // Me Tab
      const MeScreen(),
    ],
  ),
  bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isBannerAdLoaded && _bannerAd != null)
            SafeArea(
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          BottomNavigationBar(
            backgroundColor: Colors.black,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF4CAF50),
            unselectedItemColor: Colors.grey.shade500,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Main',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: 'Daily',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Me',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper for simple gradient
class LinearOverlay extends LinearGradient {
  const LinearOverlay({
    required super.colors,
    super.begin,
    super.end,
  });
}
