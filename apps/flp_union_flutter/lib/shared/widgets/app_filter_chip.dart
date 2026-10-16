import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryActionSubtle : colors.card,
          borderRadius: AppRadius.borderFull,
          border: Border.all(
            color: isSelected ? colors.primaryAction : colors.border,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.caption(
                color: isSelected ? colors.primaryAction : colors.textSecondary,
                weight:
                    isSelected ? AppFontWeight.semibold : AppFontWeight.medium,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primaryAction.withAlpha(40)
                      : colors.secondarySurface,
                  borderRadius: AppRadius.borderFull,
                ),
                child: Text(
                  '$count',
                  style: AppTypography.font(
                    fontSize: 10,
                    fontWeight: AppFontWeight.bold,
                    color: isSelected ? colors.primaryAction : colors.textMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
