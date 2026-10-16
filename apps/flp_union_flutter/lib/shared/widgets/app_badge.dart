import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

enum AppBadgeVariant { success, warning, danger, info, defaultValue }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final bool showDot;
  final Widget? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.defaultValue,
    this.showDot = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Color backgroundColor;
    Color textColor;

    switch (variant) {
      case AppBadgeVariant.success:
        backgroundColor = colors.successBg;
        textColor = colors.success;
        break;
      case AppBadgeVariant.warning:
        backgroundColor = colors.warningBg;
        textColor = colors.warning;
        break;
      case AppBadgeVariant.danger:
        backgroundColor = colors.dangerBg;
        textColor = colors.danger;
        break;
      case AppBadgeVariant.info:
        backgroundColor = colors.infoBg;
        textColor = colors.info;
        break;
      case AppBadgeVariant.defaultValue:
        backgroundColor = colors.secondarySurface;
        textColor = colors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderFull,
        border: Border.all(
          color: textColor.withAlpha(40),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.caption(
              color: textColor,
              weight: AppFontWeight.semibold,
            ),
          ),
        ],
      ),
    );
  }
}
