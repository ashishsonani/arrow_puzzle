import 'package:flutter/material.dart';
import 'my_tickets_screen.dart';
import 'contact_us_screen.dart';
import 'how_to_play_screen.dart';
import 'how_to_get_hint_screen.dart';
import 'generic_article_screen.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  bool _isHelpCenterExpanded = true;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  bool get _hasResults {
    if (_searchController.text.isEmpty) return true;
    final query = _searchController.text.toLowerCase();
    final titles = [
      'How do I play?',
      'How do I get a hint?',
      'What is Arrow Puzzle?',
      'How do I zoom in?',
      'How do I remove ads?',
      'What is the grid booster?',
      'What is a daily challenge?',
      'Can I change my Tournament name?',
      'Do you have Dark Mode?',
      'Having issues with ads?',
      'How do I delete my data and game progress?',
      'Privacy Rights and Options',
      'Privacy Rights and Options.'
    ];
    return titles.any((t) => t.toLowerCase().contains(query));
  }

  Widget _buildQuestionItem(String question, {VoidCallback? onTap}) {
    if (_searchController.text.isNotEmpty && !question.toLowerCase().contains(_searchController.text.toLowerCase())) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text(
                'Support',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.view_list, color: Color(0xFF4CAF50)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyTicketsScreen()),
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isHelpCenterExpanded = !_isHelpCenterExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Help Center',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  _isHelpCenterExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Color(0xFF4CAF50),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (_isHelpCenterExpanded) ...[
            if (_hasResults) _buildSectionHeader('FAQ'),
            if (!_hasResults)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off, color: Colors.white54, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'No articles found for "${_searchController.text}"',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            _buildQuestionItem(
              'How do I play?',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HowToPlayScreen()),
                );
              },
            ),
            _buildQuestionItem(
              'How do I get a hint?',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HowToGetHintScreen()),
                );
              },
            ),
            _buildQuestionItem(
              'What is Arrow Puzzle?',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericArticleScreen(
                  title: 'What is Arrow Puzzle?',
                  children: [
                    Text('Arrow Puzzle is a calming logic game where simple taps turn into a satisfying challenge. Your goal is to find free paths, tap arrows in the right order, and watch the cluttered grid become a clear, empty board. It\'s a gentle brain workout with no pressure—perfect for relaxing focus, spatial thinking, and a small daily ritual that feels like a mental reset.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                  ],
                )));
              },
            ),
            _buildQuestionItem(
              'How do I zoom in?',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericArticleScreen(
                  title: 'How do I zoom in?',
                  children: [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                        children: [
                          TextSpan(text: 'To zoom in on the puzzle, simply '),
                          TextSpan(text: 'use two fingers and pinch outward', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          TextSpan(text: ' on the screen. You can swipe with two fingers to adjust your view and get a closer look at the arrows.'),
                        ],
                      ),
                    ),
                  ],
                )));
              },
            ),
            _buildQuestionItem(
              'How do I remove ads?',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericArticleScreen(
                  title: 'How do I remove ads?',
                  children: [
                    Text('1. Tap Me in the bottom right corner', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                    SizedBox(height: 20),
                    Text('2. Tap Remove Ads and follow the instructions.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                  ],
                )));
              },
            ),
            _buildQuestionItem(
              'What is the grid booster?',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => GenericArticleScreen(
                  title: 'What is the grid booster?',
                  children: [
                    const Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                        children: [
                          TextSpan(text: 'The '),
                          TextSpan(text: 'Grid', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          TextSpan(text: ' booster is a '),
                          TextSpan(text: 'free, unlimited', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          TextSpan(text: ' helper that shows where arrows try to exit.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('• ', style: TextStyle(fontSize: 16, color: Colors.white70)),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                              children: [
                                TextSpan(text: 'Turn it on: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                TextSpan(text: 'Tap the Grid button to display arrow exit directions.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('• ', style: TextStyle(fontSize: 16, color: Colors.white70)),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                              children: [
                                TextSpan(text: 'After a correct move: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                TextSpan(text: 'The Grid '),
                                TextSpan(text: 'turns off automatically', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                TextSpan(text: ' and guiding lines disappear.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('• ', style: TextStyle(fontSize: 16, color: Colors.white70)),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                              children: [
                                TextSpan(text: 'After a mistake: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                TextSpan(text: 'If a move is wrong and an arrow turns red, its '),
                                TextSpan(text: 'path is highlighted in red', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                TextSpan(text: ' so you can see why it was blocked.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )));
              },
            ),

              _buildQuestionItem(
                'What is a daily challenge?',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericArticleScreen(
                    title: 'What is a daily challenge?',
                    children: [
                      Text('Every day, players receive a unique daily challenge. Complete daily challenges every day and win gold stars.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('If you complete all the daily challenges during a given month, you are rewarded with a trophy, the highest prize in the game. Each month, you can win a new unique trophy.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('Turn your notifications on so you never miss a daily challenge!', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                    ],
                  )));
                },
              ),
              _buildQuestionItem(
                'Can I change my Tournament name?',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericArticleScreen(
                    title: 'Can I change my Tournament name?',
                    children: [
                      Text('Tournament names are automatically generated and cannot be changed.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('On your screen, your name will appear as "Me" for easy recognition.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('Other players will see a randomly assigned name for you—just as you will see randomized names for them. This system ensures a fair and consistent experience for all players.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                    ],
                  )));
                },
              ),
              _buildQuestionItem(
                'Do you have Dark Mode?',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericArticleScreen(
                    title: 'Do you have Dark Mode?',
                    children: [
                      Text('At the moment, Dark Mode isn\'t available in the game.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 30),
                      Text('🌙 Playing at Night', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Text('If you prefer a softer screen while playing at night, your device may already include display settings that make the screen feel more comfortable to look at.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('• On iPhone and iPad, you can use Night Shift or Reduce White Point in your display and accessibility settings.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 15),
                      Text('• On Android devices, similar features may appear as Night Light, Eye Comfort Shield, Reading Mode, or Eye Comfort, depending on your device model.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('We appreciate your feedback and continue paying attention to the features players ask for most.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                    ],
                  )));
                },
              ),
              _buildQuestionItem(
                'Having issues with ads?',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericArticleScreen(
                    title: 'Having issues with ads?',
                    children: [
                      Text('We know ads aren\'t everyone\'s favorite (trust us, we play too). They allow us to keep the game free and continue improving it with new puzzles, updates, and features.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('That said, ads should never disrupt your experience. If something doesn\'t seem right, we\'re here to help.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('Below are answers to the most common questions.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 30),
                      Text('Why am I seeing ads so often? 📺', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Text('Ads may appear between games, after finishing levels, or when using certain features.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('If you prefer uninterrupted play, we offer a one-time Remove Ads purchase that removes most ads permanently.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 30),
                      Text('I removed ads, why am I still seeing them?', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  )));
                },
              ),
              _buildQuestionItem(
                'How do I delete my data and game progress?',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericArticleScreen(
                    title: 'How do I delete my data and game progress?',
                    children: [
                      Text.rich(
                        TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                          children: [
                            TextSpan(text: '1. Tap the '),
                            TextSpan(text: 'gear icon', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            TextSpan(text: ' in the top right corner.'),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                          children: [
                            TextSpan(text: '2. Navigate to '),
                            TextSpan(text: 'Privacy Rights', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Text.rich(
                        TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                          children: [
                            TextSpan(text: '3. Select '),
                            TextSpan(text: 'Delete My Data', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            TextSpan(text: ' and follow the instructions provided.'),
                          ],
                        ),
                      ),
                    ],
                  )));
                },
              ),
              _buildQuestionItem(
                'Privacy Rights and Options.',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GenericArticleScreen(
                    title: 'Privacy Rights and Options',
                    children: [
                      Text('We value your privacy and are dedicated to safeguarding your personal data in accordance with the General Data Protection Regulation (GDPR). This section is designed to inform you about your rights regarding your personal data and the options available to you to manage your privacy preferences.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 30),
                      Text('Right to Access', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Text('To request access to your data, please tap the message icon in the bottom right corner and enter your request. We will provide you with a copy of your personal data in an electronic format.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('Alternatively, you can exercise this right through the Privacy Rights section within our apps:', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('1. Open the app settings (Me or More depending on the app).', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 15),
                      Text('2. Navigate to Privacy Rights.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 15),
                      Text('3. Select Access to Data and follow the instructions provided.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 30),
                      Text('Right to Erasure', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Text('You can request the deletion of your data through the app\'s Privacy Rights section by following this procedure:', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('1. Open the app settings (Me or More depending on the app).', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 15),
                      Text('2. Navigate to Privacy Rights.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 15),
                      Text('3. Select Delete My Data and follow the instructions provided.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 30),
                      Text('Other Rights', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Text('You also have other rights, such as to correct your data, object to how we use or share your data, and restrict how we use or share your data. You also have the right to withdraw consent where you have previously given it to the processing of your personal data, for example, by turning off camera access in your mobile device\'s settings, where applicable.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('Any requests to exercise your rights should be made through the support section of our application. You can also send an email to privacy@easybrain.com. However, we may still redirect you to make the same request through the in-app support section, or we may request additional information to process your request. These requests can be exercised free of charge and will be addressed by us as early as possible and always within one month. You may also contact your local data protection authority within the European Economic Area for unresolved complaints.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 30),
                      Text('Opt-Out of Targeted Advertising', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Text('To show you personalized advertisements in our apps, we use specific advertising networks and their partners to deliver advertisements tailored to you based on a determination of your characteristics or interests. To do so, they use personal and advertising identifiers, including the Android advertising ID and/or Apple\'s ID for advertising (IDFA), and may use cookies and other similar tracking technologies to enable and optimize this advertising procedure.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('Depending on your local privacy laws, you may opt out of the personalized advertisement experience at any time by following the instructions below. When you choose to opt out, advertising networks will consider this choice as a withdrawal of consent to the personalized advertisement experience, and they will show only non-personalized advertisements that will not be based on your interests.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('You can exercise these privacy rights at any time by checking the Privacy Preferences tab in any of our apps or under the privacy settings of your iOS or Android device.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('1. Open the app settings (Me or More depending on the app).', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 15),
                      Text('2. Navigate to Privacy Preferences (or Do Not Sell or Share My Personal Information).', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 15),
                      Text('3. Tap Withdraw Consent to All, then tap Confirm Choices (Android) or Save & Exit (iOS).', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('Otherwise, you can limit access to your advertising identifiers i.e. the Android advertising ID and/or Apple\'s ID for advertising (IDFA), through the privacy settings on your iOS or Android device. This means that third parties won\'t be able to link your data across different apps and websites. To do so, please follow these steps:', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 20),
                      Text('For iOS:', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Text('1. Open the Settings on your iOS device.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 15),
                      Text('2. Navigate down and select Privacy (& Security).', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 15),
                      Text('3. Select Tracking or Advertising (depending on your device\'s operating system).\na. If you selected Tracking, enable or disable Allow Apps to Request to Track and/or this particular app from the list of apps.\nb. If you selected Advertising, enable or disable Limit Ad Tracking accordingly.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 30),
                      Text('For Android:', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 15),
                      Text('1. Open the Settings on your Android device.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 15),
                      Text('2. Navigate down and select either Privacy or Google (depending on your device\'s operating system).\na. If you selected Privacy, now choose Ads.\nb. If you selected Google, select Ads under the All Services section.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 15),
                      Text('3. Tap Reset Advertising ID or Delete Advertising ID, as applicable.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                      SizedBox(height: 30),
                      Text('Please note that opting out does not mean that you will see fewer advertisements; it just means that you will see advertisements that are less relevant to your interests.', style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5)),
                    ],
                  )));
                },
              ),
            ],
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ContactUsScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
    );
  }
}
