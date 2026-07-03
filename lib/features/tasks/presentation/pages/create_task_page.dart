import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_entity.dart';
import 'package:orbit_app/features/tasks/presentation/bloc/create_task_bloc.dart';
import 'package:orbit_app/features/tasks/presentation/bloc/create_task_event.dart';
import 'package:orbit_app/features/tasks/presentation/bloc/create_task_state.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key, required this.tasks});
  final List<TaskEntity> tasks;

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      context.read<CreateTaskBloc>().add(UpdateFieldEvent(title: _titleController.text));
    });
    _descriptionController.addListener(() {
      context.read<CreateTaskBloc>().add(UpdateFieldEvent(description: _descriptionController.text));
    });
    final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
    if (wsId != null) {
      context.read<CreateTaskBloc>().add(FetchMetadataEvent(wsId));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.neutral400;
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final state = context.read<CreateTaskBloc>().state;
    final picked = await showDatePicker(
      context: context,
      initialDate: state.dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.brand,
            onPrimary: AppColors.background,
            surface: AppColors.surfaceAlt,
            onSurface: AppColors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && context.mounted) {
      context.read<CreateTaskBloc>().add(UpdateFieldEvent(dueDate: picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateTaskBloc, CreateTaskState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.status == CreateTaskStatus.error && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        } else if (state.status == CreateTaskStatus.success) {
          context.pop(true);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.neutral400, size: 24),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'New Task',
            style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            BlocBuilder<CreateTaskBloc, CreateTaskState>(
              builder: (context, state) {
                final isCreating = state.status == CreateTaskStatus.creating;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: ElevatedButton(
                    onPressed: isCreating
                        ? null
                        : () {
                            final wsId =
                                context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                            if (wsId != null) {
                              context.read<CreateTaskBloc>().add(
                                    SubmitTaskEvent(
                                      workstationId: wsId,
                                      existingTasks: widget.tasks,
                                    ),
                                  );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brand,
                      foregroundColor: AppColors.background,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: isCreating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : const Text(
                            'Create Task',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<CreateTaskBloc, CreateTaskState>(
          builder: (context, state) {
            if (state.status == CreateTaskStatus.initial ||
                state.status == CreateTaskStatus.loading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.brand));
            }

            final metadata = state.metadata;
            final projects = metadata['projects'] as List<dynamic>? ?? [];
            final statuses = metadata['statuses'] as List<dynamic>? ?? [];
            final priorities = metadata['priorities'] as List<dynamic>? ?? [];
            final members = metadata['members'] as List<dynamic>? ?? [];
            final tags = metadata['tags'] as List<dynamic>? ?? [];

            final selectedProject = projects.cast<Map<String, dynamic>?>().firstWhere(
                  (p) => p?['shortId'] == state.selectedProjectId,
                  orElse: () => null,
                );
            final repo = selectedProject?['repo'] as String?;
            final hasRepo = repo != null && repo.isNotEmpty && repo != '—';
            final repoName = hasRepo
                ? repo!
                    .replaceAll(RegExp(r'^https?://github\.com/'), '')
                    .replaceAll(RegExp(r'\.git$'), '')
                    .split('?')
                    .first
                : '';

            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // ── Title ──────────────────────────────────────────────
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Task title',
                    hintStyle: TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Row 1: Project & Priority ─────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Project',
                        value: state.selectedProjectId,
                        items: projects.map((p) {
                          return DropdownMenuItem<String>(
                            value: p['shortId'] as String,
                            child: Text(p['name'] as String,
                                style: const TextStyle(color: AppColors.white)),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            context.read<CreateTaskBloc>().add(UpdateFieldEvent(projectId: val)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdown(
                        label: 'Priority',
                        value: state.selectedPriorityId,
                        items: priorities.map((p) {
                          return DropdownMenuItem<String>(
                            value: p['id'] as String,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _parseColor(p['color'] as String),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(p['label'] as String,
                                    style: const TextStyle(color: AppColors.white)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            context.read<CreateTaskBloc>().add(UpdateFieldEvent(priorityId: val)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Row 2: Status & Due Date ──────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        label: 'Column',
                        value: state.selectedStatusId,
                        items: statuses.map((s) {
                          return DropdownMenuItem<String>(
                            value: s['id'] as String,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _parseColor(s['color'] as String),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(s['label'] as String,
                                    style: const TextStyle(color: AppColors.white)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            context.read<CreateTaskBloc>().add(UpdateFieldEvent(statusId: val)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Due date',
                            style: TextStyle(
                              color: AppColors.neutral500,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectDueDate(context),
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderCard),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded,
                                      color: AppColors.neutral400, size: 16),
                                  const SizedBox(width: 12),
                                  Text(
                                    state.dueDate != null
                                        ? DateFormat('MMM d, yyyy').format(state.dueDate!)
                                        : 'Set date',
                                    style: TextStyle(
                                      color: state.dueDate != null
                                          ? AppColors.white
                                          : AppColors.neutral400,
                                      fontSize: 14,
                                    ),
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
                const SizedBox(height: 24),

                // ── Assignee ──────────────────────────────────────────
                _buildDropdown(
                  label: 'Assignee',
                  value: state.selectedAssigneeId,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Unassigned',
                          style: TextStyle(color: AppColors.neutral400)),
                    ),
                    ...members.map((m) {
                      return DropdownMenuItem<String>(
                        value: m['id'] as String,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 9,
                              backgroundColor: AppColors.surfaceAlt,
                              backgroundImage: (m['avatar'] as String?) != null
                                  ? CachedNetworkImageProvider(m['avatar'] as String)
                                  : null,
                              child: (m['avatar'] as String?) == null
                                  ? Text(
                                      ((m['name'] as String?) ?? 'U').isNotEmpty
                                          ? (m['name'] as String)[0].toUpperCase()
                                          : 'U',
                                      style: const TextStyle(
                                          color: AppColors.neutral400, fontSize: 9),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (m['name'] as String?) ?? '',
                                style: const TextStyle(color: AppColors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) =>
                      context.read<CreateTaskBloc>().add(UpdateFieldEvent(assigneeId: val)),
                ),
                const SizedBox(height: 24),

                // ── Estimated Duration ────────────────────────────────
                const Text(
                  'Estimated Duration',
                  style: TextStyle(
                    color: AppColors.neutral500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberField(
                        suffix: 'hours',
                        onChanged: (val) => context
                            .read<CreateTaskBloc>()
                            .add(UpdateFieldEvent(estHours: int.tryParse(val) ?? 0)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildNumberField(
                        suffix: 'mins',
                        onChanged: (val) => context
                            .read<CreateTaskBloc>()
                            .add(UpdateFieldEvent(estMinutes: int.tryParse(val) ?? 0)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── GitHub Branch (only if project has repo) ──────────
                if (hasRepo) ...[
                  const Text(
                    'GitHub Branch',
                    style: TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderCard),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Option: Create new branch
                        InkWell(
                          onTap: () => context.read<CreateTaskBloc>().add(
                                UpdateFieldEvent(
                                  branchMode: state.branchMode == BranchMode.create
                                      ? BranchMode.none
                                      : BranchMode.create,
                                ),
                              ),
                          child: Row(
                            children: [
                              Icon(
                                state.branchMode == BranchMode.create
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: state.branchMode == BranchMode.create
                                    ? AppColors.brand
                                    : AppColors.neutral500,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Create new branch',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(repoName,
                                      style: const TextStyle(
                                          color: AppColors.neutral500, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (state.branchMode == BranchMode.create)
                          Padding(
                            padding: const EdgeInsets.only(top: 12, left: 32),
                            child: TextField(
                              style: const TextStyle(color: AppColors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'feat/new-feature',
                                hintStyle: const TextStyle(color: AppColors.neutral500),
                                filled: true,
                                fillColor: AppColors.surfaceAlt,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                              onChanged: (val) => context
                                  .read<CreateTaskBloc>()
                                  .add(UpdateFieldEvent(branchName: val)),
                            ),
                          ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: AppColors.borderCard, height: 1),
                        ),
                        // Option: Link existing branch
                        InkWell(
                          onTap: () => context.read<CreateTaskBloc>().add(
                                UpdateFieldEvent(
                                  branchMode: state.branchMode == BranchMode.existing
                                      ? BranchMode.none
                                      : BranchMode.existing,
                                ),
                              ),
                          child: Row(
                            children: [
                              Icon(
                                state.branchMode == BranchMode.existing
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: state.branchMode == BranchMode.existing
                                    ? AppColors.brand
                                    : AppColors.neutral500,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Link existing branch',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(repoName,
                                      style: const TextStyle(
                                          color: AppColors.neutral500, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (state.branchMode == BranchMode.existing)
                          Padding(
                            padding: const EdgeInsets.only(top: 12, left: 32),
                            child: TextField(
                              style: const TextStyle(color: AppColors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Type branch name...',
                                hintStyle: const TextStyle(color: AppColors.neutral500),
                                filled: true,
                                fillColor: AppColors.surfaceAlt,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                              onChanged: (val) => context
                                  .read<CreateTaskBloc>()
                                  .add(UpdateFieldEvent(existingBranch: val)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Tags ─────────────────────────────────────────────
                const Text(
                  'Tags',
                  style: TextStyle(
                    color: AppColors.neutral500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((t) {
                    final isSelected = state.selectedTagIds.contains(t['id']);
                    final color = _parseColor(t['color'] as String);
                    return FilterChip(
                      label: Text(
                        t['name'] as String,
                        style: TextStyle(
                          color: isSelected ? color : AppColors.neutral400,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (val) {
                        final newTags = List<String>.from(state.selectedTagIds);
                        if (val) {
                          newTags.add(t['id'] as String);
                        } else {
                          newTags.remove(t['id'] as String);
                        }
                        context
                            .read<CreateTaskBloc>()
                            .add(UpdateFieldEvent(selectedTagIds: newTags));
                      },
                      backgroundColor: AppColors.surface,
                      selectedColor: color.withValues(alpha: 0.15),
                      checkmarkColor: color,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      side: BorderSide(
                        color: isSelected
                            ? color.withValues(alpha: 0.5)
                            : AppColors.borderCard,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ── Description ───────────────────────────────────────
                const Text(
                  'Description',
                  style: TextStyle(
                    color: AppColors.neutral500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderCard),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    style: const TextStyle(color: AppColors.white, fontSize: 14),
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Add a more detailed description...',
                      hintStyle: TextStyle(color: AppColors.neutral500),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String?>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.neutral500,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderCard),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: value,
              items: items,
              onChanged: onChanged,
              dropdownColor: AppColors.surfaceAlt,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.neutral400,
                size: 18,
              ),
              style: const TextStyle(color: AppColors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String suffix,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: '0',
                hintStyle: TextStyle(color: AppColors.neutral500),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Text(
              suffix,
              style: const TextStyle(color: AppColors.neutral400, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
