import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';

enum _Check { todoCircle, checkedSquare, doneCircle }

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const _FilterChips(),
            const _SearchBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  // ── IN PROGRESS ──────────────────────────────────────────
                  const _SectionHeader(
                    color: AppColors.amber,
                    label: 'IN PROGRESS',
                    count: '2',
                  ),
                  _TaskTile(
                    title: 'Implement OAuth token refresh flow',
                    tag: 'Auth API',
                    tagColor: AppColors.emerald,
                    dotColor: AppColors.rose,
                    initials: 'MK',
                    date: 'Apr 12',
                    check: _Check.checkedSquare,
                    highlighted: true,
                    onTap: () => context.push('/tasks/detail'),
                  ),
                  _TaskTile(
                    title: 'Refactor task list virtualization',
                    tag: 'Core UI',
                    tagColor: AppColors.purple,
                    dotColor: AppColors.amber,
                    initials: 'AL',
                    date: 'Apr 14',
                    onTap: () => context.push('/tasks/detail'),
                  ),

                  // ── TO DO ────────────────────────────────────────────────
                  const SizedBox(height: 12),
                  const _SectionHeader(
                    color: AppColors.neutral400,
                    label: 'TO DO',
                    count: '3',
                  ),
                  _TaskTile(
                    title: 'Write integration tests for sync engine',
                    tag: 'Sync',
                    tagColor: AppColors.brandSoft,
                    dotColor: kOrbitIndigo,
                    initials: 'JK',
                    date: 'Apr 18',
                    onTap: () => context.push('/tasks/detail'),
                  ),
                  _TaskTile(
                    title: 'Design empty state illustrations',
                    tag: 'Core UI',
                    tagColor: AppColors.purple,
                    dotColor: AppColors.amber,
                    initials: 'AL',
                    date: 'Apr 20',
                    onTap: () => context.push('/tasks/detail'),
                  ),
                  _TaskTile(
                    title: 'Add rate limiting to public endpoints',
                    tag: 'Auth API',
                    tagColor: AppColors.emerald,
                    dotColor: AppColors.rose,
                    initials: 'MK',
                    date: 'Apr 22',
                    onTap: () => context.push('/tasks/detail'),
                  ),

                  // ── DONE ─────────────────────────────────────────────────
                  const SizedBox(height: 12),
                  const _SectionHeader(
                    color: AppColors.emerald,
                    label: 'DONE',
                    count: '8',
                    showChevron: true,
                  ),
                  _TaskTile(
                    title: 'Set up CI pipeline',
                    date: 'Apr 08',
                    check: _Check.doneCircle,
                    strikethrough: true,
                    onTap: () => context.push('/tasks/detail'),
                  ),
                ],
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
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: kOrbitIndigo,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              children: [
                Icon(Icons.add_rounded, color: AppColors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'New Task',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

// ── Filter chips ────────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    const labels = ['All', 'Today', 'This Week', 'By Project'];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => _Chip(label: labels[i], active: i == 0),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? kOrbitIndigo : AppColors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: active ? null : Border.all(color: AppColors.borderCard),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.white : AppColors.neutral400,
          fontSize: 14,
          fontWeight: active ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ── Search bar ──────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.neutral400, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: TextStyle(color: AppColors.white, fontSize: 14),
                decoration: InputDecoration(
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
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.color,
    required this.label,
    required this.count,
    this.showChevron = false,
  });

  final Color color;
  final String label;
  final String count;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.neutral400,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
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
              count,
              style: const TextStyle(
                color: AppColors.neutral400,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (showChevron) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral400,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Task tile ──────────────────────────────────────────────────────────────────

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.title,
    required this.date,
    this.tag,
    this.tagColor,
    this.dotColor,
    this.initials,
    this.check = _Check.todoCircle,
    this.highlighted = false,
    this.strikethrough = false,
    this.onTap,
  });

  final String title;
  final String date;
  final String? tag;
  final Color? tagColor;
  final Color? dotColor;
  final String? initials;
  final _Check check;
  final bool highlighted;
  final bool strikethrough;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        _Checkbox(check: check),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: strikethrough ? AppColors.neutral400 : AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: strikethrough ? TextDecoration.lineThrough : null,
              decorationColor: AppColors.neutral400,
            ),
          ),
        ),
        if (tag != null && tagColor != null) ...[
          const SizedBox(width: 8),
          _TagBadge(label: tag!, color: tagColor!),
        ],
        if (dotColor != null) ...[
          const SizedBox(width: 8),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ],
        if (initials != null) ...[
          const SizedBox(width: 8),
          _AvatarCircle(initials: initials!),
        ],
        const SizedBox(width: 8),
        Text(
          date,
          style: const TextStyle(
            color: AppColors.neutral400,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: highlighted
            ? BoxDecoration(
                color: kOrbitIndigo.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(color: kOrbitIndigo, width: 2),
                ),
              )
            : const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderCard)),
              ),
        child: row,
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.check});
  final _Check check;

  @override
  Widget build(BuildContext context) {
    switch (check) {
      case _Check.checkedSquare:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: kOrbitIndigo,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 14,
            color: AppColors.white,
          ),
        );
      case _Check.doneCircle:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: AppColors.emerald,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 14,
            color: AppColors.background,
          ),
        );
      case _Check.todoCircle:
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderCard, width: 2),
          ),
        );
    }
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
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
