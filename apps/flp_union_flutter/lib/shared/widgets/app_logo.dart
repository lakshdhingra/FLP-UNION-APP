import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable official emblem of the Telangana Authorised Service Centre Proprietors Welfare Society.
/// Formatted cleanly inside a consistent circular container everywhere in the app.
class AppLogo extends StatelessWidget {
  /// The diameter of the circular logo container.
  final double size;

  /// Optional subtle circular border for contrast.
  final bool showBorder;

  /// Custom border color if specified. Defaults to semantic theme border.
  final Color? borderColor;

  /// Optional Hero tag for fluid page transitions.
  final String? heroTag;

  const AppLogo({
    super.key,
    this.size = 64.0,
    this.showBorder = true,
    this.borderColor,
    this.heroTag,
  });

  /// The square-cropped circular asset path of the official Society emblem
  static const String circularAssetPath =
      'assets/images/flp_union_logo_circular.png';

  /// Original source asset path
  static const String originalAssetPath = 'assets/images/flp_union_logo.jpeg';

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final effectiveBorderColor = borderColor ?? colors.border.withAlpha(140);

    Widget circleImage = SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipOval(
            child: Image.asset(
              circularAssetPath,
              width: size,
              height: size,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  originalAssetPath,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.0, -0.02),
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.card,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'T',
                      style: TextStyle(
                        fontSize: size * 0.45,
                        fontWeight: FontWeight.bold,
                        color: colors.primaryAction,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (showBorder)
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: effectiveBorderColor, width: 1),
              ),
            ),
        ],
      ),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: circleImage,
      );
    }

    return circleImage;
  }
}
