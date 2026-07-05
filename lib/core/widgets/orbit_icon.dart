import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';

// ── Design token: oklch(0.488 0.243 264.376) → ~#1F3CE6 (vivid indigo-blue)
const Color kOrbitIndigo = AppColors.brand;

/// Reusable Orbit brand icon rendered via [CustomPainter].
/// Renders a highly premium, animated 3D Gyroscopic Armature / Quantum Atom
/// that dynamically sorts layers by Z-depth to achieve a true holographic 3D aesthetic.
class OrbitIcon extends StatefulWidget {
  const OrbitIcon({
    super.key,
    this.size = 24,
    this.color = kOrbitIndigo,
    this.strokeWidth = 1.5,
    this.isAnimated = true,
  });

  final double size;
  final Color color;
  final double strokeWidth;
  final bool isAnimated;

  @override
  State<OrbitIcon> createState() => _OrbitIconState();
}

class _OrbitIconState extends State<OrbitIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // Smooth, continuous gyroscopic spin
    );
    if (widget.isAnimated) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(OrbitIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated != oldWidget.isAnimated) {
      if (widget.isAnimated) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _OrbitIconPainter(
                color: widget.color,
                strokeWidth: widget.strokeWidth,
                progress: widget.isAnimated ? _controller.value : 0.0,
                isHovered: _isHovered,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Helper class to represent a 3D vector and handle rotation transformations.
class _Vector3 {
  const _Vector3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  _Vector3 rotateX(double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    return _Vector3(x, y * cos - z * sin, y * sin + z * cos);
  }

  _Vector3 rotateY(double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    return _Vector3(x * cos + z * sin, y, -x * sin + z * cos);
  }

  _Vector3 rotateZ(double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    return _Vector3(x * cos - y * sin, x * sin + y * cos, z);
  }
}

/// Abstract drawable item sorted by depth for the Painter's Algorithm (Z-sorting).
abstract class _DrawItem {
  const _DrawItem({required this.depth});

  final double depth;
  void draw(Canvas canvas, double u);
}

/// A line segment representation of a ring.
class _LineSegmentItem extends _DrawItem {
  const _LineSegmentItem({
    required super.depth,
    required this.p1,
    required this.p2,
    required this.color,
    required this.strokeWidth,
  });

  final Offset p1;
  final Offset p2;
  final Color color;
  final double strokeWidth;

  @override
  void draw(Canvas canvas, double u) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawLine(p1, p2, paint);
  }
}

/// An orbiting planet representation.
class _PlanetItem extends _DrawItem {
  const _PlanetItem({
    required super.depth,
    required this.center,
    required this.color,
    required this.radius,
  });

  final Offset center;
  final Color color;
  final double radius;

  @override
  void draw(Canvas canvas, double u) {
    // 1. Draw glowing outer halo
    final glowShader = RadialGradient(
      colors: [
        Colors.white.withValues(alpha: 0.9),
        color.withValues(alpha: 0.5),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius * 3.0));

    final glowPaint = Paint()..shader = glowShader;
    canvas.drawCircle(center, radius * 3.0, glowPaint);

    // 2. Draw solid planet body
    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius, bodyPaint);

    // 3. Draw bright white highlight center
    final highlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawCircle(center, radius * 0.4, highlightPaint);
  }
}

/// Central core representation.
class _CoreItem extends _DrawItem {
  const _CoreItem({
    required super.depth,
    required this.center,
    required this.color,
    required this.radius,
    required this.isHovered,
  });

  final Offset center;
  final Color color;
  final double radius;
  final bool isHovered;

  @override
  void draw(Canvas canvas, double u) {
    final double glowRadiusMultiplier = isHovered ? 1.4 : 1.1;
    final coreShader = RadialGradient(
      colors: [
        Colors.white,
        color.withValues(alpha: 0.8),
        color.withValues(alpha: 0.2),
        Colors.transparent,
      ],
      stops: const [0.0, 0.28, 0.68, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: radius * glowRadiusMultiplier));

    final corePaint = Paint()..shader = coreShader;
    canvas.drawCircle(center, radius * glowRadiusMultiplier, corePaint);
  }
}

class _OrbitIconPainter extends CustomPainter {
  const _OrbitIconPainter({
    required this.color,
    required this.strokeWidth,
    required this.progress,
    required this.isHovered,
  });

  final Color color;
  final double strokeWidth;
  final double progress;
  final bool isHovered;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final u = size.width / 24; // 1 unit in px

    final List<_DrawItem> drawItems = [];

    // Global rotation angles to rotate the entire gyroscope structure in 3D
    final double globalYaw = progress * 2 * math.pi;
    const double globalPitch = 0.55; // Angle looking slightly down at the structure

    // Helper to rotate local points into global space
    _Vector3 toGlobalSpace(_Vector3 local) {
      return local.rotateY(globalYaw).rotateX(globalPitch);
    }

    // Offset to center on screen
    Offset projectToScreen(_Vector3 v) {
      return Offset(cx + v.x, cy + v.y);
    }

