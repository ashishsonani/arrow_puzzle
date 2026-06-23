import 'package:flutter/material.dart';
import 'feedback_section.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  Widget _buildSection({
    required String icon,
    required String title,
    required List<TextSpan> textSpans,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
              children: textSpans,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616), // Match the app's dark theme
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'How do I play?',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How do I play?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              icon: '🎯',
              title: 'Your Goal',
              textSpans: [
                const TextSpan(text: 'Clear the grid', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: ' by helping every arrow leave the board.'),
              ],
            ),
            _buildSection(
              icon: '🧭',
              title: 'Find a Free Path',
              textSpans: [
                const TextSpan(text: 'An arrow '),
                const TextSpan(text: 'moves only when the space ahead is clear', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: ' (no arrows blocking its direction). Take a moment to scan the grid and spot safe exits.'),
              ],
            ),
            _buildSection(
              icon: '👆',
              title: 'Tap in the Right Order',
              textSpans: [
                const TextSpan(text: 'Tap arrows one by one', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: ' to let them exit and '),
                const TextSpan(text: 'open space', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: ' for the others. Planning the order of your taps is the key to solving each puzzle.'),
              ],
            ),
            _buildSection(
              icon: '❤️',
              title: 'Lives & Mistakes',
              textSpans: [
                const TextSpan(text: 'If you tap a '),
                const TextSpan(text: 'blocked arrow', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: ', you '),
                const TextSpan(text: 'lose a life', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: '. Lives are limited per level, but you can always rethink your plan and try again at your own pace.'),
              ],
            ),
            _buildSection(
              icon: '💡',
              title: 'Use Hints',
              textSpans: [
                const TextSpan(text: 'Stuck? '),
                const TextSpan(text: 'Hints', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: ' highlight an arrow that can '),
                const TextSpan(text: 'safely leave', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: ' the grid so you can keep your flow.'),
              ],
            ),
            _buildSection(
              icon: '✅',
              title: 'Finish the Board',
              textSpans: [
                const TextSpan(text: 'Keep creating space, help every arrow escape, and enjoy that final moment when the '),
                const TextSpan(text: 'last arrow leaves', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                const TextSpan(text: ' and everything falls into place.'),
              ],
            ),
            const FeedbackSection(),
          ],
        ),
      ),
    );
  }
}
