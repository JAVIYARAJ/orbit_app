import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workstation_entity.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_state.dart';
import 'package:orbit_app/features/workspaces/presentation/widgets/create_workspace_sheet.dart';

class WorkspaceSelectionPage extends StatefulWidget {
  const WorkspaceSelectionPage({super.key});

  @override
  State<WorkspaceSelectionPage> createState() => _WorkspaceSelectionPageState();
}

class _WorkspaceSelectionPageState extends State<WorkspaceSelectionPage> {
  @override
  void initState() {
    super.initState();
    context.read<WorkspaceCubit>().fetchContext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDeep,
      body: Stack(
        children: [
          // Radial glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kOrbitIndigo.withValues(alpha: 0.15),
                    AppColors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: BlocListener<WorkspaceCubit, WorkspaceState>(
              listener: (context, state) {
                if (state.status == WorkspaceStatus.loaded && state.contextEntity?.activeWorkstationId != null) {
                  context.go('/dashboard');
                }
              },
              child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
                builder: (context, state) {
                if (state.status == WorkspaceStatus.loading ||
                    state.status == WorkspaceStatus.initial ||
                    (state.status == WorkspaceStatus.loaded &&
                        state.contextEntity?.activeWorkstationId != null)) {
                  return const Center(
                    child: CircularProgressIndicator(color: kOrbitIndigo),
                  );
                }

                if (state.status == WorkspaceStatus.error) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? 'Failed to load workspaces',
                      style: const TextStyle(color: AppColors.rose500),
                    ),
                  );
                }

                final workstations = state.contextEntity?.workstations ?? [];

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _LogoHeader(),
                          const SizedBox(height: 48),
                          
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppColors.white, AppColors.neutral300],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              workstations.isEmpty ? 'Get started' : 'Select workspace',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            workstations.isEmpty 
                                ? 'Create your first workspace to begin using Orbit'
                                : 'Choose a workspace to continue with Orbit',
                            style: const TextStyle(
                              color: AppColors.neutral400,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (workstations.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.borderFaint.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: kOrbitIndigo.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.workspaces_outline,
                                        color: kOrbitIndigo,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No workspaces found',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Create a new workspace to get started.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.neutral400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: workstations.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final ws = workstations[index];
                                final isSelected = state.selectedWorkstation?.id == ws.id;
                                final wsColor = _parseColor(ws.color);

                                return _WorkspaceCard(
                                  ws: ws,
                                  isSelected: isSelected,
                                  color: wsColor,
                                  onTap: () {
                                    context.read<WorkspaceCubit>().selectWorkstation(ws);
                                    context.go('/dashboard');
                                  },
                                );
                              },
                            ),
                          
                          const SizedBox(height: 24),
                          
                          // Create new workspace button
                          GestureDetector(
                            onTap: () => CreateWorkspaceSheet.show(
                              context,
                              onSuccess: () => context.go('/dashboard'),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.borderFaint.withValues(alpha: 0.5),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: AppColors.neutral400, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Create new workspace',
                                    style: TextStyle(
                                      color: AppColors.neutral300,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorCode) {
    try {
      if (colorCode.startsWith('#')) {
        return Color(int.parse(colorCode.substring(1, 7), radix: 16) + 0xFF000000);
      }
      return kOrbitIndigo;
    } catch (_) {
      return kOrbitIndigo;
    }
  }
}

class _WorkspaceCard extends StatelessWidget {
  const _WorkspaceCard({
    required this.ws,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final WorkstationEntity ws;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceRaised.withValues(alpha: 0.8) : AppColors.surfaceAlt.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kOrbitIndigo.withValues(alpha: 0.6) : AppColors.borderFaint.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kOrbitIndigo.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  ws.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          ws.name,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (ws.role.toLowerCase() == 'owner')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.emerald.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Text(
                            'OWNER',
                            style: TextStyle(
                              color: AppColors.emerald400,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected ? 'Currently active' : 'Click to launch',
                    style: TextStyle(
                      color: isSelected ? AppColors.neutral300 : AppColors.neutral500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: kOrbitIndigo.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: kOrbitIndigo, size: 16),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.neutral500, size: 24),
          ],
        ),
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.surfaceRaised, AppColors.background],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: kOrbitIndigo.withValues(alpha: 0.20),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: kOrbitIndigo.withValues(alpha: 0.40),
              width: 1.5,
            ),
          ),
          child: const Center(child: OrbitIcon(size: 18, strokeWidth: 1.5)),
        ),
        const SizedBox(width: 8),
        const Text(
          'Orbit',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
