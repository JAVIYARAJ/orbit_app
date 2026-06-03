import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_detail_app_bar.dart';
import 'package:orbit_app/core/widgets/orbit_square_button.dart';

class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OrbitDetailAppBar(
        title: 'Project',
        actions: [
          OrbitSquareButton(icon: Icons.more_horiz_rounded, onTap: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.indigo400.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.folder_open_rounded,
                      color: AppColors.indigo400,
                      size: 32,
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
                          const Expanded(
                            child: Text(
                              'Atlas API Gateway',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.indigo400.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: AppColors.indigo400,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Central API gateway · 12 members',
                        style: TextStyle(
                          color: AppColors.neutral400,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Stats Row ────────────────────────────────────────────
          const SizedBox(height: 24),
          SizedBox(
            height: 112,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: const [
                _StatCard(
                  icon: Icons.checklist_rtl_rounded,
                  value: '24',
                  label: 'Tasks',
                  color: AppColors.indigo400,
                ),
                SizedBox(width: 12),
                _StatCard(
                  icon: Icons.check_circle_outline_rounded,
                  value: '18',
                  label: 'Completed',
                  color: AppColors.emerald400,
                ),
                SizedBox(width: 12),
                _StatCard(
                  icon: Icons.access_time_rounded,
                  value: '4',
                  label: 'In Progress',
                  color: AppColors.amber400,
                ),
                SizedBox(width: 12),
                _StatCard(
                  icon: Icons.error_outline_rounded,
                  value: '2',
                  label: 'Overdue',
                  color: AppColors.rose400,
                ),
              ],
            ),
          ),

          // ── Description ──────────────────────────────────────────
          const SizedBox(height: 32),
          const _SectionTitle('Description'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderCard),
              ),
              child: const Text(
                'Central API gateway handling routing, authentication middleware, and rate limiting across all Orbit microservices. Built with TypeScript and deployed on the self-hosted infrastructure.',
                style: TextStyle(
                  color: AppColors.neutral300,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // ── Progress ─────────────────────────────────────────────
          const SizedBox(height: 32),
          const _SectionTitle('Progress'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '75% complete',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '18 of 24 tasks done',
                      style: TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.neutral700,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.75,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.indigo500, // bg-indigo-500
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Team ─────────────────────────────────────────────────
          const SizedBox(height: 32),
          const _SectionTitle('Team'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _TeamAvatar(label: 'AL', color: AppColors.indigo400),
                SizedBox(width: 8),
                _TeamAvatar(label: 'MK', color: AppColors.amber400),
                SizedBox(width: 8),
                _TeamAvatar(label: 'JD', color: AppColors.emerald400),
                SizedBox(width: 8),
                _TeamAvatar(label: 'RP', color: AppColors.rose400),
                SizedBox(width: 8),
                _TeamAvatar(label: 'ST', color: AppColors.cyan),
                SizedBox(width: 12),
                Text(
                  '+7 more',
                  style: TextStyle(color: AppColors.neutral400, fontSize: 14),
                ),
              ],
            ),
          ),

          // ── Recent Tasks ─────────────────────────────────────────
          const SizedBox(height: 32),
          const _SectionTitle('Recent Tasks'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const _TaskItem(
                  title: 'Implement OAuth token refresh',
                  assignee: 'Alex Lambert',
                  priority: 'Low',
                  priorityColor: AppColors.emerald400,
                  isCompleted: true,
                ),
                const SizedBox(height: 12),
                const _TaskItem(
                  title: 'Add rate limiting middleware',
                  assignee: 'Maya Kim',
                  priority: 'High',
                  priorityColor: AppColors.rose400,
                  isCompleted: false,
                ),
                const SizedBox(height: 12),
                const _TaskItem(
                  title: 'Write integration tests',
                  assignee: 'Jordan Diaz',
                  priority: 'Medium',
                  priorityColor: AppColors.amber400,
                  isCompleted: false,
                ),
                const SizedBox(height: 32),

                // View All Button
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.indigo500,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View All Tasks',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.white,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Note: If using AppShell for bottom nav, this page may not need its own bottom nav.
      // Keeping it to match the original implementation if AppShell is not wrapping this branch correctly.
      // But typically, child pages inside StatefulShellRoute don't need their own bottom nav.
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112, // w-28 = 112px
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.neutral400,
          fontSize: 12,
          fontFamily: 'monospace',
          letterSpacing: 2.0, // tracking-widest
        ),
      ),
    );
  }
}

class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  const _TaskItem({
    required this.title,
    required this.assignee,
    required this.priority,
    required this.priorityColor,
    required this.isCompleted,
  });

  final String title;
  final String assignee;
  final String priority;
  final Color priorityColor;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: isCompleted ? AppColors.emerald400 : AppColors.neutral600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  assignee,
                  style: const TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: priorityColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
