import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';
import 'package:orbit_app/features/workspaces/domain/entities/workstation_entity.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_state.dart';
import 'package:orbit_app/features/workspaces/presentation/widgets/create_workspace_sheet.dart';

class WorkspaceSwitcherSheet extends StatelessWidget {
  const WorkspaceSwitcherSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const WorkspaceSwitcherSheet(),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.chip.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle for drag
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.chip,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Header
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Switch Workspace',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            
            Flexible(
              child: BlocBuilder<WorkspaceCubit, WorkspaceState>(
                builder: (context, state) {
                  final workstations = state.contextEntity?.workstations ?? [];
                  
                  if (workstations.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No workspaces available',
                          style: TextStyle(color: AppColors.neutral500),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: workstations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ws = workstations[index];
                      final isSelected = state.selectedWorkstation?.id == ws.id;
                      final wsColor = _parseColor(ws.color);

                      return GestureDetector(
                        onTap: () {
                          if (!isSelected) {
                            context.read<WorkspaceCubit>().selectWorkstation(ws);
                          }
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.surfaceRaised.withValues(alpha: 0.8) 
                                : AppColors.surfaceAlt.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected 
                                  ? kOrbitIndigo.withValues(alpha: 0.6) 
                                  : AppColors.borderFaint.withValues(alpha: 0.3),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: wsColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: wsColor.withValues(alpha: 0.3)),
                                ),
                                child: Center(
                                  child: Text(
                                    ws.name.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      color: wsColor,
                                      fontSize: 16,
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
                                        Text(
                                          ws.name,
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.2,
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
                                    if (isSelected)
                                      const Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Text(
                                          'Currently active',
                                          style: TextStyle(
                                            color: AppColors.neutral400,
                                            fontSize: 12,
                                          ),
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
                                  child: const Icon(Icons.check, color: kOrbitIndigo, size: 14),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  CreateWorkspaceSheet.show(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.chip.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: AppColors.neutral400, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Create new workspace',
                        style: TextStyle(
                          color: AppColors.neutral300,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
