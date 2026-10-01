import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

enum AppBadgeVariant { success, warning, danger, info, defaultValue }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.defaultValue,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (variant) {
      case AppBadgeVariant.success:
        backgroundColor = AppColors.successBg;
        textColor = AppColors.success;
        break;
      case AppBadgeVariant.warning:
        backgroundColor = AppColors.warningBg;
        textColor = AppColors.warning;
        break;
      case AppBadgeVariant.danger:
        backgroundColor = AppColors.dangerBg;
        textColor = AppColors.danger;
        break;
      case AppBadgeVariant.info:
        backgroundColor = AppColors.infoBg;
        textColor = AppColors.info;
        break;
      case AppBadgeVariant.defaultValue:
        backgroundColor = AppColors.surface;
        textColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        label,
        style: AppTypography.xs.copyWith(
          color: textColor,
          fontWeight: AppFontWeight.semibold,
        ),
      ),
    );
  }
}
