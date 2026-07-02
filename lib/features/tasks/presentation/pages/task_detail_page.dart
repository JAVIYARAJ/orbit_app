import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/features/tasks/presentation/cubit/task_detail_bloc.dart';
import 'package:orbit_app/features/tasks/presentation/cubit/task_detail_event.dart';
import 'package:orbit_app/features/tasks/presentation/cubit/task_detail_state.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';
import 'package:orbit_app/app/di/injection.dart';
import 'package:orbit_app/features/tasks/domain/entities/task_detail_entity.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key, required this.taskId});
  final String taskId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
        final bloc = sl<TaskDetailBloc>();
        if (wsId != null) {
          bloc.add(FetchTaskDetailEvent(workstationId: wsId, taskId: taskId));
        }
        return bloc;
      },
      child: const TaskDetailView(),
    );
  }
}

class TaskDetailView extends StatefulWidget {
  const TaskDetailView({super.key});

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  int _activityTabIndex = 0; // 0: Comments, 1: History, 2: Work Log
  bool _didChange = false;
  bool _showSaved = false;
  Timer? _savedTimer;
  String? _replyingToCommentId;
  String? _mentionQuery;
  bool _isReplyingMention = false;
  final List<String> _pendingMentions = [];

  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  @override
  void dispose() {
    _savedTimer?.cancel();
    _commentController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskDetailBloc, TaskDetailState>(
      listenWhen: (prev, current) => prev.isSaving != current.isSaving,
      listener: (context, state) {
        if (state.isSaving) {
          _didChange = true;
          _savedTimer?.cancel();
          setState(() {
            _showSaved = false;
          });
        } else {
          setState(() {
            _showSaved = true;
          });
          _savedTimer?.cancel();
          _savedTimer = Timer(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _showSaved = false;
              });
            }
          });
        }
      },
      builder: (context, state) {
        if (state.status == TaskDetailStatus.loading || state.status == TaskDetailStatus.initial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator(color: AppColors.brandSoft)),
          );
        }

        if (state.status == TaskDetailStatus.failure) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text(state.errorMessage ?? 'Error', style: const TextStyle(color: AppColors.rose))),
          );
        }

        final data = state.taskDetail!;
        final task = data.task;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, dynamic result) {
            if (didPop) return;
            context.pop(_didChange);
          },
          child: Scaffold(
            backgroundColor: const Color(0xFF1E1F24), // Match dark grey background from web
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E1F24),
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 24,
            title: Row(
              children: [
                _Badge(task.taskId),
                const SizedBox(width: 8),
                if (task.project != null) _Badge(task.project!.name),
              ],
            ),
            actions: [
              _buildSaveStatus(state.isSaving),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.neutral400),
                onPressed: () => context.pop(_didChange),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                color: const Color(0xFF1E1F24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('TITLE'),
                    const SizedBox(height: 8),
                    _DebouncedTextField(
                      initialValue: task.title,
                      maxLines: null,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      onChanged: (val) {
                        final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                        if (wsId != null && val.trim().isNotEmpty) {
                          _dispatchUpdate(UpdateTaskTitleEvent(workstationId: wsId, taskId: task.id, title: val.trim()));
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF2C2D33), height: 1, thickness: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  children: [
                    const _SectionTitle('DESCRIPTION'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141518),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF2C2D33)),
                      ),
                      child: _DebouncedTextField(
                        initialValue: task.description ?? '',
                        maxLines: null,
                        hintText: 'Add a description...',
                        style: const TextStyle(color: AppColors.neutral300, fontSize: 14, height: 1.5),
                        onChanged: (val) {
                          final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                          if (wsId != null) {
                            _dispatchUpdate(UpdateTaskDescriptionEvent(workstationId: wsId, taskId: task.id, description: val.trim()));
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildAttachments(data.attachments),
                    const SizedBox(height: 24),

                    _buildSubtasks(data.subtasks, task.id),
                    const SizedBox(height: 24),

                    _buildLinkedNotes(data.linkedNotes),
                    const SizedBox(height: 32),

                    const _SectionTitle('ACTIVITY'),
                    const SizedBox(height: 12),
                    _buildActivityTabs(),
                    const SizedBox(height: 16),
                    _buildActivityContent(data),
                    const SizedBox(height: 32),
                    
                    _buildDropdowns(task, data.metadata),
                    const SizedBox(height: 24),

                    _buildTags(task, data.metadata),
                    const SizedBox(height: 32),

                    _buildTimeAndProgress(task),
                    const SizedBox(height: 24),

                    _buildBranch(task),
                  ],
                ),
              ),
            ],
          ),
        ));
      },
    );
  }

  Widget _buildAttachments(List<TaskAttachmentEntity> attachments) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.upload_rounded, color: AppColors.neutral400, size: 16),
                const SizedBox(width: 8),
                const Text('Attachments', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF2C2D33), borderRadius: BorderRadius.circular(999)),
                  child: Text('${attachments.length}', style: const TextStyle(color: AppColors.neutral400, fontSize: 12)),
                ),
              ],
            ),
            const Row(
              children: [
                Icon(Icons.add, color: AppColors.white, size: 14),
                SizedBox(width: 4),
                Text('Add', style: TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (attachments.isNotEmpty)
          Container(
            width: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF141518),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2C2D33)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E1F24),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: attachments.first.url.isNotEmpty 
                      ? Image.network(attachments.first.url, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image, color: AppColors.neutral500))
                      : const Icon(Icons.image_outlined, color: AppColors.neutral500),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(attachments.first.fileName, style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${attachments.first.sizeBytes ~/ 1024} KB', style: const TextStyle(color: AppColors.neutral400, fontSize: 11)),
                          _MiniAvatar(
                            initials: attachments.first.uploadedBy.name.substring(0, 2),
                            avatarUrl: attachments.first.uploadedBy.avatar,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C2D33), style: BorderStyle.none),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_rounded, color: AppColors.neutral500, size: 16),
              SizedBox(width: 8),
              Text('Tap here to upload an attachment', style: TextStyle(color: AppColors.neutral500, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtasks(List<TaskSubtaskEntity> subtasks, String parentTaskId) {
    final completedCount = subtasks.where((e) => e.status.isDone).length;
    final totalCount = subtasks.length;
    final progress = totalCount > 0 ? (completedCount / totalCount * 100).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.menu_rounded, color: AppColors.neutral400, size: 16),
                const SizedBox(width: 8),
                const Text('SUBTASKS', style: TextStyle(color: AppColors.neutral400, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF2C2D33), borderRadius: BorderRadius.circular(4)),
                  child: Text('$completedCount/$totalCount', style: const TextStyle(color: AppColors.neutral400, fontSize: 11)),
                ),
              ],
            ),
            const Row(
              children: [
                Icon(Icons.link_rounded, color: AppColors.white, size: 14),
                SizedBox(width: 4),
                Text('Link', style: TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                SizedBox(width: 16),
                Icon(Icons.add, color: AppColors.white, size: 14),
                SizedBox(width: 4),
                Text('Add', style: TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: totalCount > 0 ? completedCount / totalCount : 0,
                  backgroundColor: const Color(0xFF2C2D33),
                  color: const Color(0xFF38BDF8),
                  minHeight: 2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('$progress%', style: const TextStyle(color: AppColors.neutral500, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
          ],
        ),
        const SizedBox(height: 16),
        if (subtasks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No subtasks — break this into smaller pieces.', style: TextStyle(color: AppColors.neutral500, fontSize: 13, fontStyle: FontStyle.italic)),
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < subtasks.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final didChange = await context.pushNamed<bool>('taskDetail', pathParameters: {'taskId': subtasks[i].id});
                    if (didChange == true && mounted) {
                      final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                      if (wsId != null) {
                        context.read<TaskDetailBloc>().add(FetchTaskDetailEvent(workstationId: wsId, taskId: parentTaskId));
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141518),
                      border: Border.all(color: const Color(0xFF2C2D33)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: _parseColor(subtasks[i].status.color), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(subtasks[i].title, style: TextStyle(color: subtasks[i].status.isDone ? AppColors.neutral400 : AppColors.white, fontSize: 13, decoration: subtasks[i].status.isDone ? TextDecoration.lineThrough : null))),
                      const SizedBox(width: 12),
                      Text(subtasks[i].status.label.toUpperCase(), style: TextStyle(color: _parseColor(subtasks[i].status.color), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.neutral500, size: 16),
                    ],
                  ),
                ),)
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildLinkedNotes(List<TaskLinkedNoteEntity> notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.description_outlined, color: AppColors.neutral400, size: 16),
                const SizedBox(width: 8),
                const Text('LINKED NOTES', style: TextStyle(color: AppColors.neutral400, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFF2C2D33), borderRadius: BorderRadius.circular(4)),
                  child: Text('${notes.length}', style: const TextStyle(color: AppColors.neutral400, fontSize: 11)),
                ),
              ],
            ),
            const Row(
              children: [
                Icon(Icons.add, color: AppColors.white, size: 14),
                SizedBox(width: 4),
                Text('Attach', style: TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final note in notes)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF141518),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2C2D33)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: AppColors.neutral400, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(note.title, style: const TextStyle(color: AppColors.white, fontSize: 14))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActivityTabs() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141518),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2C2D33)),
      ),
      child: Row(
        children: [
          _TabItem(title: 'Comments', isSelected: _activityTabIndex == 0, onTap: () => setState(() => _activityTabIndex = 0)),
          _TabItem(title: 'History', isSelected: _activityTabIndex == 1, onTap: () => setState(() => _activityTabIndex = 1)),
          _TabItem(title: 'Work Log', isSelected: _activityTabIndex == 2, onTap: () => setState(() => _activityTabIndex = 2)),
        ],
      ),
    );
  }

  Widget _buildActivityContent(TaskDetailEntity data) {
    final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
    final task = data.task;

    if (_activityTabIndex == 0) {
      // Group comments: top-level + their replies
      final parents = data.comments.where((c) => c.parentId == null || c.parentId!.isEmpty).toList();
      parents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final Map<String, List<TaskCommentEntity>> repliesByParent = {};
      for (final reply in data.comments.where((c) => c.parentId != null && c.parentId!.isNotEmpty)) {
        repliesByParent.putIfAbsent(reply.parentId!, () => []).add(reply);
      }
      for (final replies in repliesByParent.values) {
        replies.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (wsId != null) ...[
            _buildMainComposer(wsId, task.id, data),
            const SizedBox(height: 16),
          ],
          if (parents.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.message_rounded, color: AppColors.neutral500, size: 32),
                    SizedBox(height: 12),
                    Text('No comments yet.', style: TextStyle(color: AppColors.neutral400, fontSize: 13, fontWeight: FontWeight.w500)),
                    SizedBox(height: 4),
                    Text('Be the first to share your thoughts!', style: TextStyle(color: AppColors.neutral500, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            ...parents.map((parent) {
              final replies = repliesByParent[parent.id] ?? [];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCommentRow(parent, wsId ?? '', task.id, isReply: false),
                    if (replies.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 40, top: 2),
                        child: Column(
                          children: replies.map((reply) => _buildCommentRow(reply, wsId ?? '', task.id, isReply: true)).toList(),
                        ),
                      ),
                    if (_replyingToCommentId == parent.id)
                      Padding(
                        padding: const EdgeInsets.only(left: 40, top: 6),
                        child: _buildReplyComposer(wsId ?? '', task.id, parent.id, data),
                      ),
                  ],
                ),
              );
            }),
        ],
      );
    } else if (_activityTabIndex == 1) {
      if (data.history.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(Icons.history_rounded, color: AppColors.neutral500, size: 32),
              SizedBox(height: 12),
              Text('No history yet.', style: TextStyle(color: AppColors.neutral400, fontSize: 13, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('Activity will appear here when the task changes.', style: TextStyle(color: AppColors.neutral500, fontSize: 12)),
            ],
          ),
        );
      }

      return Column(
        children: [
          for (var i = 0; i < data.history.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 20,
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: _parseColor(data.history[i].toStatus.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (i != data.history.length - 1)
                          Expanded(
                            child: Container(
                              width: 1,
                              color: const Color(0xFF2C2D33),
                              margin: const EdgeInsets.only(top: 4, bottom: 4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(data.history[i].fromStatus.label, style: const TextStyle(color: AppColors.neutral400, fontSize: 13)),
                              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward_rounded, color: AppColors.neutral500, size: 12)),
                              Text(data.history[i].toStatus.label, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(DateFormat('MMM d · HH:mm').format(data.history[i].changedAt), style: const TextStyle(color: AppColors.neutral500, fontSize: 12, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
        ],
      );
    } else {
      if (data.workLogs.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(Icons.timer_off_outlined, color: AppColors.neutral500, size: 32),
              SizedBox(height: 12),
              Text('No work logged yet.', style: TextStyle(color: AppColors.neutral400, fontSize: 13, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text('Start the timer or log time manually.', style: TextStyle(color: AppColors.neutral500, fontSize: 12)),
            ],
          ),
        );
      }

      return Column(
        children: [
          for (final log in data.workLogs)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MiniAvatar(
                    initials: log.user.name.substring(0, 2),
                    avatarUrl: log.user.avatar,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(log.user.name, style: const TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            Text('${log.totalSeconds ~/ 3600}h', style: const TextStyle(color: AppColors.brandSoft, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            if (log.isManual)
                              const Text('MANUAL', style: TextStyle(color: AppColors.neutral500, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(log.notes, style: const TextStyle(color: AppColors.neutral300, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(DateFormat('dd/MM/yyyy').format(log.startedAt), style: const TextStyle(color: AppColors.neutral500, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            )
        ],
      );
    }
  }

  Widget _buildCommentRow(TaskCommentEntity comment, String wsId, String taskId, {required bool isReply}) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isOwner = comment.author.id == currentUserId;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isReply ? 6 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniAvatar(
            initials: comment.author.name.isNotEmpty && comment.author.name.length >= 2 
                ? comment.author.name.substring(0, 2) 
                : (comment.author.name.isNotEmpty ? comment.author.name : '?'),
            avatarUrl: comment.author.avatar,
            size: isReply ? 22 : 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      comment.author.name,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: isReply ? 12 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM d').format(comment.createdAt),
                      style: const TextStyle(color: AppColors.neutral500, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.body,
                  style: TextStyle(
                    color: AppColors.neutral300,
                    fontSize: isReply ? 13 : 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (!isReply) ...[
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            if (_replyingToCommentId == comment.id) {
                              _replyingToCommentId = null;
                              _replyController.clear();
                            } else {
                              _replyingToCommentId = comment.id;
                              _replyController.text = '@${comment.author.name} ';
                              _replyController.selection = TextSelection.collapsed(offset: _replyController.text.length);
                              _pendingMentions.clear();
                              _pendingMentions.add(comment.author.id);
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              color: _replyingToCommentId == comment.id ? AppColors.brandSoft : AppColors.neutral500,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      if (isOwner) const SizedBox(width: 16),
                    ],
                    if (isOwner)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          _dispatchUpdate(DeleteTaskCommentEvent(
                            workstationId: wsId,
                            taskId: taskId,
                            commentId: comment.id,
                          ));
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: AppColors.rose,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkMention(String text, TextEditingController controller, bool isReply) {
    final selection = controller.selection;
    if (selection.isValid && selection.isCollapsed) {
      final cursorPosition = selection.baseOffset;
      final textBeforeCursor = text.substring(0, cursorPosition);
      
      final atIndex = textBeforeCursor.lastIndexOf('@');
      if (atIndex != -1 && (atIndex == 0 || textBeforeCursor[atIndex - 1] == ' ' || textBeforeCursor[atIndex - 1] == '\n')) {
        final query = textBeforeCursor.substring(atIndex + 1);
        if (!query.contains(' ')) {
          setState(() {
            _mentionQuery = query;
            _isReplyingMention = isReply;
          });
          return;
        }
      }
    }
    setState(() {
      _mentionQuery = null;
    });
  }

  void _insertMention(TaskUserItemEntity member, TextEditingController controller) {
    final text = controller.text;
    final selection = controller.selection;
    if (selection.isValid && selection.isCollapsed) {
      final cursorPosition = selection.baseOffset;
      final textBeforeCursor = text.substring(0, cursorPosition);
      final atIndex = textBeforeCursor.lastIndexOf('@');
      if (atIndex != -1) {
        final textAfterCursor = text.substring(cursorPosition);
        final replacement = '@${member.name} ';
        
        final newText = textBeforeCursor.substring(0, atIndex) + replacement + textAfterCursor;
        controller.text = newText;
        
        final newCursorPosition = atIndex + replacement.length;
        controller.selection = TextSelection.collapsed(offset: newCursorPosition);
        
        if (!_pendingMentions.contains(member.id)) {
          _pendingMentions.add(member.id);
        }
      }
    }
    setState(() {
      _mentionQuery = null;
    });
  }

  Widget _buildReplyComposer(String wsId, String taskId, String parentId, TaskDetailEntity data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_mentionQuery != null && _isReplyingMention)
          _buildMentionAutocomplete(data, _replyController),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF141518),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C2D33)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _replyController,
                maxLines: null,
                minLines: 2,
                style: const TextStyle(color: AppColors.white, fontSize: 13, height: 1.5),
                onChanged: (val) => _checkMention(val, _replyController, true),
                decoration: const InputDecoration(
                  hintText: 'Write a reply... @ to mention',
                  hintStyle: TextStyle(color: AppColors.neutral500, fontSize: 12),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFF2C2D33), height: 1, thickness: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _CommentActionButton(
                    text: 'Cancel',
                    onTap: () {
                      setState(() {
                        _replyingToCommentId = null;
                        _replyController.clear();
                        _mentionQuery = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _CommentActionButton(
                    text: 'Reply',
                    isPrimary: true,
                    onTap: () => _submitReply(wsId, taskId, parentId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainComposer(String wsId, String taskId, TaskDetailEntity data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_mentionQuery != null && !_isReplyingMention)
          _buildMentionAutocomplete(data, _commentController),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF141518),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C2D33)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _commentController,
                maxLines: null,
                minLines: 2,
                style: const TextStyle(color: AppColors.white, fontSize: 13, height: 1.5),
                onChanged: (val) => _checkMention(val, _commentController, false),
                decoration: const InputDecoration(
                  hintText: 'Write a comment... @ to mention',
                  hintStyle: TextStyle(color: AppColors.neutral500, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Color(0xFF2C2D33), height: 1, thickness: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _CommentActionButton(
                    text: 'Comment',
                    isPrimary: true,
                    onTap: () => _submitComment(wsId, taskId),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMentionAutocomplete(TaskDetailEntity data, TextEditingController controller) {
    final filteredMembers = data.metadata.members.where((m) {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (m.id == currentUserId) return false;

      final query = _mentionQuery!.toLowerCase();
      final nameMatches = m.name.toLowerCase().contains(query);
      final emailMatches = m.email != null && m.email!.toLowerCase().contains(query);
      return nameMatches || emailMatches;
    }).toList();

    if (filteredMembers.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxHeight: 140),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141518),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2C2D33)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: filteredMembers.length,
        itemBuilder: (context, index) {
          final member = filteredMembers[index];
          return Material(
            color: Colors.transparent,
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              leading: _MiniAvatar(
                initials: member.name.isNotEmpty && member.name.length >= 2 
                    ? member.name.substring(0, 2) 
                    : (member.name.isNotEmpty ? member.name : '?'),
                avatarUrl: member.avatar,
              ),
              title: Text(member.name, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              subtitle: member.email != null 
                  ? Text(member.email!, style: const TextStyle(color: AppColors.neutral500, fontSize: 11))
                  : null,
              onTap: () => _insertMention(member, controller),
            ),
          );
        },
      ),
    );
  }

  void _submitComment(String wsId, String taskId) {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    _dispatchUpdate(AddTaskCommentEvent(
      workstationId: wsId,
      taskId: taskId,
      body: body,
      mentionedUserIds: _pendingMentions.toList(),
    ));

    _commentController.clear();
    _pendingMentions.clear();
    setState(() {
      _mentionQuery = null;
    });
  }

  void _submitReply(String wsId, String taskId, String parentId) {
    final body = _replyController.text.trim();
    if (body.isEmpty) return;

    _dispatchUpdate(AddTaskCommentEvent(
      workstationId: wsId,
      taskId: taskId,
      body: body,
      mentionedUserIds: _pendingMentions.toList(),
      parentId: parentId,
    ));

    _replyController.clear();
    _pendingMentions.clear();
    setState(() {
      _replyingToCommentId = null;
      _mentionQuery = null;
    });
  }

  void _dispatchUpdate(TaskDetailEvent event) {
    context.read<TaskDetailBloc>().add(event);
  }

  void _showSelectionSheet<T>({
    required String title,
    required List<T> items,
    required String Function(T) labelBuilder,
    Color? Function(T)? colorBuilder,
    String? Function(T)? avatarUrlBuilder,
    String? Function(T)? initialsBuilder,
    required void Function(T) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141518),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: const Color(0xFF2C2D33).withOpacity(0.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 48, height: 4, decoration: BoxDecoration(color: const Color(0xFF2C2D33), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text('Select $title', style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: const Color(0xFF1E1F24), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.close, color: AppColors.neutral400, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF2C2D33), height: 1),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final color = colorBuilder?.call(item);
                    final avatarUrl = avatarUrlBuilder?.call(item);
                    final initials = initialsBuilder?.call(item);
                    
                    return InkWell(
                      onTap: () {
                        onSelected(item);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1F24),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2C2D33).withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            if (color != null) ...[
                              Container(
                                width: 14, 
                                height: 14, 
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2), 
                                  border: Border.all(color: color, width: 2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            if (avatarUrl != null || initials != null) ...[
                              _MiniAvatar(initials: initials ?? 'U', avatarUrl: avatarUrl, size: 32),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: Text(labelBuilder(item), style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.neutral500, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdowns(TaskDetailDataEntity task, TaskMetadataEntity meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DropdownField(
          label: 'STATUS', 
          value: task.status.label, 
          color: _parseColor(task.status.color),
          onTap: () {
            final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
            if (wsId != null) {
              _showSelectionSheet<TaskStatusItemEntity>(
                title: 'Status',
                items: meta.statuses,
                labelBuilder: (e) => e.label,
                colorBuilder: (e) => _parseColor(e.color),
                onSelected: (e) => _dispatchUpdate(UpdateTaskStatusEvent(workstationId: wsId, taskId: task.id, statusId: e.id)),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: 'PRIORITY', 
          value: task.priority?.label ?? 'Normal', 
          color: task.priority != null ? _parseColor(task.priority!.color) : null,
          onTap: () {
            final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
            if (wsId != null) {
              _showSelectionSheet<TaskPriorityItemEntity>(
                title: 'Priority',
                items: meta.priorities,
                labelBuilder: (e) => e.label,
                colorBuilder: (e) => _parseColor(e.color),
                onSelected: (e) => _dispatchUpdate(UpdateTaskPriorityEvent(workstationId: wsId, taskId: task.id, priorityId: e.id)),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: 'DUE DATE', 
          value: task.dueDate != null ? DateFormat('dd / MM / yyyy').format(task.dueDate!) : 'dd / mm / yyyy', 
          icon: Icons.calendar_today_rounded,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: task.dueDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null && context.mounted) {
              final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
              if (wsId != null) {
                _dispatchUpdate(UpdateTaskDueDateEvent(workstationId: wsId, taskId: task.id, dueDate: date));
              }
            }
          },
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: 'ASSIGNEE', 
          value: task.assignee?.name ?? 'Unassigned',
          avatarUrl: task.assignee?.avatar,
          initials: task.assignee != null && task.assignee!.name.isNotEmpty ? task.assignee!.name.substring(0, 2).toUpperCase() : null,
          onTap: () {
            final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
            if (wsId != null) {
              _showSelectionSheet<TaskUserItemEntity>(
                title: 'Assignee',
                items: meta.members,
                labelBuilder: (e) => e.name,
                avatarUrlBuilder: (e) => e.avatar,
                initialsBuilder: (e) => e.name.isNotEmpty ? e.name.substring(0, 2).toUpperCase() : 'U',
                onSelected: (e) => _dispatchUpdate(UpdateTaskAssigneeEvent(workstationId: wsId, taskId: task.id, assigneeId: e.id)),
              );
            }
          },
        ),
        const SizedBox(height: 16),
        _DropdownField(
          label: 'REPORTER', 
          value: task.reporter?.name ?? 'Unassigned',
          avatarUrl: task.reporter?.avatar,
          initials: task.reporter != null && task.reporter!.name.isNotEmpty ? task.reporter!.name.substring(0, 2).toUpperCase() : null,
          onTap: () {
            final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
            if (wsId != null) {
              _showSelectionSheet<TaskUserItemEntity>(
                title: 'Reporter',
                items: meta.members,
                labelBuilder: (e) => e.name,
                avatarUrlBuilder: (e) => e.avatar,
                initialsBuilder: (e) => e.name.isNotEmpty ? e.name.substring(0, 2).toUpperCase() : 'U',
                onSelected: (e) => _dispatchUpdate(UpdateTaskReporterEvent(workstationId: wsId, taskId: task.id, reporterId: e.id)),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildTags(TaskDetailDataEntity task, TaskMetadataEntity meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('TAGS'),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
            if (wsId != null) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => _TagSelectionSheet(
                  selectedTags: task.tags,
                  allTags: meta.tags,
                  onSave: (tagsList) => _dispatchUpdate(UpdateTaskTagsEvent(workstationId: wsId, taskId: task.id, tags: tagsList)),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141518),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2C2D33)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (task.tags.isEmpty)
                  const Text('No tags yet. Tap to add.', style: TextStyle(color: AppColors.neutral500, fontSize: 13)),
                for (final t in task.tags)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _parseColor(t.color).withOpacity(0.15),
                      border: Border.all(color: _parseColor(t.color).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 6, height: 6, decoration: BoxDecoration(color: _parseColor(t.color), shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        Text(t.name, style: TextStyle(color: _parseColor(t.color), fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                            if (wsId != null) {
                              final newTags = task.tags.where((e) => e.id != t.id).toList();
                              _dispatchUpdate(UpdateTaskTagsEvent(workstationId: wsId, taskId: task.id, tags: newTags));
                            }
                          },
                          child: Icon(Icons.close_rounded, color: _parseColor(t.color).withOpacity(0.6), size: 12),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeAndProgress(TaskDetailDataEntity task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('TIME & PROGRESS'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF141518),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2C2D33)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.timer_outlined, color: AppColors.neutral400, size: 16),
                      SizedBox(width: 8),
                      Text('TRACKING PROGRESS', style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF0D324D), borderRadius: BorderRadius.circular(4)),
                    child: Text('${task.progress.toInt()}%', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: task.progress / 100,
                  backgroundColor: const Color(0xFF2C2D33),
                  color: const Color(0xFF38BDF8),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF2C2D33), height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('LOGGED', style: TextStyle(color: AppColors.neutral500, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                        const SizedBox(height: 4),
                        Text('${task.loggedMinutes ~/ 60}h', style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 30, color: const Color(0xFF2C2D33)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ESTIMATE', style: TextStyle(color: AppColors.neutral500, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF1E1F24), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF2C2D33))),
                              child: Text('${task.estimateMinutes ~/ 60}', style: const TextStyle(color: AppColors.white, fontSize: 14)),
                            ),
                            const SizedBox(width: 8),
                            const Text('h', style: TextStyle(color: AppColors.neutral500, fontSize: 12)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFF1E1F24), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF2C2D33))),
                              child: Text('${task.estimateMinutes % 60}', style: const TextStyle(color: AppColors.white, fontSize: 14)),
                            ),
                            const SizedBox(width: 8),
                            const Text('m', style: TextStyle(color: AppColors.neutral500, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF2C2D33), height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFF1E1F24), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF2C2D33))),
                    child: const Row(
                      children: [
                        Icon(Icons.add, color: AppColors.neutral400, size: 14),
                        SizedBox(width: 4),
                        Text('Log Time', style: TextStyle(color: AppColors.neutral300, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _QuickTimeBtn('+15m'),
                      const SizedBox(width: 8),
                      _QuickTimeBtn('+30m'),
                      const SizedBox(width: 8),
                      _QuickTimeBtn('+1h'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBranch(TaskDetailDataEntity task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('BRANCH'),
        const SizedBox(height: 8),
        if (task.branchName != null && task.branchName!.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Text(task.branchName!, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontFamily: 'monospace')),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF141518),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2C2D33)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.check_box_outline_blank_rounded, color: AppColors.neutral500, size: 20),
                  const SizedBox(width: 12),
                  const Icon(Icons.call_split_rounded, color: AppColors.neutral400, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Switch to existing branch', style: TextStyle(color: AppColors.neutral300, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(task.project != null ? 'JAVIYARAJ/${task.project!.name.toLowerCase().replaceAll(' ', '_')}' : 'Repository', style: const TextStyle(color: AppColors.neutral500, fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 44, top: 8, bottom: 8),
                child: Text('feat/account-deletion-required-by-both-stores', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontFamily: 'monospace')),
              ),
              const Divider(color: Color(0xFF2C2D33), height: 32),
              Row(
                children: [
                  const Icon(Icons.check_box_outline_blank_rounded, color: AppColors.neutral500, size: 20),
                  const SizedBox(width: 12),
                  const Icon(Icons.add_circle_outline_rounded, color: AppColors.neutral400, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Create a new branch', style: TextStyle(color: AppColors.neutral300, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text(task.project != null ? 'JAVIYARAJ/${task.project!.name.toLowerCase().replaceAll(' ', '_')}' : 'Repository', style: const TextStyle(color: AppColors.neutral500, fontSize: 12, fontFamily: 'monospace')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveStatus(bool isSaving) {
    Widget child;
    if (isSaving) {
      child = Container(
        key: const ValueKey('saving'),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2638),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF2B3D54)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                color: Color(0xFF38BDF8),
                strokeWidth: 1.5,
              ),
            ),
            SizedBox(width: 6),
            Text(
              'Saving...',
              style: TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else if (_showSaved) {
      child = Container(
        key: const ValueKey('saved'),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF162E20),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF224A34)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, color: Color(0xFF4ADE80), size: 12),
            SizedBox(width: 4),
            Text(
              'Saved',
              style: TextStyle(
                color: Color(0xFF4ADE80),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      child = const SizedBox.shrink(key: ValueKey('none'));
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation.drive(Tween(begin: 0.95, end: 1.0)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildBottomBar(TaskDetailState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderCard)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (state.isSaving)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.neutral400, strokeWidth: 2)),
              ),
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.borderCard),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.title, required this.isSelected, required this.onTap});
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0099FF).withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isSelected ? Border.all(color: const Color(0xFF0099FF)) : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF38BDF8) : AppColors.neutral400,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({required this.label, required this.value, this.color, this.icon, this.avatarUrl, this.initials, this.onTap});
  final String label;
  final String value;
  final Color? color;
  final IconData? icon;
  final String? avatarUrl;
  final String? initials;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF141518),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2C2D33)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (color != null) ...[
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                    ],
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.neutral400, size: 16),
                      const SizedBox(width: 8),
                    ],
                    if (initials != null || avatarUrl != null) ...[
                      _MiniAvatar(initials: initials ?? 'U', avatarUrl: avatarUrl),
                      const SizedBox(width: 8),
                    ],
                    Text(value, style: const TextStyle(color: AppColors.white, fontSize: 14)),
                  ],
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neutral400, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: AppColors.neutral400, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2));
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF141518),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF2C2D33)),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.neutral400, fontSize: 12, fontFamily: 'monospace')),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.initials, this.avatarUrl, this.size = 28});
  final String initials;
  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: NetworkImage(avatarUrl!), fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(color: Color(0xFF2C2D33), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initials, style: TextStyle(color: AppColors.white, fontSize: size * 0.4, fontWeight: FontWeight.w600)),
    );
  }
}

class _QuickTimeBtn extends StatelessWidget {
  const _QuickTimeBtn(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F24),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF2C2D33)),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.neutral400, fontSize: 12)),
    );
  }
}

Color _parseColor(String colorStr) {
  try {
    return Color(int.parse(colorStr.substring(1, 7), radix: 16) + 0xFF000000);
  } catch (e) {
    return AppColors.neutral400;
  }
}

class _TagSelectionSheet extends StatefulWidget {
  const _TagSelectionSheet({
    required this.selectedTags,
    required this.allTags,
    required this.onSave,
  });

  final List<TaskTagItemEntity> selectedTags;
  final List<TaskTagItemEntity> allTags;
  final void Function(List<TaskTagItemEntity>) onSave;

  @override
  State<_TagSelectionSheet> createState() => _TagSelectionSheetState();
}

class _TagSelectionSheetState extends State<_TagSelectionSheet> {
  final _searchController = TextEditingController();
  late List<TaskTagItemEntity> _selected;
  late List<TaskTagItemEntity> _filtered;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedTags);
    _filtered = widget.allTags;
  }

  void _onSearch(String query) {
    setState(() {
      _query = query;
      _filtered = widget.allTags.where((t) => t.name.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  String _getColorForText(String text) {
    if (text.isEmpty) return '#38BDF8';
    final colors = const ['#F87171', '#FBBF24', '#34D399', '#60A5FA', '#A78BFA', '#F472B6', '#38BDF8'];
    return colors[text.hashCode.abs() % colors.length];
  }

  void _onSave() {
    if (_query.trim().isNotEmpty && !_filtered.any((t) => t.name.toLowerCase() == _query.trim().toLowerCase())) {
      _toggleTag(TaskTagItemEntity(id: '', name: _query.trim(), color: _getColorForText(_query.trim())));
    }
    Navigator.pop(context);
  }

  void _dispatchSave() {
    widget.onSave(_selected.toList());
  }

  void _toggleTag(TaskTagItemEntity tag) {
    setState(() {
      if (_selected.any((e) => e.name.toLowerCase() == tag.name.toLowerCase())) {
        _selected.removeWhere((e) => e.name.toLowerCase() == tag.name.toLowerCase());
      } else {
        _selected.add(tag);
      }
    });
    _dispatchSave();
  }

  @override
  Widget build(BuildContext context) {
    final showCreateOption = _query.isNotEmpty && !_filtered.any((t) => t.name.toLowerCase() == _query.toLowerCase());
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141518),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: const Color(0xFF2C2D33).withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 48, height: 4, decoration: BoxDecoration(color: const Color(0xFF2C2D33), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Text('Manage Tags', style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                  const Spacer(),
                  TextButton(
                    onPressed: _onSave,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: AppColors.brandSoft.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Done', style: TextStyle(color: AppColors.brandSoft, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF2C2D33), height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty && !_filtered.any((t) => t.name.toLowerCase() == val.trim().toLowerCase())) {
                    _toggleTag(TaskTagItemEntity(id: '', name: val.trim(), color: _getColorForText(val.trim())));
                    _searchController.clear();
                    _onSearch('');
                  }
                },
                style: const TextStyle(color: AppColors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search or create a new tag...',
                  hintStyle: const TextStyle(color: AppColors.neutral500, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: AppColors.neutral500, size: 20),
                  filled: true,
                  fillColor: const Color(0xFF1E1F24),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF2C2D33).withOpacity(0.5))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: const Color(0xFF2C2D33).withOpacity(0.5))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.brandSoft)),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  if (showCreateOption)
                    InkWell(
                      onTap: () {
                        _toggleTag(TaskTagItemEntity(id: '', name: _query.trim(), color: _getColorForText(_query.trim())));
                        _searchController.clear();
                        _onSearch('');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: _parseColor(_getColorForText(_query.trim())).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _parseColor(_getColorForText(_query.trim())).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(color: _parseColor(_getColorForText(_query.trim())).withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                              child: Icon(Icons.add, size: 16, color: _parseColor(_getColorForText(_query.trim()))),
                            ),
                            const SizedBox(width: 12),
                            Text('Create tag "$_query"', style: TextStyle(color: _parseColor(_getColorForText(_query.trim())), fontSize: 15, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ..._filtered.map((t) {
                    final isSelected = _selected.any((e) => e.name.toLowerCase() == t.name.toLowerCase());
                    return InkWell(
                      onTap: () => _toggleTag(t),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? _parseColor(t.color).withOpacity(0.1) : const Color(0xFF1E1F24),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isSelected ? _parseColor(t.color).withOpacity(0.5) : const Color(0xFF2C2D33).withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 14, height: 14,
                              decoration: BoxDecoration(
                                color: _parseColor(t.color).withOpacity(0.2),
                                border: Border.all(color: _parseColor(t.color), width: 2),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(t.name, style: TextStyle(color: isSelected ? AppColors.white : AppColors.neutral300, fontSize: 15, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
                            ),
                            if (isSelected) 
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: AppColors.brandSoft, shape: BoxShape.circle),
                                child: const Icon(Icons.check, color: AppColors.white, size: 14),
                              )
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebouncedTextField extends StatefulWidget {
  const _DebouncedTextField({
    required this.initialValue,
    required this.onChanged,
    this.style,
    this.maxLines = 1,
    this.hintText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final TextStyle? style;
  final int? maxLines;
  final String? hintText;

  @override
  State<_DebouncedTextField> createState() => _DebouncedTextFieldState();
}

class _DebouncedTextFieldState extends State<_DebouncedTextField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_DebouncedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue && _controller.text != widget.initialValue) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      widget.onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      style: widget.style,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: AppColors.neutral500),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _CommentActionButton extends StatelessWidget {
  const _CommentActionButton({required this.text, required this.onTap, this.isPrimary = false});
  final String text;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF38BDF8) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isPrimary ? const Color(0xFF38BDF8) : const Color(0xFF2C2D33),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isPrimary ? const Color(0xFF0F172A) : AppColors.neutral300,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
