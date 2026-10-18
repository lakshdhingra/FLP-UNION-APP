import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/admin_summary_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final colors = AppColors.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          side: BorderSide(color: colors.border, width: 1),
        ),
        title: Text('Sign Out',
            style: AppTypography.title2(color: colors.textPrimary)),
        content: Text('Are you sure you want to sign out of admin control?',
            style: AppTypography.body(color: colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: AppTypography.body(
                    color: colors.textSecondary, weight: AppFontWeight.medium)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sign Out',
                style: AppTypography.body(
                    color: colors.danger, weight: AppFontWeight.semibold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final summaryAsync = ref.watch(adminSummaryProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: true,
          bottom: false,
          child: summaryAsync.when(
            loading: () => const AppDashboardSkeleton(),
            error: (err, stack) => ErrorStateWidget(
              message: 'Unable to load administrative overview.',
              onRetry: () => ref.refresh(adminSummaryProvider),
            ),
            data: (data) {
              return RefreshIndicator(
                color: colors.primaryAction,
                backgroundColor: colors.card,
                onRefresh: () async => ref.refresh(adminSummaryProvider.future),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row with Title and Action Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const AppLogo(size: 38),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Admin Overview',
                                    style: AppTypography.title1(
                                        color: colors.textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Platform workforce and infrastructure stats',
                                    style: AppTypography.caption(
                                        color: colors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isDark ? LucideIcons.sun : LucideIcons.moon,
                                  size: 18,
                                  color: colors.textSecondary,
                                ),
                                tooltip: 'Toggle Theme',
                                onPressed: () => ref
                                    .read(themeModeProvider.notifier)
                                    .toggleTheme(),
                              ),
                              IconButton(
                                icon: Icon(
                                  LucideIcons.history,
                                  size: 18,
                                  color: colors.primaryAction,
                                ),
                                tooltip: 'Audit Logs',
                                onPressed: () =>
                                    context.push('/admin/dashboard/audit-logs'),
                              ),
                              IconButton(
                                icon: Icon(
                                  LucideIcons.logOut,
                                  size: 18,
                                  color: colors.danger,
                                ),
                                tooltip: 'Sign Out',
                                onPressed: () => _handleLogout(context, ref),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // 4 Stat Cards Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 600;
                          final cardWidth = isDesktop
                              ? (constraints.maxWidth - (AppSpacing.sm * 3)) / 4
                              : (constraints.maxWidth - AppSpacing.sm) / 2;

                          return Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              _StatGridCard(
                                width: cardWidth,
                                label: 'States Covered',
                                value: data.states,
                                icon: LucideIcons.mapPin,
                                accentColor: colors.info,
                              ),
                              _StatGridCard(
                                width: cardWidth,
                                label: 'District Proprietors',
                                value: data.managers,
                                icon: LucideIcons.userCheck,
                                accentColor: colors.primaryAction,
                              ),
                              _StatGridCard(
                                width: cardWidth,
                                label: 'Total Engineers',
                                value: data.engineers,
                                icon: LucideIcons.users,
                                accentColor: colors.success,
                              ),
                              _StatGridCard(
                                width: cardWidth,
                                label: 'Open Issues',
                                value: data.openIssues,
                                icon: LucideIcons.alertCircle,
                                accentColor: colors.warning,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Active vs Inactive Ratio Card
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Engineers Operational Status',
                                  style: AppTypography.title3(
                                      color: colors.textPrimary),
                                ),
                                Text(
                                  '${data.engineers} Total',
                                  style: AppTypography.caption(
                                      color: colors.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: colors.secondarySurface,
                                      borderRadius: AppRadius.cardRadius,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: colors.success,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text('Active',
                                                style: AppTypography.caption(
                                                    color: colors.textMuted)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${data.activeEngineers}',
                                          style: AppTypography.title2(
                                              color: colors.success),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: colors.secondarySurface,
                                      borderRadius: AppRadius.cardRadius,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: colors.warning,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text('Inactive',
                                                style: AppTypography.caption(
                                                    color: colors.textMuted)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${data.inactiveEngineers}',
                                          style: AppTypography.title2(
                                              color: colors.warning),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Engineers by State Section
                      Text(
                        'State Distribution',
                        style: AppTypography.title3(color: colors.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        child: Column(
                          children: data.engineersByState.map((s) {
                            final fraction = data.engineers > 0
                                ? (s.count / data.engineers).clamp(0.0, 1.0)
                                : 0.0;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 90,
                                    child: Text(
                                      s.state,
                                      style: AppTypography.subhead(
                                          color: colors.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: colors.secondarySurface,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: fraction,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: colors.primaryAction,
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 32,
                                    child: Text(
                                      '${s.count}',
                                      style: AppTypography.subhead(
                                        color: colors.textPrimary,
                                        weight: AppFontWeight.semibold,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatGridCard extends StatelessWidget {
  final double width;
  final String label;
  final int value;
  final IconData icon;
  final Color accentColor;

  const _StatGridCard({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SizedBox(
      width: width,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: AppTypography.caption(color: colors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Icon(icon, size: 14, color: accentColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: AppTypography.title1(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
