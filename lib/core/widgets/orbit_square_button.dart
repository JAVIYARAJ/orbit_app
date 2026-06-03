import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';

/// Small rounded-square icon button used in detail-screen app bars
/// (back / pin / more, etc.).
class OrbitSquareButton extends StatelessWidget {
  const OrbitSquareButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.neutral400,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.chip,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}
