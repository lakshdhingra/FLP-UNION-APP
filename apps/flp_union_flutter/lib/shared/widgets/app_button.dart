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
  final Widget? icon;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPress,
    this.loading = false,
    this.disabled = false,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = true,
    this.padding,
    this.icon,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDisabled = disabled || loading;

    Color backgroundColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colors.primaryAction;
        textColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colors.card;
        textColor = colors.textPrimary;
        borderSide = BorderSide(color: colors.border, width: 1);
        break;
      case AppButtonVariant.danger:
        backgroundColor = colors.danger;
        textColor = Colors.white;
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        textColor = colors.primaryAction;
        borderSide = BorderSide(color: colors.border, width: 1);
        break;
    }

    Widget content = loading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.ghost
                    ? colors.primaryAction
                    : textColor,
              ),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTypography.body(
                  color: textColor,
                  weight: AppFontWeight.semibold,
                ),
              ),
            ],
          );

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      disabledBackgroundColor: backgroundColor.withAlpha(128),
      disabledForegroundColor: textColor.withAlpha(128),
      minimumSize: Size(fullWidth ? double.infinity : 0, height),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.buttonRadius,
        side: borderSide,
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    );

    return Opacity(
      opacity: isDisabled ? 0.65 : 1.0,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPress,
        style: buttonStyle,
        child: content,
      ),
    );
  }
}
