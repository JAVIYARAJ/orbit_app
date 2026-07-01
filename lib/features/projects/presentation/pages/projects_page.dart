import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/app/di/injection.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/features/projects/presentation/cubit/projects_bloc.dart';
import 'package:orbit_app/features/projects/presentation/cubit/projects_event.dart';
import 'package:orbit_app/features/projects/presentation/cubit/projects_state.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_state.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workstationId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
    return BlocProvider(
      create: (context) {
        final bloc = sl<ProjectsBloc>();
        if (workstationId != null) {
          bloc.add(FetchProjectsEvent(workstationId));
        }
        return bloc;
      },
      child: BlocListener<WorkspaceCubit, WorkspaceState>(
        listenWhen: (previous, current) => 
            previous.selectedWorkstation?.id != current.selectedWorkstation?.id,
        listener: (context, state) {
          final newWsId = state.selectedWorkstation?.id;
          if (newWsId != null) {
            context.read<ProjectsBloc>().add(FetchProjectsEvent(newWsId));
          }
        },
        child: const _ProjectsView(),
      ),
    );
  }
}

class _ProjectsView extends StatefulWidget {
  const _ProjectsView();

  @override
  State<_ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<_ProjectsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            _SearchBar(
              controller: _searchController,
              onChanged: (val) => context.read<ProjectsBloc>().add(SearchProjectsEvent(val)),
            ),
            Expanded(
              child: BlocBuilder<ProjectsBloc, ProjectsState>(
                builder: (context, state) {
                  if (state.status == ProjectsStatus.initial || (state.status == ProjectsStatus.loading && state.projects.isEmpty)) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.brand));
                  }

                  if (state.status == ProjectsStatus.error) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Failed to load projects',
                        style: const TextStyle(color: AppColors.rose500),
                      ),
                    );
                  }

                  final allProjects = state.projects;
                  final isSearching = state.searchQuery.isNotEmpty;
                  final queryLower = state.searchQuery.toLowerCase();
                  
                  final projects = isSearching 
                      ? allProjects.where((p) => p.name.toLowerCase().contains(queryLower) || (p.description?.toLowerCase().contains(queryLower) ?? false)).toList()
                      : allProjects;

                  if (allProjects.isEmpty && !isSearching) {
                    return const Center(
                      child: Text(
                        'No projects found',
                        style: TextStyle(color: AppColors.neutral500),
                      ),
                    );
                  }

                  if (projects.isEmpty && isSearching) {
                    return const Center(
                      child: Text(
                        'No projects match your search',
                        style: TextStyle(color: AppColors.neutral500),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                      if (wsId != null) {
                        context.read<ProjectsBloc>().add(FetchProjectsEvent(wsId));
                      }
                    },
                    color: AppColors.brand,
                    backgroundColor: AppColors.surfaceAlt,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      itemCount: projects.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        if (index == projects.length) {
                          return isSearching ? const SizedBox.shrink() : const _ArchivedButton();
                        }
                        
                        final project = projects[index];
                        // Just a mock way to assign colors based on shortId length for variety
                        final colorList = [AppColors.brand, AppColors.teal, AppColors.amber600, AppColors.purple600, AppColors.rose600];
                        final color = colorList[project.shortId.length % colorList.length];

                        return _ProjectCard(
                          id: project.id,
                          title: project.name,
                          description: project.description ?? 'No description provided.',
                          color: color,
                          progress: project.progress / 100, // API returns 0-100
                          tags: project.stack,
                          updatedAt: project.updatedAt != null ? timeago.format(project.updatedAt!) : 'Unknown',
                          avatars: [
                            _Avatar(
                              label: project.client != null && project.client!.isNotEmpty ? project.client!.substring(0, 1).toUpperCase() : 'U',
                              color: color,
                              isDarkText: false,
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<ProjectsBloc, ProjectsState>(
            builder: (context, state) {
              final activeCount = state.projects.where((p) => p.status != 'archived').length;
              final archivedCount = state.projects.where((p) => p.status == 'archived').length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Projects',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$activeCount active · $archivedCount archived',
                    style: const TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              );
            },
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.add_rounded, color: AppColors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.neutral500, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search projects…',
                  hintStyle: TextStyle(
                    color: AppColors.neutral500,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(Icons.close_rounded, color: AppColors.neutral500, size: 18),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar {
  const _Avatar({
    required this.label,
    required this.color,
    required this.isDarkText,
  });
  final String label;
  final Color color;
  final bool isDarkText;
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.id,
    required this.title,
    required this.description,
    required this.color,
    required this.progress,
    required this.tags,
    required this.updatedAt,
    required this.avatars,
  });

  final String id;
  final String title;
  final String description;
  final Color color;
  final double progress;
  final List<String> tags;
  final String updatedAt;
  final List<_Avatar> avatars;

  @override
  Widget build(BuildContext context) {
    // In a real scenario, this would come from the project status
    final String statusText = progress == 1.0 ? 'COMPLETED' : 'IN PROGRESS';
    final Color statusColor = const Color(0xFF00B4D8); // Cyan

    return GestureDetector(
      onTap: () async {
        await context.push('/projects/detail/$id');
        if (context.mounted) {
          final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
          if (wsId != null) {
            context.read<ProjectsBloc>().add(FetchProjectsEvent(wsId));
          }
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface, // Use surface instead of surfaceAlt for darker bg
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderCard),
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left color stripe
              Container(width: 4, color: color), // The dynamic color or cyan

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Header: Client/Category & Status Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'PERSONAL', // Placeholder for client/category
                            style: TextStyle(
                              color: AppColors.neutral500,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: statusColor,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  statusText,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      
                      // Subtitle / Client (Mocking 'Personal' like the image)
                      const Text(
                        'Personal',
                        style: TextStyle(
                          color: AppColors.neutral400,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.neutral400,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      if (tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: tags
                              .map((tag) => _TagChip(label: tag))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Divider
                      Container(
                        height: 1,
                        color: AppColors.borderCard,
                      ),
                      const SizedBox(height: 12),

                      // Footer: Timestamps and Stats (Mocking similar to image)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Updated $updatedAt',
                            style: const TextStyle(
                              color: AppColors.neutral500,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${(progress * 100).toInt()}% progress',
                                style: const TextStyle(
                                  color: AppColors.neutral400,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
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
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.transparent, // Transparent background as per image
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderCard), // Outline border
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.neutral400,
          fontSize: 11,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

class _ArchivedButton extends StatelessWidget {
  const _ArchivedButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, state) {
        final archivedCount = state.projects.where((p) => p.status == 'archived').length;
        if (archivedCount == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderCard),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Archived Projects',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.chip,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$archivedCount',
                      style: const TextStyle(color: AppColors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.neutral500,
                size: 18,
              ),
            ],
          ),
        );
      },
    );
  }
}
