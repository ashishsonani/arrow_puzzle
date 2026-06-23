import 'package:flutter/material.dart';
import 'feedback_section.dart';

class HowToGetHintScreen extends StatelessWidget {
  const HowToGetHintScreen({super.key});

  Widget _buildStep(String number, List<TextSpan> textSpans) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
                children: textSpans,
              ),
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
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'How do I get a hint?',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How do I get a hint?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            _buildStep('1', [
              const TextSpan(text: 'Tap the '),
              const TextSpan(text: 'Hint', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const TextSpan(text: ' icon in the '),
              const TextSpan(text: 'bottom-right corner', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const TextSpan(text: '.'),
            ]),
            _buildStep('2', [
              const TextSpan(text: 'The game will '),
              const TextSpan(text: 'highlight an arrow', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const TextSpan(text: ' that can safely leave the grid.'),
            ]),
            _buildStep('3', [
              const TextSpan(text: 'Tap the highlighted arrow', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              const TextSpan(text: ' to continue playing and open more space on the board.'),
            ]),
            const FeedbackSection(),
          ],
        ),
      ),
    );
  }
}
