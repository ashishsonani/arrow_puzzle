import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/arrow_level.dart';
import '../widgets/path_arrow_widget.dart';

class ArrowGameplayScreen extends StatefulWidget {
  final ArrowLevel level;

  const ArrowGameplayScreen({super.key, required this.level});

  @override
  State<ArrowGameplayScreen> createState() => _ArrowGameplayScreenState();
}

class _ArrowGameplayScreenState extends State<ArrowGameplayScreen> with TickerProviderStateMixin {
  late ArrowLevel currentLevel;
  int currentHearts = 0;
  bool isLevelComplete = false;

  @override
  void initState() {
    super.initState();
    _initLevel();
  }

  void _initLevel() {
    currentLevel = ArrowLevel(
      id: widget.level.id,
      title: widget.level.title,
      difficulty: widget.level.difficulty,
      initialHearts: widget.level.initialHearts,
      gridWidth: widget.level.gridWidth,
      gridHeight: widget.level.gridHeight,
      paths: widget.level.paths.map((p) => PathArrow(
        id: p.id,
        segments: p.segments,
        state: p.state,
      )).toList(),
    );
    currentHearts = currentLevel.initialHearts;
  }

  bool _isPathClear(PathArrow arrow) {
    final dir = arrow.headDirection;
    var currentPoint = math.Point(arrow.head.x + dir.x, arrow.head.y + dir.y);

    // Keep checking in the head direction until we exit the grid bounds
    // (Assuming grid bounds roughly based on level dimensions, or we can just check a reasonable distance)
    // Actually, we can just check against all other active segments since we only care about collisions.
    // Let's check up to 20 cells away just to be safe.
    for (int i = 0; i < 20; i++) {
      for (var other in currentLevel.paths) {
        if (other.id == arrow.id || other.state == ArrowState.cleared) continue;
        for (var seg in other.segments) {
          if (seg.x == currentPoint.x && seg.y == currentPoint.y) {
            return false; // Blocked by another arrow
          }
        }
      }
      currentPoint = math.Point(currentPoint.x + dir.x, currentPoint.y + dir.y);
    }
    return true;
  }

  void _onPathTap(PathArrow arrow) {
    debugPrint('User clicked arrow ID: ${arrow.id}, State: ${arrow.state.name}');

    if (arrow.state != ArrowState.active || isLevelComplete) return;

    if (_isPathClear(arrow)) {
      setState(() {
        arrow.state = ArrowState.cleared;
      });
      _checkLevelCompletion();
    } else {
      if (currentHearts > 0) {
        setState(() {
          currentHearts--;
        });
        if (currentHearts == 0) {
          _showGameOverDialog();
        }
      }
    }
  }

  void _checkLevelCompletion() {
    if (currentLevel.paths.every((a) => a.state == ArrowState.cleared)) {
      setState(() {
        isLevelComplete = true;
      });
      _showLevelCompleteDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: const Text('You ran out of hearts!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Exit
            },
            child: const Text('Exit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _initLevel(); // Retry
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Column(
          children: [
            Text('😃', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text('Perfect!', style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(currentLevel.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
            onPressed: () {},
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.navigation, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text('${currentLevel.paths.where((p) => p.state != ArrowState.cleared).length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(
                      currentLevel.initialHearts,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Icon(
                          index < currentHearts ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                    ),
                    child: Text(
                      currentLevel.difficulty,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: currentLevel.gridWidth / currentLevel.gridHeight,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final cellSize = constraints.maxWidth / currentLevel.gridWidth;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: (details) {
                            final localPosition = details.localPosition;
                            final gridX = (localPosition.dx / cellSize).floor();
                            final gridY = (localPosition.dy / cellSize).floor();

                            PathArrow? tappedArrow;
                            for (var arrow in currentLevel.paths.reversed) {
                              if (arrow.state == ArrowState.cleared) continue;
                              bool found = false;
                              for (var seg in arrow.segments) {
                                if (seg.x == gridX && seg.y == gridY) {
                                  tappedArrow = arrow;
                                  found = true;
                                  break;
                                }
                              }
                              if (found) break;
                            }

                            if (tappedArrow != null) {
                              _onPathTap(tappedArrow);
                            }
                          },
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                                painter: DottedHeartPainter(
                                  gridWidth: currentLevel.gridWidth,
                                  gridHeight: currentLevel.gridHeight,
                                  cellSize: cellSize,
                                ),
                              ),
                              ...currentLevel.paths.map((arrow) {
                                if (arrow.state == ArrowState.cleared) return const SizedBox.shrink();
                                return PathArrowWidget(
                                  arrow: arrow,
                                  cellSize: cellSize,
                                  onTap: () {}, // Handled by parent GestureDetector now
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Bottom bar (Hint, Tool)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 32),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('Ad', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: const Icon(Icons.format_paint, color: Colors.white, size: 32), // Roller proxy
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedHeartPainter extends CustomPainter {
  final int gridWidth;
  final int gridHeight;
  final double cellSize;

  DottedHeartPainter({
    required this.gridWidth,
    required this.gridHeight,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Draw dots at all grid centers for now
    // In a full implementation, we can restrict this to a heart mask
    for (int y = 0; y < gridHeight; y++) {
      for (int x = 0; x < gridWidth; x++) {
        canvas.drawCircle(
          Offset(x * cellSize + cellSize / 2, y * cellSize + cellSize / 2),
          cellSize * 0.05,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
