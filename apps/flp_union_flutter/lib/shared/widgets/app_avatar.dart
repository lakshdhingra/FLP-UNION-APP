import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class AppAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? url;
  final bool showBorder;

  const AppAvatar({
    super.key,
    required this.name,
    this.size = 44.0,
    this.url,
    this.showBorder = true,
  });

  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Widget avatarContent;

    if (url != null && url!.isNotEmpty) {
      avatarContent = Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(colors),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildInitials(colors);
        },
      );
    } else {
      avatarContent = _buildInitials(colors);
    }

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              showBorder ? Border.all(color: colors.border, width: 1.2) : null,
        ),
        child: ClipOval(child: avatarContent),
      ),
    );
  }

  Widget _buildInitials(AppThemeColors colors) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.primaryActionSubtle,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.font(
          fontSize: size * 0.38,
          fontWeight: AppFontWeight.bold,
          color: colors.primaryAction,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
