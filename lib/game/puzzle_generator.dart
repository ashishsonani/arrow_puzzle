import 'dart:math';

class Point {
  final int x;
  final int y;

  const Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
  
  @override
  String toString() => 'Point($x, $y)';
}

enum Direction { up, down, left, right }

class PuzzleString {
  final int id;
  final List<Point> path; 

  PuzzleString({required this.id, required this.path});

  Point get head => path.last;
  
  Direction get exitDirection {
    if (path.length < 2) return Direction.up;
    Point secondLast = path[path.length - 2];
    if (head.x > secondLast.x) return Direction.right;
    if (head.x < secondLast.x) return Direction.left;
    if (head.y > secondLast.y) return Direction.down;
    return Direction.up;
  }
}

class PuzzleLevel {
  final int gridWidth;
  final int gridHeight;
  final List<PuzzleString> strings;

  PuzzleLevel({
    required this.gridWidth,
    required this.gridHeight,
    required this.strings,
  });
}

class PuzzleGenerator {
  static PuzzleLevel getLevel(int level) {
    int width;
    int height;
    double fillTarget;
    int maxStringLen;

    // Custom scaling curve matching user's reference screenshots (Level 4: ~10 arrows, Level 5: ~36 arrows)
    if (level == 1) {
      width = 4;
      height = 4;
      fillTarget = 0.35;
      maxStringLen = 2;
    } else if (level == 2) {
      width = 4;
      height = 5;
      fillTarget = 0.4;
      maxStringLen = 3;
    } else if (level == 3) {
      width = 5;
      height = 5;
      fillTarget = 0.45;
      maxStringLen = 3;
    } else if (level == 4) {
      // Small/simple grid for Level 4
      width = 6;
      height = 7;
      fillTarget = 0.5;
      maxStringLen = 3;
    } else if (level == 5) {
      // Large/complex grid for Level 5
      width = 9;
      height = 10;
      fillTarget = 0.7;
      maxStringLen = 5;
    } else if (level < 10) {
      width = 9;
      height = 10;
      fillTarget = 0.72;
      maxStringLen = 6;
    } else if (level < 20) {
      width = 10;
      height = 12;
      fillTarget = 0.75;
      maxStringLen = 8;
    } else {
      width = 12;
      height = 15;
      fillTarget = 0.8;
      maxStringLen = 10;
    }

    return _generateReverseTime(width, height, fillTarget, maxStringLen, level);
  }

  static PuzzleLevel _generateReverseTime(int width, int height, double fillTarget, int maxStringLen, int seed) {
    Random rand = Random(seed);
    List<PuzzleString> strings = [];
    Set<Point> occupied = {};

    int targetCells = (width * height * fillTarget).toInt();
    int idCounter = 1;

    bool isExitClear(Point p, Direction dir) {
      int dx = 0, dy = 0;
      if (dir == Direction.right) dx = 1;
      if (dir == Direction.left) dx = -1;
      if (dir == Direction.down) dy = 1;
      if (dir == Direction.up) dy = -1;

      Point check = Point(p.x + dx, p.y + dy);
      while (check.x >= 0 && check.x < width && check.y >= 0 && check.y < height) {
        if (occupied.contains(check)) return false;
        check = Point(check.x + dx, check.y + dy);
      }
      return true;
    }

    int failedAttempts = 0;
    while (occupied.length < targetCells && failedAttempts < 100) {
      List<Point> emptyCells = [];
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          Point p = Point(x, y);
          if (!occupied.contains(p)) {
            emptyCells.add(p);
          }
        }
      }

      emptyCells.shuffle(rand);
      bool placed = false;

      for (Point head in emptyCells) {
        List<Direction> dirs = [Direction.up, Direction.down, Direction.left, Direction.right];
        dirs.shuffle(rand);

        for (Direction dir in dirs) {
          int bdx = 0, bdy = 0;
          if (dir == Direction.right) bdx = -1;
          if (dir == Direction.left) bdx = 1;
          if (dir == Direction.down) bdy = -1;
          if (dir == Direction.up) bdy = 1;

          Point prev = Point(head.x + bdx, head.y + bdy);
          if (prev.x < 0 || prev.x >= width || prev.y < 0 || prev.y >= height || occupied.contains(prev)) {
            continue;
          }

          if (isExitClear(head, dir)) {
            List<Point> body = [head, prev];
            Set<Point> currentBody = {head, prev};
            
            Point curr = prev;
            int targetLen = 2 + rand.nextInt(maxStringLen - 1);
            
            while (body.length < targetLen) {
              List<Point> neighbors = [
                Point(curr.x + 1, curr.y),
                Point(curr.x - 1, curr.y),
                Point(curr.x, curr.y + 1),
                Point(curr.x, curr.y - 1),
              ];
              neighbors.shuffle(rand);
              
              bool grew = false;
              for (Point n in neighbors) {
                if (n.x >= 0 && n.x < width && n.y >= 0 && n.y < height) {
                  if (!occupied.contains(n) && !currentBody.contains(n)) {
                    body.add(n);
                    currentBody.add(n);
                    curr = n;
                    grew = true;
                    break;
                  }
                }
              }
              if (!grew) break;
            }

            List<Point> finalPath = body.reversed.toList();
            strings.add(PuzzleString(id: idCounter++, path: finalPath));
            occupied.addAll(finalPath);
            placed = true;
            break;
          }
        }
        if (placed) break;
      }

      if (!placed) {
        failedAttempts++;
      } else {
        failedAttempts = 0;
      }
    }

    return PuzzleLevel(gridWidth: width, gridHeight: height, strings: strings);
  }
}
