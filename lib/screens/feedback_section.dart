import 'package:flutter/material.dart';

class FeedbackSection extends StatefulWidget {
  const FeedbackSection({super.key});

  @override
  State<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  bool? isHelpful;

  Widget _buildFeedbackButton(bool isUpvote) {
    final bool isSelected = isUpvote ? isHelpful == true : isHelpful == false;
    final IconData icon = isUpvote
        ? (isSelected ? Icons.thumb_up : Icons.thumb_up_alt_outlined)
        : (isSelected ? Icons.thumb_down : Icons.thumb_down_alt_outlined);

    return GestureDetector(
      onTap: () {
        setState(() {
          isHelpful = isUpvote;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.2) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF4CAF50) : Colors.white24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF4CAF50) : Colors.white54,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Text(
          'Was this article helpful?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildFeedbackButton(false), // Thumb down
            const SizedBox(width: 15),
            _buildFeedbackButton(true),  // Thumb up
          ],
        ),
      ],
    );
  }
}
