import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/di/injection.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'package:orbit_app/features/tasks/presentation/cubit/tasks_bloc.dart';
import 'package:orbit_app/features/tasks/presentation/cubit/tasks_event.dart';
import 'package:orbit_app/features/tasks/presentation/cubit/tasks_state.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_state.dart';
import 'package:orbit_app/app/router/app_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';


class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workstationId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
    return BlocProvider(
      create: (context) {
        final bloc = sl<TasksBloc>();
        if (workstationId != null) {
          bloc.add(FetchTasksEvent(workstationId));
        }
        return bloc;
      },
      child: BlocListener<WorkspaceCubit, WorkspaceState>(
        listenWhen: (previous, current) => 
            previous.selectedWorkstation?.id != current.selectedWorkstation?.id,
        listener: (context, state) {
          final newWsId = state.selectedWorkstation?.id;
          if (newWsId != null) {
            context.read<TasksBloc>().add(FetchTasksEvent(newWsId));
          }
        },
        child: const _TasksView(),
      ),
    );
  }
}

class _TasksView extends StatefulWidget {
  const _TasksView();

  @override
  State<_TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<_TasksView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _parseColor(String colorString) {
    try {
      final hexCode = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return AppColors.neutral400; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              taskCount: context.watch<TasksBloc>().state.tasks.where((t) => t.parentTaskId == null).length,
              totalCount: context.watch<TasksBloc>().state.tasks.where((t) => t.parentTaskId == null).length,
            ),
            const _FilterBar(),
            const SizedBox(height: 8),
            _SearchBar(
              controller: _searchController,
              onChanged: (val) => context.read<TasksBloc>().add(SearchTasksEvent(val)),
            ),
            Expanded(
              child: BlocBuilder<TasksBloc, TasksState>(
                builder: (context, state) {
                  if (state.status == TasksStatus.initial || (state.status == TasksStatus.loading && state.tasks.isEmpty)) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.brand));
                  }

                  if (state.status == TasksStatus.error) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Failed to load tasks',
                        style: const TextStyle(color: AppColors.rose500),
                      ),
                    );
                  }

                  final tasks = state.tasks;
                  final isSearching = state.searchQuery.isNotEmpty;
                  final queryLower = state.searchQuery.toLowerCase();
                  
                  final assigneeId = state.selectedAssigneeId;
                  final priorityId = state.selectedPriorityId;
                  final projectId = state.selectedProjectId;
                  final showSubtasks = state.showSubtasks;

                  final filteredTasks = tasks.where((t) {
                    final matchesSearch = !isSearching || t.title.toLowerCase().contains(queryLower);
                    final matchesAssignee = assigneeId == null || t.assigneeId == assigneeId;
                    final matchesPriority = priorityId == null || t.priorityId == priorityId;
                    final matchesProject = projectId == null || t.projectShortId == projectId;
                    return matchesSearch && matchesAssignee && matchesPriority && matchesProject;
                  }).toList();

                  final displayTasks = isSearching ? filteredTasks : filteredTasks.where((t) => t.parentTaskId == null).toList();

                  if (displayTasks.isEmpty && !isSearching) {
                    return const Center(
                      child: Text(
                        'No tasks found',
                        style: TextStyle(color: AppColors.neutral500),
                      ),
                    );
                  }

                  if (filteredTasks.isEmpty && isSearching) {
                    return const Center(
                      child: Text(
                        'No tasks match your search',
                        style: TextStyle(color: AppColors.neutral500),
                      ),
                    );
                  }

                  final statuses = state.statuses;
                  final statusMap = {for (final s in statuses) s.id: s};

                  final hasActiveFilter = isSearching || assigneeId != null || priorityId != null || projectId != null;

                  // Group tasks by status ID
                  final Map<String, List<TaskEntity>> groupedTasks = {};
                  
                  // Pre-populate all labels so they always show empty columns like web board
                  for (final status in statuses) {
                    groupedTasks[status.id] = [];
                  }

                  for (final task in displayTasks) {
                    groupedTasks.putIfAbsent(task.statusId, () => []).add(task);
                  }

                  final sortedKeys = groupedTasks.keys.toList()
                    ..sort((a, b) {
                      final orderA = statusMap[a]?.sortOrder ?? 99;
                      final orderB = statusMap[b]?.sortOrder ?? 99;
                      return orderA.compareTo(orderB);
                    });

                  return RefreshIndicator(
                    onRefresh: () async {
                      final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                      if (wsId != null) {
                        context.read<TasksBloc>().add(FetchTasksEvent(wsId));
                      }
                    },
                    color: AppColors.brand,
                    backgroundColor: AppColors.surfaceAlt,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      itemCount: sortedKeys.length,
                      itemBuilder: (context, index) {
                        final statusId = sortedKeys[index];
                        final group = groupedTasks[statusId]!;
                        final statusInfo = statusMap[statusId];
                        
                        final label = statusInfo?.label.toUpperCase() ?? 'OTHER';
                        final color = statusInfo != null ? _parseColor(statusInfo.color) : AppColors.brand;
                        final isDone = statusInfo?.isDone ?? false;

                        bool isInitiallyExpanded = hasActiveFilter || !isDone;
                        if (state.collapseAllSignal > state.expandAllSignal) {
                          isInitiallyExpanded = false;
                        } else if (state.expandAllSignal > state.collapseAllSignal) {
                          isInitiallyExpanded = true;
                        }

                        return _ExpandableSection(
                          key: ValueKey(statusId),
                          label: label,
                          color: color,
                          count: group.length.toString(),
                          topPadding: index > 0 ? 12.0 : 0.0,
                          initiallyExpanded: isInitiallyExpanded,
                          forceExpanded: hasActiveFilter,
                          expandSignal: state.expandAllSignal,
                          collapseSignal: state.collapseAllSignal,
                          children: group.isEmpty 
                              ? [
                                  GestureDetector(
                                    onTap: () async {
                                      final created = await context.push(AppRoutes.taskAdd, extra: state.tasks);
                                      if (created == true) {
                                        final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                                        if (wsId != null && context.mounted) {
                                          context.read<TasksBloc>().add(FetchTasksEvent(wsId));
                                        }
                                      }
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 24),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.borderCard),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '+ Add task',
                                          style: TextStyle(
                                            color: AppColors.neutral500,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ]
                              : group.map((task) {
                                  Widget buildTile(TaskEntity t, {bool isSubtask = false}) {
                                    final tStatusInfo = statusMap[t.statusId];
                                    final tIsDone = tStatusInfo?.isDone ?? false;

                                    final member = state.members.where((m) => m.userId == t.assigneeId).firstOrNull;
                                    final initials = member != null && member.avatar.isNotEmpty ? member.avatar[0].toUpperCase() : null;

                                    final priority = state.priorities.where((p) => p.id == t.priorityId).firstOrNull;
                                    final priorityColor = priority != null ? _parseColor(priority.color) : null;
                                    
                                    final projectName = t.projectShortId != null ? 'Orbit' : 'Pocket score';
                                    final displayTaskId = t.projectShortId != null ? '${t.projectShortId}-${t.taskId.split('-').last}' : t.taskId;

                                    return _TaskTile(
                                      title: t.title,
                                      taskId: displayTaskId,
                                      projectName: projectName,
                                      dotColor: priorityColor ?? (tStatusInfo != null ? _parseColor(tStatusInfo.color) : AppColors.brand),
                                      initials: initials ?? (t.taskId.isNotEmpty && t.taskId.length > 2 ? t.taskId.substring(0, 2) : 'TK'),
                                      strikethrough: tIsDone,
                                      isSubtask: isSubtask,
                                      subsDone: t.subsDone,
                                      subsTotal: t.subsTotal,
                                      onTap: () async {
                                        final didChange = await context.pushNamed<bool>('taskDetail', pathParameters: {'taskId': t.id});
                                        if (didChange == true) {
                                          final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                                          if (wsId != null && context.mounted) {
                                            context.read<TasksBloc>().add(FetchTasksEvent(wsId));
                                          }
                                        }
                                      },
                                    );
                                  }

                                  final parentTile = buildTile(task);
                                  
                                  if (!showSubtasks || isSearching) {
                                    return parentTile;
                                  }

                                  final subtasks = tasks.where((t) => t.parentTaskId == task.id).toList();
                                  if (subtasks.isEmpty) return parentTile;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      parentTile,
                                      ...subtasks.map((st) => buildTile(st, isSubtask: true)),
                                    ],
                                  );
                                }).toList(),
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

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.taskCount,
    required this.totalCount,
  });

  final int taskCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tasks',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$taskCount of $totalCount - sorted by priority',
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              final created = await context.push(AppRoutes.taskAdd, extra: context.read<TasksBloc>().state.tasks);
              if (created == true) {
                final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                if (wsId != null && context.mounted) {
                  context.read<TasksBloc>().add(FetchTasksEvent(wsId));
                }
              }
            },
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.brand,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                children: [
                  Icon(Icons.add_rounded, color: AppColors.background, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'New task',
                    style: TextStyle(
                      color: AppColors.background,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Bar & Bottom Sheet ───────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  void _showFilterSheet(BuildContext context, TasksState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: context.read<TasksBloc>(),
          child: const _FilterSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksBloc, TasksState>(
      builder: (context, state) {
        int activeFilters = 0;
        if (state.selectedAssigneeId != null) activeFilters++;
        if (state.selectedPriorityId != null) activeFilters++;
        if (state.selectedProjectId != null) activeFilters++;
        if (state.showSubtasks) activeFilters++;
        
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showFilterSheet(context, state),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: activeFilters > 0 ? AppColors.brand.withValues(alpha: 0.15) : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: activeFilters > 0 ? AppColors.brand : AppColors.borderCard,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list_rounded,
                        size: 16,
                        color: activeFilters > 0 ? AppColors.brand : AppColors.neutral300,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Filters${activeFilters > 0 ? ' ($activeFilters)' : ''}',
                        style: TextStyle(
                          color: activeFilters > 0 ? AppColors.brand : AppColors.neutral300,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.read<TasksBloc>().add(TriggerExpandAllEvent()),
                    behavior: HitTestBehavior.opaque,
                    child: const Text(
                      'Expand All',
                      style: TextStyle(color: AppColors.neutral400, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('·', style: TextStyle(color: AppColors.neutral500)),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.read<TasksBloc>().add(TriggerCollapseAllEvent()),
                    behavior: HitTestBehavior.opaque,
                    child: const Text(
                      'Close All',
                      style: TextStyle(color: AppColors.neutral400, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<TasksBloc>().add(const SetAssigneeFilterEvent(null));
                      context.read<TasksBloc>().add(const SetPriorityFilterEvent(null));
                      context.read<TasksBloc>().add(const SetProjectFilterEvent(null));
                      context.read<TasksBloc>().add(const ToggleShowSubtasksEvent(false));
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.chip),
                      ),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColors.neutral300,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Projects Section
                    const Text(
                      'PROJECT',
                      style: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<TasksBloc, TasksState>(
                      builder: (context, state) {
                        final projects = state.tasks
                            .map((t) => t.projectShortId)
                            .whereType<String>()
                            .toSet()
                            .toList()
                          ..sort();

                        return Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: [
                            GestureDetector(
                              onTap: () => context.read<TasksBloc>().add(const SetProjectFilterEvent(null)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: state.selectedProjectId == null ? AppColors.brand.withValues(alpha: 0.15) : AppColors.surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: state.selectedProjectId == null ? AppColors.brand : AppColors.borderCard,
                                  ),
                                ),
                                child: Text(
                                  'All',
                                  style: TextStyle(
                                    color: state.selectedProjectId == null ? AppColors.white : AppColors.neutral300,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            ...projects.map((project) {
                              final isSelected = state.selectedProjectId == project;
                              return GestureDetector(
                                onTap: () => context.read<TasksBloc>().add(SetProjectFilterEvent(project)),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.brand.withValues(alpha: 0.15) : AppColors.surface,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: isSelected ? AppColors.brand : AppColors.borderCard,
                                    ),
                                  ),
                                  child: Text(
                                    project,
                                    style: TextStyle(
                                      color: isSelected ? AppColors.white : AppColors.neutral300,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Assignees Section
                    const Text(
                      'ASSIGNEE',
                      style: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    BlocBuilder<TasksBloc, TasksState>(
                      builder: (context, state) {
                        if (state.members.isEmpty) {
                          return const Text('No team members found.', style: TextStyle(color: AppColors.neutral500));
                        }

                        return Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: state.members.map((member) {
                            final isSelected = state.selectedAssigneeId == member.userId;
                            return GestureDetector(
                              onTap: () {
                                if (isSelected) {
                                  context.read<TasksBloc>().add(const SetAssigneeFilterEvent(null));
                                } else {
                                  context.read<TasksBloc>().add(SetAssigneeFilterEvent(member.userId));
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.only(left: 4, right: 14, top: 4, bottom: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.brand.withValues(alpha: 0.15) : AppColors.surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isSelected ? AppColors.brand : AppColors.borderCard,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: AppColors.brand.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ] : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? AppColors.brand : AppColors.chip,
                                        image: member.avatarUrl != null
                                            ? DecorationImage(
                                                image: CachedNetworkImageProvider(member.avatarUrl!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: member.avatarUrl == null
                                          ? Center(
                                              child: Text(
                                                member.avatar.isNotEmpty ? member.avatar[0].toUpperCase() : 'U',
                                                style: TextStyle(
                                                  color: isSelected ? AppColors.white : AppColors.neutral400,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 8),
                                    // Name
                                    Text(
                                      member.name.isNotEmpty ? member.name.split(' ').first : 'User',
                                      style: TextStyle(
                                        color: isSelected ? AppColors.white : AppColors.neutral300,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Priority Section
                    const Text(
                      'PRIORITY',
                      style: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<TasksBloc, TasksState>(
                      builder: (context, state) {
                        if (state.priorities.isEmpty) {
                          return const Text('No priorities found.', style: TextStyle(color: AppColors.neutral500));
                        }

                        Color parseColor(String colorString) {
                          try {
                            return Color(int.parse('FF${colorString.replaceAll('#', '')}', radix: 16));
                          } catch (e) {
                            return AppColors.neutral400;
                          }
                        }

                        return Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: state.priorities.map((priority) {
                            final isSelected = state.selectedPriorityId == priority.id;
                            final dotColor = parseColor(priority.color);
                            return GestureDetector(
                              onTap: () {
                                if (isSelected) {
                                  context.read<TasksBloc>().add(const SetPriorityFilterEvent(null));
                                } else {
                                  context.read<TasksBloc>().add(SetPriorityFilterEvent(priority.id));
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? dotColor.withValues(alpha: 0.15) : AppColors.surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isSelected ? dotColor : AppColors.borderCard,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: dotColor.withValues(alpha: 0.15),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ] : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: dotColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      priority.label,
                                      style: TextStyle(
                                        color: isSelected ? AppColors.white : AppColors.neutral300,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                    
                    // Subtasks Toggle Section
                    const Text(
                      'SHOW',
                      style: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<TasksBloc, TasksState>(
                      builder: (context, state) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: [
                            GestureDetector(
                              onTap: () => context.read<TasksBloc>().add(const ToggleShowSubtasksEvent(false)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: !state.showSubtasks ? AppColors.brand.withValues(alpha: 0.15) : AppColors.surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: !state.showSubtasks ? AppColors.brand : AppColors.borderCard,
                                  ),
                                ),
                                child: Text(
                                  'Parent Tasks Only',
                                  style: TextStyle(
                                    color: !state.showSubtasks ? AppColors.white : AppColors.neutral300,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.read<TasksBloc>().add(const ToggleShowSubtasksEvent(true)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: state.showSubtasks ? AppColors.brand.withValues(alpha: 0.15) : AppColors.surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: state.showSubtasks ? AppColors.brand : AppColors.borderCard,
                                  ),
                                ),
                                child: Text(
                                  'Include Subtasks',
                                  style: TextStyle(
                                    color: state.showSubtasks ? AppColors.white : AppColors.neutral300,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brand, Color(0xFF4338CA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brand.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Show Results',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderChip extends StatelessWidget {
  const _PlaceholderChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.neutral500,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ── Search bar ──────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, this.onChanged});
  
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.neutral400, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search tasks…',
                  hintStyle: TextStyle(
                    color: AppColors.neutral400,
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
                    if (onChanged != null) onChanged!('');
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.close_rounded, color: AppColors.neutral400, size: 18),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expandable Section ────────────────────────────────────────────────────────

class _ExpandableSection extends StatefulWidget {
  const _ExpandableSection({
    super.key,
    required this.label,
    required this.color,
    required this.count,
    required this.children,
    this.initiallyExpanded = true,
    this.forceExpanded = false,
    this.expandSignal = 0,
    this.collapseSignal = 0,
    this.topPadding = 0.0,
  });

  final String label;
  final Color color;
  final String count;
  final List<Widget> children;
  final bool initiallyExpanded;
  final bool forceExpanded;
  final int expandSignal;
  final int collapseSignal;
  final double topPadding;

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded || widget.forceExpanded;
  }

  @override
  void didUpdateWidget(covariant _ExpandableSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.expandSignal > oldWidget.expandSignal) {
      setState(() => _isExpanded = true);
    } else if (widget.collapseSignal > oldWidget.collapseSignal) {
      setState(() => _isExpanded = false);
    } else if (widget.forceExpanded && (!oldWidget.forceExpanded || oldWidget.count != widget.count)) {
      // If a filter is active and the list of children changed, or the filter just became active, expand it.
      setState(() => _isExpanded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.topPadding > 0) SizedBox(height: widget.topPadding),
        GestureDetector(
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
          },
          behavior: HitTestBehavior.opaque,
          child: _SectionHeader(
            color: widget.color,
            label: widget.label,
            count: widget.count,
            isExpanded: _isExpanded,
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstCurve: Curves.easeOut,
          secondCurve: Curves.easeIn,
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: _isExpanded 
              ? CrossFadeState.showFirst 
              : CrossFadeState.showSecond,
          alignment: Alignment.topCenter,
          firstChild: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.children,
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.color,
    required this.label,
    required this.count,
    required this.isExpanded,
  });

  final Color color;
  final String label;
  final String count;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.neutral500,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderCard),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              count,
              style: const TextStyle(
                color: AppColors.neutral500,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedRotation(
            turns: isExpanded ? 0.25 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral500,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task tile ──────────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.title,
    required this.taskId,
    this.projectName,
    this.dotColor,
    this.initials,
    this.strikethrough = false,
    this.isSubtask = false,
    this.subsDone = 0,
    this.subsTotal = 0,
    this.onTap,
  });

  final String title;
  final String taskId;
  final String? projectName;
  final Color? dotColor;
  final String? initials;
  final bool strikethrough;
  final bool isSubtask;
  final int subsDone;
  final int subsTotal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 8, left: isSubtask ? 32 : 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Priority Dot, Task ID, Tag Placeholder
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (dotColor != null) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  taskId,
                  style: const TextStyle(
                    color: AppColors.neutral500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                // Emulate the web "Feature/UI" hollow badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'Feature/UI',
                    style: TextStyle(
                      color: AppColors.emerald,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: strikethrough ? AppColors.neutral500 : AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.2,
                decoration: strikethrough ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.neutral500,
              ),
            ),
            const SizedBox(height: 4),
            // Project Name
            if (projectName != null)
              Text(
                '- $projectName',
                style: const TextStyle(
                  color: AppColors.brand,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 12),
            // Bottom Row: Subtasks and Avatar
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (subsTotal > 0) ...[
                  Text(
                    '- $subsDone/$subsTotal',
                    style: const TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (initials != null) _AvatarCircle(initials: initials!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.chip,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.neutral200,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
