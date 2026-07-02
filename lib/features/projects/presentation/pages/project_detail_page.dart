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
import 'package:cached_network_image/cached_network_image.dart';

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
    return BlocListener<ProjectDetailCubit, ProjectDetailState>(
      listener: (context, state) {
        if (state.status == ProjectDetailStatus.deleted) {
          _showCustomSnackBar(
            context: context,
            message: 'Project deleted successfully',
            type: SnackBarType.success,
          );
          context.pop();
        } else if (state.status == ProjectDetailStatus.failure && state.errorMessage != null) {
          final isSoftDeleted = state.errorMessage!.contains('Project deleted');
          _showCustomSnackBar(
            context: context,
            message: state.errorMessage!,
            type: isSoftDeleted ? SnackBarType.warning : SnackBarType.error,
          );
          if (isSoftDeleted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
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
              state.status == ProjectDetailStatus.loading ||
              state.status == ProjectDetailStatus.deleting) {
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
                              if (project.repo != null && project.repo!.trim().isNotEmpty && !['-', '—', '–'].contains(project.repo!.trim()))
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
                                  'Not linked',
                                  style: TextStyle(
                                    color: AppColors.neutral500,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Last Commit
                    if (state.isGithubLoading) ...[
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
                      const _GithubLoadingView(),
                      const SizedBox(height: 24),
                    ] else if (state.githubCommits.isNotEmpty) ...[
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
                                          .first['commit']['author']['date'] as String,
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
                              maxLines: 3,
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
                                        image: CachedNetworkImageProvider(
                                          state
                                              .githubCommits
                                              .first['author']['avatar_url'] as String,
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
                                      .first['commit']['author']['name'] as String,
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
                    ] else ...[
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceAlt,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                (project.repo == null || project.repo!.trim().isEmpty || ['-', '—', '–'].contains(project.repo!.trim()))
                                    ? Icons.link_off_rounded
                                    : Icons.history_rounded,
                                color: AppColors.neutral400,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (project.repo == null || project.repo!.trim().isEmpty || ['-', '—', '–'].contains(project.repo!.trim()))
                                        ? 'No Repository Linked'
                                        : 'No Commits Found',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    (project.repo == null || project.repo!.trim().isEmpty || ['-', '—', '–'].contains(project.repo!.trim()))
                                        ? 'Add a GitHub repository URL to sync commits.'
                                        : 'No recent commits could be found.',
                                    style: const TextStyle(
                                      color: AppColors.neutral500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
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
                              onPressed: () {
                                String? getRepoShortName(String? repoUrl) {
                                  if (repoUrl == null) return null;
                                  try {
                                    final uri = Uri.parse(repoUrl);
                                    final segments = uri.pathSegments;
                                    if (segments.length >= 2) {
                                      return segments[1];
                                    }
                                  } catch (_) {}
                                  return null;
                                }

                                String? getRepoFullName(String? repoUrl) {
                                  if (repoUrl == null) return null;
                                  try {
                                    final uri = Uri.parse(repoUrl);
                                    final segments = uri.pathSegments;
                                    if (segments.length >= 2) {
                                      return '${segments[0]}/${segments[1]}';
                                    }
                                  } catch (_) {}
                                  return null;
                                }

                                showDialog<void>(
                                  context: context,
                                  builder: (dialogContext) {
                                    final controller = TextEditingController();
                                    bool deleteRepo = false;
                                    return StatefulBuilder(
                                      builder: (builderContext, setState) {
                                        final isGithubConnected = state.githubUser != null;
                                        final hasRepo = project.repo != null &&
                                            project.repo!.trim().isNotEmpty &&
                                            !['-', '—', '–'].contains(project.repo!.trim());
                                        final showDeleteRepoOption = hasRepo && isGithubConnected;
                                        
                                        final repoShortName = getRepoShortName(project.repo);
                                        final repoFullName = getRepoFullName(project.repo);
                                        
                                        final requiredText = (deleteRepo && showDeleteRepoOption && repoShortName != null) ? repoShortName : project.name;
                                        final isMatch = controller.text == requiredText;
                                        
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                                          child: Container(
                                            constraints: const BoxConstraints(maxWidth: 400),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0F1014),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: AppColors.borderCard, width: 1.5),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.5),
                                                  blurRadius: 24,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(24),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.rose500.withValues(alpha: 0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.warning_amber_rounded,
                                                        color: AppColors.rose,
                                                        size: 24,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    const Text(
                                                      'Delete project',
                                                      style: TextStyle(
                                                        color: AppColors.white,
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w700,
                                                        letterSpacing: -0.3,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                const Text(
                                                  'Are you absolutely sure you want to delete this project? This will soft-delete the project and hide all of its tasks from the workspace.',
                                                  style: TextStyle(
                                                    color: AppColors.neutral400,
                                                    fontSize: 13,
                                                    height: 1.5,
                                                  ),
                                                ),
                                                
                                                if (showDeleteRepoOption) ...[
                                                  const SizedBox(height: 16),
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        deleteRepo = !deleteRepo;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF13141A),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: AppColors.borderCard),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            deleteRepo
                                                                ? Icons.check_box_rounded
                                                                : Icons.check_box_outline_blank_rounded,
                                                            color: deleteRepo
                                                                ? AppColors.rose500
                                                                : AppColors.neutral600,
                                                            size: 20,
                                                          ),
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
                                                  ),
                                                ] else if (hasRepo && !isGithubConnected) ...[
                                                  const SizedBox(height: 16),
                                                  Container(
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.amber.withValues(alpha: 0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                                                    ),
                                                    child: const Row(
                                                      children: [
                                                        Icon(Icons.info_outline_rounded, color: AppColors.amber, size: 16),
                                                        SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            'GitHub not connected. Reconnect GitHub in settings to delete repository.',
                                                            style: TextStyle(color: AppColors.amber, fontSize: 11, height: 1.3),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                
                                                const SizedBox(height: 16),
                                                RichText(
                                                  text: TextSpan(
                                                    style: const TextStyle(
                                                      color: AppColors.neutral400,
                                                      fontSize: 13,
                                                      height: 1.5,
                                                    ),
                                                    children: [
                                                      const TextSpan(text: 'Type '),
                                                      TextSpan(
                                                        text: requiredText,
                                                        style: const TextStyle(
                                                          color: AppColors.white,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      const TextSpan(text: ' to confirm.'),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                TextField(
                                                  controller: controller,
                                                  onChanged: (_) => setState(() {}),
                                                  style: const TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 14,
                                                  ),
                                                  decoration: InputDecoration(
                                                    hintText: 'Enter confirmation text',
                                                    hintStyle: const TextStyle(
                                                      color: AppColors.neutral600,
                                                      fontSize: 14,
                                                    ),
                                                    filled: true,
                                                    fillColor: const Color(0xFF13141A),
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: const BorderSide(color: AppColors.borderCard),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: const BorderSide(color: AppColors.borderCard),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: const BorderSide(color: AppColors.rose, width: 1.5),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 24),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () => Navigator.pop(dialogContext),
                                                        child: Container(
                                                          height: 44,
                                                          decoration: BoxDecoration(
                                                            color: Colors.transparent,
                                                            borderRadius: BorderRadius.circular(8),
                                                            border: Border.all(color: AppColors.borderCard),
                                                          ),
                                                          child: const Center(
                                                            child: Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                color: AppColors.neutral300,
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: isMatch
                                                            ? () {
                                                                Navigator.pop(dialogContext);
                                                                context.read<ProjectDetailCubit>().deleteProject(
                                                                  project.shortId,
                                                                  workstationId: deleteRepo && showDeleteRepoOption ? (project.workstationId.isNotEmpty ? project.workstationId : context.read<WorkspaceCubit>().state.selectedWorkstation?.id) : null,
                                                                  repoFullName: deleteRepo && showDeleteRepoOption ? repoFullName : null,
                                                                );
                                                              }
                                                            : null,
                                                        child: AnimatedContainer(
                                                          duration: const Duration(milliseconds: 200),
                                                          height: 44,
                                                          decoration: BoxDecoration(
                                                            color: isMatch
                                                                ? AppColors.rose
                                                                : AppColors.rose.withValues(alpha: 0.2),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                color: isMatch
                                                                    ? AppColors.white
                                                                    : AppColors.white.withValues(alpha: 0.3),
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ));
                                      },
                                    );
                                  },
                                );
                              },
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
                        onPressed: () {
                          context.pushNamed('projectEdit', extra: project).then((updated) {
                            if (updated == true) {
                              final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                              if (wsId != null) {
                                context.read<ProjectDetailCubit>().fetchProjectDetail(wsId, project.id);
                              }
                            }
                          });
                        },
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
    ),
    );
  }
}

class _GithubLoadingView extends StatefulWidget {
  const _GithubLoadingView();

  @override
  State<_GithubLoadingView> createState() => _GithubLoadingViewState();
}

class _GithubLoadingViewState extends State<_GithubLoadingView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSkeleton(double width, double height, {double borderRadius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.neutral700,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: child,
        );
      },
      child: Container(
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
                _buildSkeleton(60, 24, borderRadius: 4),
                const SizedBox(width: 12),
                _buildSkeleton(80, 14),
              ],
            ),
            const SizedBox(height: 16),
            _buildSkeleton(double.infinity, 14),
            const SizedBox(height: 8),
            _buildSkeleton(200, 14),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSkeleton(16, 16, borderRadius: 8),
                const SizedBox(width: 8),
                _buildSkeleton(100, 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum SnackBarType { success, warning, error }

void _showCustomSnackBar({
  required BuildContext context,
  required String message,
  required SnackBarType type,
}) {
  final Color borderColor;
  final Color iconBgColor;
  final Color iconColor;
  final IconData icon;

  switch (type) {
    case SnackBarType.success:
      borderColor = AppColors.emerald.withValues(alpha: 0.3);
      iconBgColor = AppColors.emerald.withValues(alpha: 0.1);
      iconColor = AppColors.emerald;
      icon = Icons.check_circle_outline_rounded;
      break;
    case SnackBarType.warning:
      borderColor = AppColors.amber.withValues(alpha: 0.3);
      iconBgColor = AppColors.amber.withValues(alpha: 0.1);
      iconColor = AppColors.amber;
      icon = Icons.warning_amber_rounded;
      break;
    case SnackBarType.error:
      borderColor = AppColors.rose.withValues(alpha: 0.3);
      iconBgColor = AppColors.rose.withValues(alpha: 0.1);
      iconColor = AppColors.rose;
      icon = Icons.error_outline_rounded;
      break;
  }

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1014),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
