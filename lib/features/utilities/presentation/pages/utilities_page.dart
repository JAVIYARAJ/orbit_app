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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.white, AppColors.neutral300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'App Drawer',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'All your Orbit modules',
                        style: TextStyle(
                          color: AppColors.neutral400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.chip.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: AppColors.neutral300,
                      size: 18,
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
                  color: AppColors.background.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.chip.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: AppColors.neutral400,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Search modules...',
                      style: TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 14,
                      ),
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
              children: [
                const _ModuleItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  color: AppColors.indigo500,
                ),
                const _ModuleItem(
                  icon: Icons.folder_open_rounded,
                  label: 'Projects',
                  color: AppColors.indigo500,
                ),
                const _ModuleItem(
                  icon: Icons.check_box_outlined,
                  label: 'Tasks',
                  color: AppColors.emerald,
                ),
                const _ModuleItem(
                  icon: Icons.description_outlined,
                  label: 'Notes',
                  color: AppColors.amber,
                ),
                _ModuleItem(
                  icon: Icons.school_outlined,
                  label: 'Learning',
                  color: AppColors.purple600,
                  onTap: () {
                    Scaffold.of(context).closeEndDrawer();
                    context.push('/profile/learning');
                  },
                ),
                _ModuleItem(
                  icon: Icons.access_time_rounded,
                  label: 'Time Track',
                  color: AppColors.rose600,
                  onTap: () {
                    Scaffold.of(context).closeEndDrawer();
                    context.push('/profile/time-tracking');
                  },
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
                _ModuleItem(
                  icon: Icons.code_rounded,
                  label: 'GitHub',
                  color: AppColors.neutral50,
                  onTap: () {
                    Scaffold.of(context).closeEndDrawer();
                    context.push('/profile/github');
                  },
                ),
                _ModuleItem(
                  icon: Icons.change_history_rounded,
                  label: 'Vercel',
                  color: AppColors.neutral50,
                  onTap: () {
                    Scaffold.of(context).closeEndDrawer();
                    context.push('/profile/vercel');
                  },
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
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDashed 
                    ? [AppColors.surfaceAlt.withValues(alpha: 0.5), AppColors.surfaceAlt.withValues(alpha: 0.2)]
                    : [AppColors.surface, AppColors.surfaceAlt],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDashed ? AppColors.chip.withValues(alpha: 0.3) : AppColors.chip.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: isDashed
                  ? null
                  : [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: -2,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Center(
              child: Icon(icon, color: color, size: 26),
            ),
          ),
          const SizedBox(height: 8),
          // Label
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDashed ? AppColors.neutral500 : AppColors.neutral200,
              fontSize: 12, // text-xs
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
