import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_detail_app_bar.dart';
import 'package:orbit_app/core/widgets/orbit_square_button.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OrbitDetailAppBar(
        title: 'Task Detail',
        actions: [
          OrbitSquareButton(icon: Icons.more_horiz_rounded, onTap: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          // ── Title ─────────────────────────────────────────────────
          const Text(
            'Implement OAuth token refresh flow',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),

          // ── Status pills ──────────────────────────────────────────
          const Row(
            children: [
              _StatusPill(dotColor: AppColors.amber, label: 'In Progress'),
              SizedBox(width: 8),
              _StatusPill(dotColor: AppColors.rose, label: 'High'),
            ],
          ),
          const SizedBox(height: 24),

          // ── Meta card ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const _MetaRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Due date',
                  trailing: const Text(
                    'Apr 12',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const _MetaDivider(),
                _MetaRow(
                  icon: Icons.folder_open_rounded,
                  label: 'Project',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emerald.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Auth API',
                      style: TextStyle(color: AppColors.emerald, fontSize: 12),
                    ),
                  ),
                ),
                const _MetaDivider(),
                const _MetaRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Assignee',
                  trailing: const Row(
                    children: [
                      _MiniAvatar('MK'),
                      SizedBox(width: 8),
                      Text(
                        'Mara Kane',
                        style: TextStyle(color: AppColors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Description ───────────────────────────────────────────
          const _SectionLabel('DESCRIPTION'),
          const SizedBox(height: 8),
          const Text(
            'Implement a secure token refresh mechanism that silently '
            'renews access tokens before expiry. Use the refresh token '
            'rotation strategy and store tokens in an httpOnly cookie. '
            'Handle race conditions when multiple requests trigger a '
            'refresh simultaneously.',
            style: TextStyle(
              color: AppColors.neutral300,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // ── Subtasks ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionLabel('SUBTASKS'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.chip,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '1/3',
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _SubtaskRow(label: 'Add refresh token endpoint', done: true),
          const SizedBox(height: 12),
          const _SubtaskRow(label: 'Handle concurrent refresh requests'),
          const SizedBox(height: 12),
          const _SubtaskRow(label: 'Write unit tests for rotation'),
          const SizedBox(height: 24),

          // ── Time logged ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: AppColors.neutral400,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time Logged',
                          style: TextStyle(
                            color: AppColors.neutral400,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '1h 20m',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.brandSoft,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Start Timer',
                      style: TextStyle(
                        color: AppColors.brandSoft,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Activity ──────────────────────────────────────────────
          const _SectionLabel('ACTIVITY'),
          const SizedBox(height: 12),
          const _ActivityRow(
            icon: Icons.chat_bubble_outline_rounded,
            time: 'Apr 11 · 14:32',
            showDivider: true,
            richText: [
              _Span('MK ', bold: true),
              _Span(
                'commented: Rotation logic is in, testing edge '
                'cases now.',
              ),
            ],
          ),
          const _ActivityRow(
            icon: Icons.commit_rounded,
            time: 'Apr 10 · 09:15',
            showDivider: true,
            richText: [
              _Span('Linked commit '),
              _Span('a3f9c1', color: AppColors.brandSoft, mono: true),
            ],
          ),
          const _ActivityRow(
            icon: Icons.flag_outlined,
            time: 'Apr 09 · 16:48',
            richText: [
              _Span('Status changed to '),
              _Span('In Progress', bold: true),
            ],
          ),
          const SizedBox(height: 16),

          // ── Comment input ─────────────────────────────────────────
          Container(
            height: 44,
            padding: const EdgeInsets.only(left: 12, right: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Add a comment…',
                      hintStyle: TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.neutral200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    size: 14,
                    color: AppColors.surface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status pill ──────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.dotColor, required this.label});
  final Color dotColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.neutral400,
            size: 16,
          ),
        ],
      ),
    );
  }
}

// ── Meta row ─────────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.neutral400, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: AppColors.neutral400, fontSize: 14),
            ),
          ],
        ),
        trailing,
      ],
    );
  }
}

class _MetaDivider extends StatelessWidget {
  const _MetaDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(height: 1, child: ColoredBox(color: AppColors.divider)),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar(this.initials);
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

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.neutral400,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }
}

// ── Subtask row ───────────────────────────────────────────────────────────────

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({required this.label, this.done = false});
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (done)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 14,
              color: AppColors.surface,
            ),
          )
        else
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.divider, width: 2),
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: done ? AppColors.neutral400 : AppColors.white,
              fontSize: 14,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.neutral400,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Activity row ──────────────────────────────────────────────────────────────

class _Span {
  const _Span(this.text, {this.bold = false, this.color, this.mono = false});
  final String text;
  final bool bold;
  final Color? color;
  final bool mono;
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.time,
    required this.richText,
    this.showDivider = false,
  });

  final IconData icon;
  final String time;
  final List<_Span> richText;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: showDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.chip,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.neutral400, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      for (final s in richText)
                        TextSpan(
                          text: s.text,
                          style: TextStyle(
                            color: s.color ?? AppColors.white,
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: s.bold
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontFamily: s.mono ? 'monospace' : null,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
