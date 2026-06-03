import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class UtilitiesPage extends StatelessWidget {
  const UtilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Drawer',
                        style: TextStyle(
                          color: AppColors.neutral50,
                          fontSize: 28, // text-3xl roughly
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'All your Orbit modules',
                        style: TextStyle(color: AppColors.neutral400, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.chip),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: AppColors.neutral400,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),

            // ── Search Bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.chip),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: AppColors.neutral400, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Search modules...',
                      style: TextStyle(color: AppColors.neutral400, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            // ── Core Modules ──────────────────────────────────────────
            const _SectionTitle('Core Modules'),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: const [
                _ModuleItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  color: AppColors.indigo500,
                ),
                _ModuleItem(
                  icon: Icons.folder_open_rounded,
                  label: 'Projects',
                  color: AppColors.indigo500,
                ),
                _ModuleItem(
                  icon: Icons.check_box_outlined,
                  label: 'Tasks',
                  color: AppColors.emerald,
                ),
                _ModuleItem(
                  icon: Icons.description_outlined,
                  label: 'Notes',
                  color: AppColors.amber,
                ),
                _ModuleItem(
                  icon: Icons.school_outlined,
                  label: 'Learning',
                  color: AppColors.purple600,
                ),
                _ModuleItem(
                  icon: Icons.access_time_rounded,
                  label: 'Time Track',
                  color: AppColors.rose600,
                ),
              ],
            ),

            // ── Integrations ──────────────────────────────────────────
            const SizedBox(height: 24),
            const _SectionTitle('Integrations'),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: [
                const _ModuleItem(
                  icon: Icons.code_rounded,
                  label: 'GitHub',
                  color: AppColors.neutral50,
                ),
                const _ModuleItem(
                  icon: Icons.change_history_rounded,
                  label: 'Vercel',
                  color: AppColors.neutral50,
                ),
                _ModuleItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'Secrets',
                  color: AppColors.rose600,
                  onTap: () {
                    // Close the drawer before navigating
                    Scaffold.of(context).closeEndDrawer();
                    context.push('/profile/secrets');
                  },
                ),
                const _ModuleItem(
                  icon: Icons.storage_rounded,
                  label: 'Databases',
                  color: AppColors.emerald,
                ),
                const _ModuleItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'Containers',
                  color: AppColors.indigo500,
                ),
                const _ModuleItem(
                  icon: Icons.terminal_rounded,
                  label: 'Terminal',
                  color: AppColors.amber,
                ),
              ],
            ),

            // ── Workspace ─────────────────────────────────────────────
            const SizedBox(height: 24),
            const _SectionTitle('Workspace'),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8,
              children: const [
                _ModuleItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Calendar',
                  color: AppColors.purple600,
                ),
                _ModuleItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Messages',
                  color: AppColors.emerald,
                ),
                _ModuleItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Analytics',
                  color: AppColors.amber,
                ),
                _ModuleItem(
                  icon: Icons.notifications_none_rounded,
                  label: 'Alerts',
                  color: AppColors.rose600,
                ),
                _ModuleItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  color: AppColors.neutral400,
                ),
                _ModuleItem(
                  icon: Icons.add_rounded,
                  label: 'Add',
                  color: AppColors.neutral400,
                  isDashed: true,
                ),
              ],
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.neutral400,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 2.0, // tracking-widest
        ),
      ),
    );
  }
}

class _ModuleItem extends StatelessWidget {
  const _ModuleItem({
    required this.icon,
    required this.label,
    required this.color,
    this.isDashed = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDashed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon Box
          Container(
            width: 64, // size-16
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16), // rounded-2xl
              // For dashed border, we'd normally use a custom painter, but for simplicity,
              // a regular border is used unless we want to bring in a dependency.
              // Flutter doesn't have a built in dashed border, so I'll just use a solid one
              // or a slightly different style for now.
              border: Border.all(
                color: AppColors.chip,
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 24), // size-6
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDashed ? AppColors.neutral400 : AppColors.neutral50,
              fontSize: 12, // text-xs
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
