import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/app/di/injection.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/features/projects/presentation/cubit/project_detail_cubit.dart';
import 'package:orbit_app/features/projects/presentation/cubit/project_detail_state.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher_string.dart';

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    final workstationId = context
        .read<WorkspaceCubit>()
        .state
        .selectedWorkstation
        ?.id;
    return BlocProvider(
      create: (context) {
        final cubit = sl<ProjectDetailCubit>();
        if (workstationId != null) {
          cubit.fetchProjectDetail(workstationId, projectId);
        }
        return cubit;
      },
      child: const _ProjectDetailView(),
    );
  }
}

class _ProjectDetailView extends StatelessWidget {
  const _ProjectDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
                    builder: (context, state) {
                      final name = state.project?.name ?? 'Loading...';
                      final shortId = state.project?.shortId ?? '...';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'WORKSPACE  /  PROJECTS  /  $shortId',
                            style: const TextStyle(
                              color: AppColors.neutral500,
                              fontSize: 10,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131313), // dark black
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderCard),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.neutral400,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
        builder: (context, state) {
          if (state.status == ProjectDetailStatus.initial ||
              state.status == ProjectDetailStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brand),
            );
          }

          if (state.status == ProjectDetailStatus.failure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Failed to load project details',
                style: const TextStyle(color: AppColors.rose500),
              ),
            );
          }

          final project = state.project;
          if (project == null) return const SizedBox.shrink();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  children: [
                    // Divider
                    Container(height: 1, color: AppColors.borderCard),
                    const SizedBox(height: 24),

                    // Status & Client
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF003366,
                            ).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFF0055AA)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00B4D8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'IN PROGRESS',
                                style: TextStyle(
                                  color: Color(0xFF00B4D8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            project.client ?? 'Unknown',
                            style: const TextStyle(
                              color: AppColors.neutral400,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project.description ?? 'No description provided.',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Client & Logged Hours
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CLIENT / OWNER',
                                style: TextStyle(
                                  color: AppColors.neutral500,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                project.client ?? 'Unknown',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TIME LOGGED',
                                style: TextStyle(
                                  color: AppColors.neutral500,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${project.hoursLogged}h',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Start Date & End Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'START DATE',
                                style: TextStyle(
                                  color: AppColors.neutral500,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                project.startDate != null
                                    ? project.startDate!
                                          .toIso8601String()
                                          .split('T')[0]
                                    : '—',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'END DATE',
                                style: TextStyle(
                                  color: AppColors.neutral500,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                project.endDate != null
                                    ? project.endDate!.toIso8601String().split(
                                        'T',
                                      )[0]
                                    : '—',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Budget & Repo
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'BUDGET',
                                style: TextStyle(
                                  color: AppColors.neutral500,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                project.budget ?? '—',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'REPOSITORY',
                                style: TextStyle(
                                  color: AppColors.neutral500,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (project.repo != null && project.repo!.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    launchUrlString(project.repo!);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF131313),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.borderCard),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.code, color: AppColors.white, size: 14),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            project.repo!.replaceAll('https://github.com/', ''),
                                            style: const TextStyle(
                                              color: AppColors.white,
                                              fontSize: 12,
                                              fontFamily: 'monospace',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                const Text(
                                  '—',
                                  style: TextStyle(color: AppColors.white),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Last Commit
                    if (state.githubCommits.isNotEmpty) ...[
                      const Text(
                        'LAST COMMIT',
                        style: TextStyle(
                          color: AppColors.neutral500,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF131313),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderCard),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0066CC,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    (state.githubCommits.first['sha'] as String)
                                        .substring(0, 7),
                                    style: const TextStyle(
                                      color: Color(0xFF4DB8FF),
                                      fontSize: 12,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  timeago.format(
                                    DateTime.parse(
                                      state
                                          .githubCommits
                                          .first['commit']['author']['date'],
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.neutral500,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              (state.githubCommits.first['commit']['message']
                                      as String)
                                  .split('\n')[0],
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 13,
                                height: 1.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (state.githubCommits.first['author'] !=
                                        null &&
                                    state
                                            .githubCommits
                                            .first['author']['avatar_url'] !=
                                        null)
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          state
                                              .githubCommits
                                              .first['author']['avatar_url'],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: AppColors.neutral500,
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  state
                                      .githubCommits
                                      .first['commit']['author']['name'],
                                  style: const TextStyle(
                                    color: AppColors.neutral500,
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Tech Stack
                    if (project.stack.isNotEmpty) ...[
                      const Text(
                        'TECH STACK',
                        style: TextStyle(
                          color: AppColors.neutral500,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: project.stack
                            .map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.borderCard,
                                  ),
                                ),
                                child: Text(
                                  t,
                                  style: const TextStyle(
                                    color: AppColors.neutral400,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Tasks
                    const Text(
                      'TASKS',
                      style: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${project.tasksCount} total · ${project.openTasks} open · ${project.tasksCount - project.openTasks} done',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Hours Logged
                    const Text(
                      'HOURS',
                      style: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'LOGGED ',
                          style: TextStyle(
                            color: AppColors.neutral500,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Text(
                          '${project.hoursLogged}h',
                          style: const TextStyle(
                            color: AppColors.neutral400,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Delete Project Zone
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.rose500.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Delete this project',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'This project and all its tasks will be soft-deleted and hidden from your workspace. No data is permanently removed.',
                            style: TextStyle(
                              color: AppColors.neutral400,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F1209), // Dark amber tint
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF4D3800)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${project.openTasks} open tasks will be soft-deleted along with this project',
                                        style: const TextStyle(color: AppColors.amber, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${project.tasksCount - project.openTasks} completed tasks will be soft-deleted along with this project',
                                        style: const TextStyle(color: AppColors.amber, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131313),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderCard),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_box_outline_blank_rounded, color: AppColors.neutral600, size: 20),
                                const SizedBox(width: 12),
                                const Icon(Icons.code, color: AppColors.neutral400, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Also delete GitHub repository',
                                        style: TextStyle(color: AppColors.neutral400, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (project.repo != null && project.repo!.isNotEmpty)
                                        Text(
                                          project.repo!.replaceAll('https://github.com/', ''),
                                          style: const TextStyle(color: AppColors.neutral500, fontSize: 10, fontFamily: 'monospace'),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () {},
                              child: const Text('Delete project', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom Bar
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.borderCard)),
                ),
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0099FF),
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {},
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_outlined, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Edit project',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
