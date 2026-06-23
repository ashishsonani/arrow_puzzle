import 'package:flutter/material.dart';
import 'dart:math';
import '../models/arrow_level.dart';
import 'arrow_gameplay_screen.dart';

class ArrowLevelSelectionScreen extends StatelessWidget {
  const ArrowLevelSelectionScreen({super.key});

  List<LevelCategory> _getMockCategories() {
    return [
      LevelCategory(
        id: 'c1',
        title: 'Tangle Puzzle',
        levels: [
          ArrowLevel(
            id: 6,
            title: 'Level 6',
            difficulty: 'Easy',
            gridWidth: 10,
            gridHeight: 10,
            paths: [
              // Simple mock paths for now to get it compiling
              // I will refine the heart shape later if needed
              PathArrow(id: 1, segments: const [Point(2, 2), Point(3, 2), Point(3, 3)]),
              PathArrow(id: 2, segments: const [Point(5, 5), Point(5, 4), Point(6, 4)]),
            ],
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final categories = _getMockCategories();

    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: const Text('Arrow Puzzles', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final level = category.levels.first;

          return Card(
            margin: const EdgeInsets.only(bottom: 24),
            color: const Color(0xFF212121),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArrowGameplayScreen(level: level),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.navigation, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text('${level.id}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            level.initialHearts,
                            (index) => const Icon(Icons.favorite, color: Colors.red, size: 20),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            level.difficulty,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.black26, // Darker box for dark theme
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3), width: 1), // Green subtle border
                      ),
                      child: const Center(
                        child: Icon(Icons.gamepad, size: 64, color: Colors.white24),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Tap to Play', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
