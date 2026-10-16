import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderRadius,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final effectiveBorderRadius = widget.borderRadius ?? AppRadius.cardRadius;
    final effectiveColor = widget.color ?? colors.card;
    final effectiveBorderColor = widget.borderColor ?? colors.border;

    final cardContent = Container(
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      margin: widget.margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveBorderRadius,
        border: Border.all(color: effectiveBorderColor, width: 1),
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return Padding(
        padding: widget.margin ?? EdgeInsets.zero,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            scale: _isPressed ? 0.985 : (_isHovered ? 1.006 : 1.0),
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: Material(
              color: Colors.transparent,
              borderRadius: effectiveBorderRadius,
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  widget.onTap!();
                },
                onHighlightChanged: (val) {
                  if (mounted) setState(() => _isPressed = val);
                },
                borderRadius: effectiveBorderRadius,
                splashColor: colors.cardPressed,
                highlightColor: colors.cardHover,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: widget.padding ??
                      const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    borderRadius: effectiveBorderRadius,
                    border: Border.all(
                      color: _isHovered
                          ? colors.primaryAction.withAlpha(90)
                          : effectiveBorderColor,
                      width: 1,
                    ),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: colors.primaryAction.withAlpha(24),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return cardContent;
  }
}