    // 1. Add Central Core (always at local origin 0,0,0)
    final double pulse = math.sin(progress * 2 * math.pi);
    final double baseCoreRadius = u * (4.2 + 0.6 * pulse);
    drawItems.add(_CoreItem(
      depth: 0.0, // Center of local space
      center: Offset(cx, cy),
      color: color,
      radius: baseCoreRadius,
      isHovered: isHovered,
    ));

    // 2. Define the three Rings with distinct orientations
    final double ringRadius = 8.6 * u;
    const int segmentsPerRing = 48;

    // Rings orientations:
    // Ring 0: Horizontal (slight tilt)
    _Vector3 getRing0Local(double angle) {
      final local = _Vector3(ringRadius * math.cos(angle), 0, ringRadius * math.sin(angle));
      return local.rotateX(0.25).rotateZ(0.1);
    }

    // Ring 1: Vertical tilted left
    _Vector3 getRing1Local(double angle) {
      final local = _Vector3(ringRadius * math.cos(angle), ringRadius * math.sin(angle), 0);
      return local.rotateY(math.pi / 4).rotateX(0.4);
    }

    // Ring 2: Vertical tilted right
    _Vector3 getRing2Local(double angle) {
      final local = _Vector3(0, ringRadius * math.cos(angle), ringRadius * math.sin(angle));
      return local.rotateX(math.pi / 4).rotateZ(0.4);
    }

    final ringFunctions = [
      getRing0Local,
      getRing1Local,
      getRing2Local,
    ];

    // Colors mapping for rings to create a rich holographic palette
    final ringColors = [
      AppColors.cyan,
      color, // Brand Indigo
      AppColors.purple,
    ];

    // Build ring segments
    for (int ringIdx = 0; ringIdx < 3; ringIdx++) {
      final getLocalPoint = ringFunctions[ringIdx];
      final Color startColor = ringColors[ringIdx];
      final Color endColor = ringColors[(ringIdx + 1) % 3];

      final List<_Vector3> globalPoints = [];
      final List<Offset> screenPoints = [];

      for (int i = 0; i <= segmentsPerRing; i++) {
        final double angle = (i / segmentsPerRing) * 2 * math.pi;
        final _Vector3 local = getLocalPoint(angle);
        final _Vector3 global = toGlobalSpace(local);
        globalPoints.add(global);
        screenPoints.add(projectToScreen(global));
      }

      // Add segment items
      for (int i = 0; i < segmentsPerRing; i++) {
        final double t = i / segmentsPerRing;
        final Color segmentColor = Color.lerp(startColor, endColor, t)!;
        final double segmentDepth = (globalPoints[i].z + globalPoints[i + 1].z) / 2.0;

        // Visual depth cue: scale segment thickness based on depth
        final double normDepth = (segmentDepth / ringRadius).clamp(-1.0, 1.0);
        final double scale = 0.6 + 0.4 * normDepth;
        final double thickness = strokeWidth * u * scale * (isHovered ? 1.3 : 1.0);

        drawItems.add(_LineSegmentItem(
          depth: segmentDepth,
          p1: screenPoints[i],
          p2: screenPoints[i + 1],
          color: segmentColor.withValues(alpha: isHovered ? 0.95 : 0.8),
          strokeWidth: thickness,
        ));
      }
    }

    // 3. Add Orbiting Planets (1 planet on each ring)
    // Planet 0 orbits Ring 0 (clockwise, speed 1.5x)
    final double angle0 = progress * 2 * math.pi * 1.5;
    final _Vector3 planet0Loc = getRing0Local(angle0);
    final _Vector3 planet0Glob = toGlobalSpace(planet0Loc);
    drawItems.add(_PlanetItem(
      depth: planet0Glob.z,
      center: projectToScreen(planet0Glob),
      color: AppColors.cyan,
      radius: 1.6 * u,
    ));

    // Planet 1 orbits Ring 1 (counter-clockwise, speed 1.1x)
    final double angle1 = -progress * 2 * math.pi * 1.1 + math.pi / 2;
    final _Vector3 planet1Loc = getRing1Local(angle1);
    final _Vector3 planet1Glob = toGlobalSpace(planet1Loc);
    drawItems.add(_PlanetItem(
      depth: planet1Glob.z,
      center: projectToScreen(planet1Glob),
      color: Colors.white,
      radius: 1.4 * u,
    ));

    // Planet 2 orbits Ring 2 (clockwise, speed 0.8x)
    final double angle2 = progress * 2 * math.pi * 0.8 + math.pi;
    final _Vector3 planet2Loc = getRing2Local(angle2);
    final _Vector3 planet2Glob = toGlobalSpace(planet2Loc);
    drawItems.add(_PlanetItem(
      depth: planet2Glob.z,
      center: projectToScreen(planet2Glob),
      color: AppColors.purple,
      radius: 1.5 * u,
    ));

    // 4. Z-Sort items (back to front)
    drawItems.sort((a, b) => a.depth.compareTo(b.depth));

    // 5. Draw all items sequentially
    for (final item in drawItems) {
      item.draw(canvas, u);
    }
  }

  @override
  bool shouldRepaint(_OrbitIconPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.progress != progress ||
      old.isHovered != isHovered;
}
