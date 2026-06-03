import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';
import 'package:orbit_app/features/utilities/presentation/pages/utilities_page.dart';

/// Persistent application shell.
///
/// Hosts a single bottom navigation bar that stays mounted while only the body
/// (the active branch) swaps. This avoids the "whole page reload" effect that
/// happens when each screen carries its own nav bar and uses `context.go`.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  /// Provided by [StatefulShellRoute.indexedStack]; tracks the active branch
  /// and keeps each tab's navigation/scroll state alive.
  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    // `initialLocation: true` when re-tapping the active tab pops it back to
    // that branch's root — standard bottom-nav behaviour.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      endDrawer: const Drawer(
        width: 320,
        backgroundColor: AppColors.surfaceAlt, // _cardBg
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
          side: BorderSide(color: AppColors.chip, width: 1), // _cardBorder
        ),
        child: UtilitiesPage(),
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Navigation Bar
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const List<_NavItem> _navItems = [
  _NavItem(icon: Icons.home_rounded, label: 'Home'),
  _NavItem(icon: Icons.folder_open_rounded, label: 'Projects'),
  _NavItem(icon: Icons.check_box_outlined, label: 'Tasks'),
  _NavItem(icon: Icons.description_outlined, label: 'Notes'),
  _NavItem(icon: Icons.person_rounded, label: 'Profile'),
];

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderNeutral)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < _navItems.length; i++)
                _NavButton(
                  item: _navItems[i],
                  isActive: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? kOrbitIndigo : AppColors.neutral400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
