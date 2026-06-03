import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';

// ── Design token: oklch(0.488 0.243 264.376) → ~#1F3CE6 (vivid indigo-blue)
const Color kOrbitIndigo = AppColors.brand;

/// Reusable Orbit brand icon rendered via [CustomPainter].
/// Matches the lucide `<Orbit>` SVG: tilted elliptical ring + centre dot +
/// two smaller dots on the ring.
class OrbitIcon extends StatelessWidget {
  const OrbitIcon({
    super.key,
    this.size = 24,
    this.color = kOrbitIndigo,
    this.strokeWidth = 1.5,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _OrbitIconPainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _OrbitIconPainter extends CustomPainter {
  const _OrbitIconPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final u = size.width / 24; // 1 lucide grid unit in px

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * u
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 1. Tilted elliptical ring (rx=10, ry=4, rotated -45°)
    canvas
      ..save()
      ..translate(cx, cy)
      ..rotate(-math.pi / 4)
      ..drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: 10 * u * 2,
          height: 4 * u * 2,
        ),
        stroke,
      )
      ..restore();

    // 2. Centre dot
    canvas.drawCircle(Offset(cx, cy), 1.5 * u, fill);

    // 3 & 4. End dots on the ring
    const a = -math.pi / 4;
    canvas
      ..drawCircle(
        Offset(
          cx + 10 * u * math.cos(a - math.pi / 2),
          cy + 10 * u * math.sin(a - math.pi / 2),
        ),
        1.2 * u,
        fill,
      )
      ..drawCircle(
        Offset(
          cx + 10 * u * math.cos(a + math.pi / 2),
          cy + 10 * u * math.sin(a + math.pi / 2),
        ),
        1.2 * u,
        fill,
      );
  }

  @override
  bool shouldRepaint(_OrbitIconPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
