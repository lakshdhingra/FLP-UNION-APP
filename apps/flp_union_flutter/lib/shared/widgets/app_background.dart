import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable atmospheric graphite-to-slate gradient background.
///
/// Provides a consistent, understated visual foundation:
/// - Base charcoal: #111315
/// - Slate gradient endpoint: #20272D
/// Elevated solid cards (#272C31) remain clearly distinguishable from this surface.
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.background,
            colors.backgroundGradientEnd,
          ],
        ),
      ),
      child: child,
    );
  }
}
