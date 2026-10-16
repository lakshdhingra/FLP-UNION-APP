import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_typography.dart';

enum AppButtonVariant { primary, secondary, danger, ghost }

class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDisabled = widget.disabled || widget.loading;

    Color backgroundColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        backgroundColor = colors.primaryAction;
        textColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = colors.card;
        textColor = colors.textPrimary;
        borderSide = BorderSide(
          color: _isHovered && !isDisabled
              ? colors.primaryAction.withAlpha(120)
              : colors.border,
          width: 1,
        );
        break;
      case AppButtonVariant.danger:
        backgroundColor = colors.danger;
        textColor = Colors.white;
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        textColor = colors.primaryAction;
        borderSide = BorderSide(
          color: _isHovered && !isDisabled
              ? colors.primaryAction.withAlpha(120)
              : colors.border,
          width: 1,
        );
        break;
    }

    Widget content = widget.loading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.variant == AppButtonVariant.ghost
                    ? colors.primaryAction
                    : textColor,
              ),
            ),
          )
        : Row(
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
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
      minimumSize: Size(widget.fullWidth ? double.infinity : 0, widget.height),
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.buttonRadius,
        side: borderSide,
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    );

    return MouseRegion(
      onEnter: (_) {
        if (!isDisabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (_isHovered) setState(() => _isHovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: AppRadius.buttonRadius,
          boxShadow: _isHovered && !isDisabled
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(45),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: AnimatedScale(
          scale: _isPressed && !isDisabled
              ? 0.975
              : (_isHovered && !isDisabled ? 1.01 : 1.0),
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: Listener(
            onPointerDown: (_) {
              if (!isDisabled) setState(() => _isPressed = true);
            },
            onPointerUp: (_) {
              if (_isPressed) setState(() => _isPressed = false);
            },
            onPointerCancel: (_) {
              if (_isPressed) setState(() => _isPressed = false);
            },
            child: Opacity(
              opacity: isDisabled ? 0.65 : 1.0,
              child: ElevatedButton(
                onPressed: isDisabled
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        widget.onPress();
                      },
                style: buttonStyle,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
