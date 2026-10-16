import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_animations.dart';

class ManagerShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget>? children;

  const ManagerShellScreen({
    super.key,
    required this.navigationShell,
    this.children,
  });

  void _onTap(int branchIndex) {
    HapticFeedback.selectionClick();
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isWide = MediaQuery.of(context).size.width >= 768;

    // Desktop/Wide screen items (Includes secondary Help destination in sidebar)
    final desktopNavItems = [
      const _ShellNavItem(
          icon: LucideIcons.layoutDashboard,
          label: 'Dashboard',
          branchIndex: 0),
      const _ShellNavItem(
          icon: LucideIcons.users, label: 'Engineers', branchIndex: 1),
      const _ShellNavItem(
          icon: LucideIcons.userCheck, label: 'Managers', branchIndex: 2),
      const _ShellNavItem(
          icon: LucideIcons.helpCircle,
          label: 'Help & Support',
          branchIndex: 3),
      const _ShellNavItem(
          icon: LucideIcons.user, label: 'Profile', branchIndex: 4),
    ];

    // Phone Bottom Navigation (Dashboard, Engineers, Managers, Profile)
    final phoneNavItems = [
      const _ShellNavItem(
          icon: LucideIcons.layoutDashboard,
          label: 'Dashboard',
          branchIndex: 0),
      const _ShellNavItem(
          icon: LucideIcons.users, label: 'Engineers', branchIndex: 1),
      const _ShellNavItem(
          icon: LucideIcons.userCheck, label: 'Managers', branchIndex: 2),
      const _ShellNavItem(
          icon: LucideIcons.user, label: 'Profile', branchIndex: 4),
    ];

    if (isWide) {
      // Desktop / Web Linear-style Side Navigation
      return Scaffold(
        backgroundColor: colors.background,
        body: Row(
          children: [
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: colors.surface,
                border:
                    Border(right: BorderSide(color: colors.border, width: 1)),
              ),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: colors.primaryAction,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primaryAction.withAlpha(50),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'T',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: AppFontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TASPU FLP',
                                style: AppTypography.title3(
                                    color: colors.textPrimary),
                              ),
                              Text(
                                'Manager Portal',
                                style: AppTypography.caption(
                                    color: colors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: desktopNavItems.length,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemBuilder: (context, index) {
                          final item = desktopNavItems[index];
                          final isSelected =
                              navigationShell.currentIndex == item.branchIndex;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Material(
                              color: isSelected
                                  ? colors.primaryActionSubtle
                                  : Colors.transparent,
                              borderRadius: AppRadius.buttonRadius,
                              child: InkWell(
                                onTap: () => _onTap(item.branchIndex),
                                borderRadius: AppRadius.buttonRadius,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 18,
                                        color: isSelected
                                            ? colors.primaryAction
                                            : colors.textSecondary,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        item.label,
                                        style: AppTypography.body(
                                          color: isSelected
                                              ? colors.primaryAction
                                              : colors.textPrimary,
                                          weight: isSelected
                                              ? AppFontWeight.semibold
                                              : AppFontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: children != null
                  ? AnimatedBranchContainer(
                      currentIndex: navigationShell.currentIndex,
                      children: children!,
                    )
                  : navigationShell,
            ),
          ],
        ),
      );
    }

    // Phone Mobile-First Animated Bottom Navigation Bar
    return Scaffold(
      backgroundColor: colors.background,
      body: children != null
          ? AnimatedBranchContainer(
              currentIndex: navigationShell.currentIndex,
              children: children!,
            )
          : navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: phoneNavItems.map((item) {
                final isSelected =
                    navigationShell.currentIndex == item.branchIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => _onTap(item.branchIndex),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Active pill highlight behind icon
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primaryActionSubtle
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              item.icon,
                              size: 20,
                              color: isSelected
                                  ? colors.primaryAction
                                  : colors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            style: AppTypography.font(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? AppFontWeight.semibold
                                  : AppFontWeight.medium,
                              color: isSelected
                                  ? colors.primaryAction
                                  : colors.textMuted,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellNavItem {
  final IconData icon;
  final String label;
  final int branchIndex;

  const _ShellNavItem({
    required this.icon,
    required this.label,
    required this.branchIndex,
  });
}
