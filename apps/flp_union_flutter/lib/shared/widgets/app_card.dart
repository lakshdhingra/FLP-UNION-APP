import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_spacing.dart';

class AppCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final effectiveBorderRadius = borderRadius ?? AppRadius.cardRadius;
    final effectiveColor = color ?? colors.card;
    final effectiveBorderColor = borderColor ?? colors.border;

    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveBorderRadius,
        border: Border.all(color: effectiveBorderColor, width: 1),
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: effectiveBorderRadius,
          child: InkWell(
            onTap: onTap,
            borderRadius: effectiveBorderRadius,
            splashColor: colors.cardPressed,
            highlightColor: colors.cardHover,
            child: Container(
              padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: effectiveColor,
                borderRadius: effectiveBorderRadius,
                border: Border.all(color: effectiveBorderColor, width: 1),
              ),
              child: child,
            ),
          ),
        ),
      );
    }

    return cardContent;
  }
}
