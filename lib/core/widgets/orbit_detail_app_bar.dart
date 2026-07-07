import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_square_button.dart';

/// Shared app bar for detail screens (Project / Task / Note).
///
/// Renders a square back button, a centered title and optional trailing
/// [actions] (typically [OrbitSquareButton]s), with a hairline bottom border.
/// Use directly as a [Scaffold.appBar].
class OrbitDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const OrbitDetailAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions = const [],
  });

  final String title;

  /// Defaults to `context.pop()` when omitted.
  final VoidCallback? onBack;

  /// Trailing buttons shown on the right (e.g. pin / more).
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: OrbitSquareButton(
          icon: Icons.chevron_left_rounded,
          iconColor: AppColors.white,
          onTap: onBack ?? () => context.pop(),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.neutral400, fontSize: 20),
      ),
      actions: actions.isEmpty
          ? null
          : [
              for (final action in actions)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: action,
                ),
              const SizedBox(width: 8),
            ],
      shape: const Border(bottom: BorderSide(color: AppColors.divider)),
    );
  }
}
