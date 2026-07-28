import 'dart:math';
import '../models/arrow_level.dart';

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
  final LevelShape shape;

  PuzzleLevel({
    required this.gridWidth,
    required this.gridHeight,
    required this.strings,
    this.shape = LevelShape.rectangle,
  });
}

class PuzzleGenerator {
  static bool isCellInShape(int x, int y, int width, int height, LevelShape shape) {
    if (x < 0 || x >= width || y < 0 || y >= height) return false;

    switch (shape) {
      case LevelShape.rectangle:
        return true;

      case LevelShape.triangle:
        double cx = (x + 0.5) / width;
        double cy = (y + 0.5) / height;
        double halfWidthAtY = 0.12 + 0.42 * cy;
        return (cx - 0.5).abs() <= halfWidthAtY;

      case LevelShape.heart:
        double cx = (x - (width - 1) / 2.0) / (max(1, width - 1) / 2.0);
        double cy = (y - (height - 1) / 2.0) / (max(1, height - 1) / 2.0);
        double u = cx * 1.35;
        double v = -cy * 1.35 + 0.25;
        double val = pow(u * u + v * v - 1, 3) - u * u * pow(v, 3);
        return val <= 0.08;

      case LevelShape.circle:
        double cx = (x - (width - 1) / 2.0) / (max(1, width - 1) / 2.0);
        double cy = (y - (height - 1) / 2.0) / (max(1, height - 1) / 2.0);
        return (cx * cx + cy * cy) <= 1.15;

      case LevelShape.diamond:
        double cx = (x - (width - 1) / 2.0) / (max(1, width - 1) / 2.0);
        double cy = (y - (height - 1) / 2.0) / (max(1, height - 1) / 2.0);
        return (cx.abs() + cy.abs()) <= 1.25;

      case LevelShape.cross:
        double cx = (x + 0.5) / width;
        double cy = (y + 0.5) / height;
        return (cx >= 0.25 && cx <= 0.75) || (cy >= 0.25 && cy <= 0.75);

      case LevelShape.star:
        double cx = (x - (width - 1) / 2.0) / (max(1, width - 1) / 2.0);
        double cy = (y - (height - 1) / 2.0) / (max(1, height - 1) / 2.0);
        return pow(cx.abs(), 0.75) + pow(cy.abs(), 0.75) <= 1.15;
    }
  }

