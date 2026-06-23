import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/arrow_level.dart';

class PathArrowWidget extends StatelessWidget {
  final PathArrow arrow;
  final VoidCallback onTap;
  final double cellSize;

  const PathArrowWidget({
    super.key,
    required this.arrow,
    required this.onTap,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) {
    // Determine bounds of this path
    int minX = arrow.segments.first.x;
    int maxX = arrow.segments.first.x;
    int minY = arrow.segments.first.y;
    int maxY = arrow.segments.first.y;

    for (var p in arrow.segments) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }

    // We make the widget cover its entire bounding box
    final width = (maxX - minX + 1) * cellSize;
    final height = (maxY - minY + 1) * cellSize;

    return Positioned(
      left: minX * cellSize,
      top: minY * cellSize,
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: PathPainter(
          segments: arrow.segments,
          minX: minX,
          minY: minY,
          cellSize: cellSize,
          color: arrow.state == ArrowState.moving ? Colors.white : const Color(0xFF4CAF50),
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final List<math.Point<int>> segments;
  final int minX;
  final int minY;
  final double cellSize;
  final Color color;

  PathPainter({
    required this.segments,
    required this.minX,
    required this.minY,
    required this.cellSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = cellSize * 0.15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    
    // Convert grid coordinates to local canvas coordinates
    Offset toLocal(math.Point<int> p) {
      return Offset(
        (p.x - minX) * cellSize + cellSize / 2,
        (p.y - minY) * cellSize + cellSize / 2,
      );
    }

    path.moveTo(toLocal(segments.first).dx, toLocal(segments.first).dy);
    for (int i = 1; i < segments.length; i++) {
      path.lineTo(toLocal(segments[i]).dx, toLocal(segments[i]).dy);
    }

    canvas.drawPath(path, paint);

    // Draw arrowhead at the last segment
    if (segments.length >= 2) {
      final head = toLocal(segments.last);
      final prev = toLocal(segments[segments.length - 2]);
      
      final angle = math.atan2(head.dy - prev.dy, head.dx - prev.dx);
      
      final arrowLength = cellSize * 0.3;
      final arrowAngle = math.pi / 6;

      final p1 = Offset(
        head.dx - arrowLength * math.cos(angle - arrowAngle),
        head.dy - arrowLength * math.sin(angle - arrowAngle),
      );
      final p2 = Offset(
        head.dx - arrowLength * math.cos(angle + arrowAngle),
        head.dy - arrowLength * math.sin(angle + arrowAngle),
      );

      final arrowPaint = Paint()
        ..color = color
        ..strokeWidth = cellSize * 0.15
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final arrowPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(head.dx, head.dy)
        ..lineTo(p2.dx, p2.dy);
        
      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.segments != segments;
  }
}
