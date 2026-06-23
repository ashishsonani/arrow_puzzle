import 'dart:math';

enum ArrowState { active, moving, cleared, blocked }

class PathArrow {
  final int id;
  /// List of grid coordinates forming the path. Index 0 is the tail, last index is the head.
  List<Point<int>> segments; 
  ArrowState state;

  PathArrow({
    required this.id,
    required List<Point<int>> segments,
    this.state = ArrowState.active,
  }) : segments = List.from(segments);
  
  Point<int> get head => segments.last;
  Point<int> get tail => segments.first;

  /// The direction the head is pointing, to know where it will move.
  Point<int> get headDirection {
    if (segments.length < 2) return const Point(0, -1); // Default up
    var diff = segments.last - segments[segments.length - 2];
    // Normalize in case segments are longer than 1
    if (diff.x > 0) return const Point(1, 0);
    if (diff.x < 0) return const Point(-1, 0);
    if (diff.y > 0) return const Point(0, 1);
    if (diff.y < 0) return const Point(0, -1);
    return const Point(0, -1);
  }
}

class ArrowLevel {
  final int id;
  final String title;
  final String difficulty;
  final int initialHearts;
  final int gridWidth;
  final int gridHeight;
  final List<PathArrow> paths;

  ArrowLevel({
    required this.id,
    required this.title,
    required this.difficulty,
    this.initialHearts = 3,
    required this.gridWidth,
    required this.gridHeight,
    required this.paths,
  });
}

class LevelCategory {
  final String id;
  final String title;
  final List<ArrowLevel> levels;

  LevelCategory({
    required this.id,
    required this.title,
    required this.levels,
  });
}
