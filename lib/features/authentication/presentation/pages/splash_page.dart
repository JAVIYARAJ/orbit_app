import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/router/app_router.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';
import 'package:orbit_app/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:orbit_app/features/authentication/presentation/state/auth_state.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';

/// Ultra-creative, high-tech holographic sci-fi splash screen for Orbit Developer OS.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _loopController;

  late final Animation<double> _bgFade;
  late final Animation<double> _ringsScale;
  late final Animation<double> _coreScale;
  late final Animation<double> _textFade;
  late final Animation<double> _statusFade;

  int _statusIndex = 0;
  final List<String> _statusMessages = [
    'INITIALIZING DEV CORE...',
    'CONNECTING WORKSPACE ENGINE...',
    'SYNCING QUANTUM NODES...',
    'ORBIT KERNEL READY',
  ];

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation timeline (1200 ms total)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _bgFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _ringsScale = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.65, curve: Curves.easeOutBack),
    );

    _coreScale = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.30, 0.80, curve: Curves.elasticOut),
    );

    _textFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.50, 0.90, curve: Curves.easeOut),
    );

    _statusFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    // 2. Continuous ambient loop (10s loop)
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _entranceController.forward();

    // Status ticker sequence
    _startStatusSequence();

    // Navigation decision
    _decideNavigation();
  }

  Future<void> _startStatusSequence() async {
    for (int i = 1; i < _statusMessages.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _statusIndex = i;
      });
    }
  }

  /// Holds the splash for a minimum display time, waits for the session to
  /// resolve, then routes to the dashboard (signed in) or login (signed out).
  Future<void> _decideNavigation() async {
    await Future<void>.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    final cubit = context.read<AuthCubit>();
    var status = cubit.state.status;
    if (status == AuthStatus.unknown) {
      final resolved =
          await cubit.stream.firstWhere((s) => s.status != AuthStatus.unknown);
      status = resolved.status;
    }
    if (!mounted) return;

    if (status == AuthStatus.authenticated) {
      final wsCubit = context.read<WorkspaceCubit>();
      await wsCubit.fetchContext();
      if (!mounted) return;
      if (wsCubit.state.contextEntity?.activeWorkstationId != null) {
        context.go(AppRoutes.dashboard);
        return;
      }
    }

    context.go(
      status == AuthStatus.authenticated
          ? AppRoutes.selectWorkspace
          : AppRoutes.login,
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: AnimatedBuilder(
        animation: Listenable.merge([_entranceController, _loopController]),
        builder: (context, child) {
          final loopVal = _loopController.value;

          return Stack(
            children: [
              // Layer 1: Cosmic Starfield & Ambient Nebula Background
              FadeTransition(
                opacity: _bgFade,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _CosmicStarfieldPainter(progress: loopVal),
                ),
              ),

              // Layer 2: Center Holographic Core & Energy Rings
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Interactive Holographic Ring & Icon Stack
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Holographic Energy Rings
                          Transform.scale(
                            scale: _ringsScale.value,
                            child: CustomPaint(
                              size: const Size(240, 240),
                              painter: _HolographicRingsPainter(
                                progress: loopVal,
                              ),
                            ),
                          ),

                          // Central Orbit 3D Gyroscopic Icon Container
                          Transform.scale(
                            scale: _coreScale.value,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceAlt.withValues(alpha: 0.85),
                                border: Border.all(
                                  color: AppColors.cyan.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: kOrbitIndigo.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 4,
                                  ),
                                  BoxShadow(
                                    color: AppColors.cyan.withValues(alpha: 0.3),
                                    blurRadius: 60,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: OrbitIcon(
                                  size: 76,
                                  strokeWidth: 1.8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Layer 3: Title & Subtitle with Animated Metallic Shimmer
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Shimmer Branding Title
                          ShaderMask(
                            shaderCallback: (bounds) {
                              final double shimmerPos = (loopVal * 3) % 2.0 - 0.5;
                              return LinearGradient(
                                colors: const [
                                  AppColors.white,
                                  AppColors.cyan,
                                  AppColors.brandSoft,
                                  AppColors.purple,
                                  AppColors.white,
                                ],
                                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                transform: GradientRotation(shimmerPos * math.pi),
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'O R B I T',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 8.0,
                                height: 1,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Your self-hosted developer OS',
                            style: TextStyle(
                              color: AppColors.neutral300,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Layer 4: Sci-Fi Status Terminal Readout & Energy Progress Line
                    FadeTransition(
                      opacity: _statusFade,
                      child: SizedBox(
                        width: 280,
                        child: Column(
                          children: [
                            // Status text
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Row(
                                key: ValueKey<int>(_statusIndex),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '> ',
                                    style: TextStyle(
                                      color: AppColors.cyan,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _statusMessages[_statusIndex],
                                    style: TextStyle(
                                      color: _statusIndex ==
                                              _statusMessages.length - 1
                                          ? AppColors.emerald400
                                          : AppColors.neutral400,
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Energy Progress Line
                            Container(
                              height: 2,
                              width: 220,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(1),
                              ),
                              child: Stack(
                                children: [
                                  FractionallySizedBox(
                                    widthFactor: ((_statusIndex + 1) /
                                            _statusMessages.length)
                                        .clamp(0.2, 1.0),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 400),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1),
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.brand,
                                            AppColors.cyan,
                                            AppColors.emerald400,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.cyan
                                                .withValues(alpha: 0.6),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Layer 5: Futuristic Bottom Badge with Pulsing Status Indicator
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _statusFade,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.borderCard,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Live Pulsing Green Dot
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.emerald400,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emerald400.withValues(
                                    alpha: 0.4 +
                                        0.4 *
                                            math.sin(
                                                loopVal * 2 * math.pi * 2),
                                  ),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'ORBIT OS v1.0.0',
                            style: TextStyle(
                              color: AppColors.neutral400,
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Custom Painter: Cosmic Deep Space Starfield & Nebulae ───────────────────────
class _CosmicStarfieldPainter extends CustomPainter {
  _CosmicStarfieldPainter({required this.progress}) {
    // Generate deterministic starfield positions
    final rand = math.Random(42);
    for (int i = 0; i < 50; i++) {
      _stars.add(_Star(
        x: rand.nextDouble(),
        y: rand.nextDouble(),
        size: 0.8 + rand.nextDouble() * 2.2,
        alpha: 0.2 + rand.nextDouble() * 0.7,
        speed: 0.2 + rand.nextDouble() * 0.8,
      ));
    }
  }

  final double progress;
  final List<_Star> _stars = [];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Draw Nebulae Glow Blobs
    final pulse = math.sin(progress * 2 * math.pi);

    final nebula1 = RadialGradient(
      colors: [
        kOrbitIndigo.withValues(alpha: 0.30 + 0.05 * pulse),
        AppColors.purple.withValues(alpha: 0.12),
        AppColors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(
      center: Offset(cx + math.sin(progress * 2 * math.pi) * 40, cy - 20),
      radius: size.width * 0.5,
    ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = nebula1);

    final nebula2 = RadialGradient(
      colors: [
        AppColors.cyan.withValues(alpha: 0.20 + 0.05 * math.cos(progress * 2 * math.pi)),
        AppColors.transparent,
      ],
      stops: const [0.0, 0.8],
    ).createShader(Rect.fromCircle(
      center: Offset(cx - 60, cy + 80),
      radius: size.width * 0.4,
    ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..shader = nebula2);

    // 2. Draw Twinkling & Drifting Starfield
    final starPaint = Paint()..style = PaintingStyle.fill;

    for (final star in _stars) {
      final double dy = (star.y - progress * 0.05 * star.speed) % 1.0;
      final double starX = star.x * size.width;
      final double starY = dy * size.height;
      final double twinkle = 0.5 + 0.5 * math.sin((progress * star.speed * 20) + star.x * 10);

      starPaint.color = Colors.white.withValues(alpha: (star.alpha * twinkle).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(starX, starY), star.size, starPaint);
    }
  }

  @override
  bool shouldRepaint(_CosmicStarfieldPainter old) => old.progress != progress;
}

class _Star {
  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.alpha,
    required this.speed,
  });

  final double x;
  final double y;
  final double size;
  final double alpha;
  final double speed;
}

// ── Custom Painter: Concentric Holographic Energy Rings ───────────────────────
class _HolographicRingsPainter extends CustomPainter {
  _HolographicRingsPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    // Ring 1: Outer Dotted Tech Arc (Clockwise)
    final outerRadius = size.width * 0.46;
    final outerAngle = progress * 2 * math.pi;

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.cyan.withValues(alpha: 0.35);

    for (int i = 0; i < 12; i++) {
      final a = outerAngle + (i / 12) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        a,
        0.25,
        false,
        outerPaint,
      );
    }

    // Ring 2: Middle Segmented Energy Arc (Counter-Clockwise)
    final midRadius = size.width * 0.38;
    final midAngle = -progress * 2 * math.pi * 1.5;

    final midShader = SweepGradient(
      colors: [
        AppColors.brand.withValues(alpha: 0.0),
        AppColors.cyan.withValues(alpha: 0.8),
        AppColors.purple.withValues(alpha: 0.6),
        AppColors.brand.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
      transform: GradientRotation(midAngle),
    ).createShader(Rect.fromCircle(center: center, radius: midRadius));

    final midPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..shader = midShader;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: midRadius),
      0,
      2 * math.pi,
      false,
      midPaint,
    );

    // Ring 3: Inner High-Tech Orbital Accents (Clockwise, 2.5x)
    final innerRadius = size.width * 0.30;
    final innerAngle = progress * 2 * math.pi * 2.5;

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.emerald400.withValues(alpha: 0.5);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      innerAngle,
      math.pi / 3,
      false,
      innerPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      innerAngle + math.pi,
      math.pi / 3,
      false,
      innerPaint,
    );

    // Radiant Energy Particle Nodes
    final nodePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final double angle = outerAngle + (i * math.pi / 2);
      final px = cx + outerRadius * math.cos(angle);
      final py = cy + outerRadius * math.sin(angle);

      nodePaint.color = AppColors.cyan.withValues(alpha: 0.9);
      canvas.drawCircle(Offset(px, py), 2.5, nodePaint);

      nodePaint.color = Colors.white.withValues(alpha: 0.6);
      canvas.drawCircle(Offset(px, py), 1.2, nodePaint);
    }
  }

  @override
  bool shouldRepaint(_HolographicRingsPainter old) => old.progress != progress;
}
