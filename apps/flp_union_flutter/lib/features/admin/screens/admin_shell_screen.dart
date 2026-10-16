import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_background.dart';

class AdminShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShellScreen({
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
    final colors = AppColors.of(context);
    final isWide = MediaQuery.of(context).size.width >= 768;

    const navItems = [
      _AdminNavItem(icon: LucideIcons.layoutDashboard, label: 'Dashboard'),
      _AdminNavItem(icon: LucideIcons.userCheck, label: 'Managers'),
      _AdminNavItem(icon: LucideIcons.users, label: 'Engineers'),
      _AdminNavItem(icon: LucideIcons.helpCircle, label: 'Issues'),
      _AdminNavItem(icon: LucideIcons.building2, label: 'States'),
    ];

    if (isWide) {
      return AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colors.primaryAction,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: AppFontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TASPU Admin',
                                  style: AppTypography.title3(
                                      color: colors.textPrimary),
                                ),
                                Text(
                                  'Master Control',
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
                          itemCount: navItems.length,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemBuilder: (context, index) {
                            final item = navItems[index];
                            final isSelected =
                                navigationShell.currentIndex == index;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Material(
                                color: isSelected
                                    ? colors.primaryActionSubtle
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: () => _onTap(index),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
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
              Expanded(child: navigationShell),
            ],
          ),
        ),
      );
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(top: BorderSide(color: colors.border, width: 1)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = navigationShell.currentIndex == index;
                  return Expanded(
                    child: InkWell(
                      onTap: () => _onTap(index),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 20,
                            color: isSelected
                                ? colors.primaryAction
                                : colors.textMuted,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: AppTypography.font(
                              fontSize: 10.5,
                              fontWeight: isSelected
                                  ? AppFontWeight.semibold
                                  : AppFontWeight.medium,
                              color: isSelected
                                  ? colors.primaryAction
                                  : colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminNavItem {
  final IconData icon;
  final String label;

  const _AdminNavItem({required this.icon, required this.label});
}
