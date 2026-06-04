import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:orbit_app/features/authentication/presentation/state/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// Asks for confirmation, then signs out of this device only. The router's
  /// auth guard sends the user back to the login screen automatically.
  Future<void> _confirmAndSignOut(BuildContext context) async {
    final cubit = context.read<AuthCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceAlt,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.chip),
        ),
        title: const Text(
          'Sign out?',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'You will be signed out on this device only. Your other devices and '
          'the web app stay signed in.',
          style: TextStyle(color: AppColors.neutral400, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.neutral300),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: AppColors.rose600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) await cubit.logout();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.backgroundDeep,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            32,
            20,
            112,
          ), // bottom padding for nav bar
          children: [
            // ── Header ───────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: () => Scaffold.of(context).openEndDrawer(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.chip),
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.neutral300,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Profile Card ──────────────────────────────────────────
            const _ProfileHeaderCard(),
            const SizedBox(height: 16),

            // ── Stats ────────────────────────────────────────────────
            const Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    icon: Icons.folder_open_rounded,
                    iconColor: AppColors.indigo500,
                    value: '24',
                    label: 'Projects',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_box_outlined,
                    iconColor: AppColors.emerald,
                    value: '142',
                    label: 'Tasks Done',
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.school_outlined,
                    iconColor: AppColors.purple600,
                    value: '68%',
                    label: 'Learning',
                  ),
                ),
              ],
            ),

            // ── Account Section ──────────────────────────────────────
            const SizedBox(height: 32),
            const _SectionTitle('Account'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.chip),
              ),
              child: const Column(
                children: [
                  _ListTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    trailingText: 'All enabled',
                    showDivider: true,
                  ),
                  _ListTile(
                    icon: Icons.link_rounded,
                    title: 'Connected Accounts',
                    trailingText: '5 connected',
                    showDivider: true,
                  ),
                  _ListTile(
                    icon: Icons.storage_rounded,
                    title: 'Storage & Sync',
                    trailingText: 'Self-hosted',
                    showDivider: false,
                  ),
                ],
              ),
            ),

            // ── Preferences Section ──────────────────────────────────
            const SizedBox(height: 32),
            const _SectionTitle('Preferences'),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.chip),
              ),
              child: const Column(
                children: [
                  _ListTile(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                    trailingText: 'Dark · System',
                    showDivider: true,
                  ),
                  _ListTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About Orbit',
                    trailingText: 'v1.0.0',
                    showDivider: false,
                  ),
                ],
              ),
            ),

            // ── Sign Out ─────────────────────────────────────────────
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => _confirmAndSignOut(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.rose600.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.chip),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: AppColors.rose600,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.rose600,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile header card bound to the signed-in user from [AuthCubit].
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final name = (user?.name?.trim().isNotEmpty ?? false)
            ? user!.name!.trim()
            : (user?.email.split('@').first ?? 'Orbit User');
        final email = user?.email ?? '';
        final handle =
            email.contains('@') ? '@${email.split('@').first}' : '@orbit';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.chip),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.indigo500,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user?.avatarInitial ?? '?',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                handle,
                style: const TextStyle(
                  color: AppColors.neutral400,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.indigo500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: AppColors.indigo500,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.indigo500,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.chip),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.neutral400, fontSize: 12),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.neutral400,
          fontSize: 12,
          fontFamily: 'monospace',
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.icon,
    required this.title,
    required this.trailingText,
    required this.showDivider,
  });

  final IconData icon;
  final String title;
  final String trailingText;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.chip))
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.neutral300, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            trailingText,
            style: const TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.neutral500,
            size: 16,
          ),
        ],
      ),
    );
  }
}
