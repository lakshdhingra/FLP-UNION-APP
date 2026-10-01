import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPress;
  final bool loading;
  final bool disabled;
  final AppButtonVariant variant;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.label,
    required this.onPress,
    this.loading = false,
    this.disabled = false,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading;

    Color backgroundColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = AppColors.accent;
        textColor = AppColors.textPrimary;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = AppColors.card;
        textColor = AppColors.textPrimary;
        borderSide = const BorderSide(color: AppColors.border, width: 1);
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.danger;
        textColor = AppColors.textPrimary;
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        textColor = AppColors.accent;
        borderSide = const BorderSide(color: AppColors.border, width: 1);
        break;
    }

    Widget content = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.ghost ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
          )
        : Text(
            label,
            style: AppTypography.md.copyWith(
              fontWeight: AppFontWeight.semibold,
              color: textColor,
            ),
          );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      disabledBackgroundColor: backgroundColor.withOpacity(0.5),
      disabledForegroundColor: textColor.withOpacity(0.5),
      minimumSize: Size(fullWidth ? double.infinity : 0, 50),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderMd,
        side: borderSide,
      ),
      elevation: 0,
    );

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPress,
        style: buttonStyle,
        child: content,
      ),
    );
  }
}
