import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/router/app_router.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';
import 'package:orbit_app/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:orbit_app/features/authentication/presentation/state/auth_state.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';

/// Splash screen — pixel-faithful Flutter port of the Orbit React design.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scaleAnim = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    _decideNavigation();
  }

  /// Holds the splash for a minimum display time, waits for the session to
  /// resolve, then routes to the dashboard (signed in) or login (signed out).
  Future<void> _decideNavigation() async {
    await Future<void>.delayed(const Duration(milliseconds: 2600));
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Stack(
        children: [
          // Radial glow
          Center(
            child: Container(
              width: 420,
              height: 420,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kOrbitIndigo.withValues(alpha: 0.28),
                    AppColors.transparent,
                  ],
                  stops: const [0.0, 0.65],
                ),
              ),
            ),
          ),

          // Main content
          FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo container
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow halo
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kOrbitIndigo.withValues(alpha: 0.15),
                            ),
                          ),
                          // Icon circle
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceAlt,
                              border: Border.all(
                                color: kOrbitIndigo.withValues(alpha: 0.30),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: OrbitIcon(size: 72, strokeWidth: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Orbit',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Your self-hosted developer OS',
                      style: TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 14,
                        letterSpacing: 0.3,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Version tag
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: const Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.neutral600,
                  fontSize: 12,
                  fontFamily: 'monospace',
                  letterSpacing: 0.2,
                  height: 1.33,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