  static PuzzleLevel getLevel(int level, {LevelShape? customShape}) {
    int width;
    int height;
    double fillTarget;
    int maxStringLen;
    LevelShape shape;

    if (customShape != null) {
      shape = customShape;
    } else {
      // Assign shapes per level sequence
      if (level == 1) {
        shape = LevelShape.rectangle;
      } else if (level == 2) {
        shape = LevelShape.triangle;
      } else if (level == 3) {
        shape = LevelShape.heart;
      } else if (level == 4) {
        shape = LevelShape.circle;
      } else if (level == 5) {
        shape = LevelShape.diamond;
      } else if (level == 6) {
        shape = LevelShape.cross;
      } else if (level == 7) {
        shape = LevelShape.star;
      } else {
        final shapes = LevelShape.values;
        shape = shapes[(level - 1) % shapes.length];
      }
    }

    if (level == 1) {
      width = 7;
      height = 7;
      fillTarget = 0.75;
      maxStringLen = 4;
    } else if (level == 2) {
      width = 9;
      height = 9;
      fillTarget = 0.80;
      maxStringLen = 5;
    } else if (level == 3) {
      width = 11;
      height = 11;
      fillTarget = 0.84;
      maxStringLen = 6;
    } else if (level == 4) {
      width = 13;
      height = 13;
      fillTarget = 0.87;
      maxStringLen = 8;
    } else if (level == 5) {
      width = 15;
      height = 15;
      fillTarget = 0.89;
      maxStringLen = 10;
    } else if (level < 15) {
      width = 15;
      height = 15;
      fillTarget = 0.90;
      maxStringLen = 10;
    } else if (level < 30) {
      width = 17;
      height = 17;
      fillTarget = 0.92;
      maxStringLen = 12;
    } else {
      width = 19;
      height = 19;
      fillTarget = 0.93;
      maxStringLen = 14;
    }

    int validCellsCount = 0;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        if (isCellInShape(x, y, width, height, shape)) {
          validCellsCount++;
        }
      }
    }

    int minRequiredArrows = max(5, (validCellsCount * 0.35).toInt());

    PuzzleLevel bestLevel = _generateReverseTime(width, height, fillTarget, maxStringLen, level, shape);
    int attempt = 1;
    while ((bestLevel.strings.length < minRequiredArrows || !isLevelSolvable(bestLevel)) && attempt < 50) {
      PuzzleLevel candidate = _generateReverseTime(width, height, fillTarget, maxStringLen, level + attempt * 1009, shape);
      if (isLevelSolvable(candidate) && candidate.strings.length >= minRequiredArrows) {
        bestLevel = candidate;
        break;
      }
      if (isLevelSolvable(candidate) && candidate.strings.length > bestLevel.strings.length) {
        bestLevel = candidate;
      }
      attempt++;
    }

    return bestLevel;
  }

  static bool isLevelSolvable(PuzzleLevel level) {
    List<PuzzleString> active = List.from(level.strings);
    if (active.isEmpty) return false;

    bool progress = true;
    while (progress && active.isNotEmpty) {
      progress = false;
      Set<Point> occupied = {};
      for (var s in active) {
        for (var p in s.path) {
          occupied.add(p);
        }
      }

      for (int i = 0; i < active.length; i++) {
        var string = active[i];
        Direction dir = string.exitDirection;
        int dx = (dir == Direction.right) ? 1 : (dir == Direction.left) ? -1 : 0;
        int dy = (dir == Direction.down) ? 1 : (dir == Direction.up) ? -1 : 0;

        Point check = Point(string.head.x + dx, string.head.y + dy);
        bool clear = true;
        while (check.x >= 0 && check.x < level.gridWidth && check.y >= 0 && check.y < level.gridHeight) {
          if (occupied.contains(check)) {
            clear = false;
            break;
          }
          check = Point(check.x + dx, check.y + dy);
        }

        if (clear) {
          active.removeAt(i);
          progress = true;
          break;
        }
      }
    }

    return active.isEmpty;
  }

  static PuzzleLevel _generateReverseTime(int width, int height, double fillTarget, int maxStringLen, int seed, LevelShape shape) {
    Random rand = Random(seed);
    List<PuzzleString> strings = [];
    Set<Point> occupied = {};

    int validCellsCount = 0;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        if (isCellInShape(x, y, width, height, shape)) {
          validCellsCount++;
        }
      }
    }

    int targetCells = max(1, (validCellsCount * fillTarget).toInt());
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
    while (occupied.length < targetCells && failedAttempts < 400) {
      List<Point> emptyCells = [];
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          Point p = Point(x, y);
          if (isCellInShape(x, y, width, height, shape) && !occupied.contains(p)) {
            emptyCells.add(p);
          }
        }
      }

      if (emptyCells.isEmpty) break;

      emptyCells.shuffle(rand);
      bool placed = false;

      for (Point head in emptyCells) {
        List<Direction> dirs = [Direction.up, Direction.down, Direction.left, Direction.right];
        dirs.shuffle(rand);

        for (Direction dir in dirs) {
          if (!isExitClear(head, dir)) continue;

          // Backward vector from head opposite to exit
          int bdx = 0, bdy = 0;
          if (dir == Direction.right) bdx = -1;
          if (dir == Direction.left) bdx = 1;
          if (dir == Direction.down) bdy = -1;
          if (dir == Direction.up) bdy = 1;

          int desiredLen = 2 + rand.nextInt(max(1, maxStringLen - 1));
          bool isLShaped = (desiredLen >= 3) && rand.nextBool();

          List<Point> candidateBody = [head];
          Set<Point> candidateBodySet = {head};

          if (!isLShaped) {
            // Straight arrow path
            Point curr = head;
            for (int len = 1; len < desiredLen; len++) {
              Point nextPoint = Point(curr.x + bdx, curr.y + bdy);
              if (isCellInShape(nextPoint.x, nextPoint.y, width, height, shape) &&
                  !occupied.contains(nextPoint) &&
                  !candidateBodySet.contains(nextPoint)) {
                candidateBody.add(nextPoint);
                candidateBodySet.add(nextPoint);
                curr = nextPoint;
              } else {
                break;
              }
            }
          } else {
            // L-Shaped arrow path (1 right-angle turn)
            int stem1 = 1 + rand.nextInt(max(1, desiredLen - 2));
            Point curr = head;
            for (int len = 0; len < stem1; len++) {
              Point nextPoint = Point(curr.x + bdx, curr.y + bdy);
              if (isCellInShape(nextPoint.x, nextPoint.y, width, height, shape) &&
                  !occupied.contains(nextPoint) &&
                  !candidateBodySet.contains(nextPoint)) {
                candidateBody.add(nextPoint);
                candidateBodySet.add(nextPoint);
                curr = nextPoint;
              } else {
                break;
              }
            }

            List<Point> turnDirs = [];
            if (bdx != 0) {
              turnDirs = [const Point(0, 1), const Point(0, -1)];
            } else {
              turnDirs = [const Point(1, 0), const Point(-1, 0)];
            }
            turnDirs.shuffle(rand);

            Point turnDir = turnDirs.first;
            int remainingLen = desiredLen - candidateBody.length;
            for (int len = 0; len < remainingLen; len++) {
              Point nextPoint = Point(curr.x + turnDir.x, curr.y + turnDir.y);
              if (isCellInShape(nextPoint.x, nextPoint.y, width, height, shape) &&
                  !occupied.contains(nextPoint) &&
                  !candidateBodySet.contains(nextPoint)) {
                candidateBody.add(nextPoint);
                candidateBodySet.add(nextPoint);
                curr = nextPoint;
              } else {
                break;
              }
            }
          }

          if (candidateBody.length >= 2) {
            List<Point> finalPath = candidateBody.reversed.toList();
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

    return PuzzleLevel(
      gridWidth: width,
      gridHeight: height,
      strings: strings,
      shape: shape,
    );
  }
}
