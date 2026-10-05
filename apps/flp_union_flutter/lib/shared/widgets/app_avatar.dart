import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class AppAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? url;

  const AppAvatar({
    super.key,
    required this.name,
    this.size = 44.0,
    this.url,
  });

  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitials(),
        ),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.accentSubtle,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.md.copyWith(
          color: AppColors.accent,
          fontWeight: AppFontWeight.bold,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
