import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class ManagerShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ManagerShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _onTap,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: AppTypography.xs.copyWith(fontWeight: AppFontWeight.medium),
          unselectedLabelStyle: AppTypography.xs.copyWith(fontWeight: AppFontWeight.medium),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.layoutDashboard, size: 20),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.users, size: 20),
              label: 'Engineers',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.userCheck, size: 20),
              label: 'Managers',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.helpCircle, size: 20),
              label: 'Help',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.user, size: 20),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
