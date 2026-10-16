import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/manager_dashboard_provider.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final dashboardAsync = ref.watch(managerDashboardProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: dashboardAsync.when(
          loading: () => const AppDashboardSkeleton(),
          error: (err, stack) => ErrorStateWidget(
            message: 'Unable to load dashboard metrics.',
            onRetry: () => ref.refresh(managerDashboardProvider),
          ),
          data: (data) {
            final manager = data.manager;
            final stats = data.stats;

            // Sort designation entries to find top role
            final sortedDesignations = stats.designationDistribution.entries
                .toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final topDesignation =
                sortedDesignations.isNotEmpty ? sortedDesignations.first : null;

            return RefreshIndicator(
              color: colors.primaryAction,
              backgroundColor: colors.card,
              onRefresh: () async =>
                  ref.refresh(managerDashboardProvider.future),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar / Greeting Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good day, ${manager.fullName.split(' ').first}',
                                style: AppTypography.title1(
                                    color: colors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (manager.district.name.isNotEmpty) ...[
                                    Icon(LucideIcons.mapPin,
                                        size: 13, color: colors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${manager.district.name}, ${manager.state.name}',
                                      style: AppTypography.subhead(
                                          color: colors.textSecondary),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/manager/profile'),
                          child: AppAvatar(
                            name: manager.fullName,
                            size: 46,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Quick Actions Row
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: LucideIcons.userPlus,
                            label: 'Add Engineer',
                            isPrimary: true,
                            onTap: () =>
                                context.push('/manager/engineers/create'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _QuickActionButton(
                            icon: LucideIcons.users,
                            label: 'Engineers',
                            isPrimary: false,
                            onTap: () => context.go('/manager/engineers'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _QuickActionButton(
                            icon: LucideIcons.helpCircle,
                            label: 'Support',
                            isPrimary: false,
                            onTap: () => context.go('/manager/help'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section Heading: Workforce Metrics
                    Text(
                      'Workforce Overview',
                      style: AppTypography.title3(color: colors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // 3 Metric Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Total',
                            value: stats.totalEngineers,
                            icon: LucideIcons.users,
                            accentColor: colors.primaryAction,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _MetricCard(
                            label: 'Active',
                            value: stats.activeEngineers,
                            icon: LucideIcons.userCheck,
                            accentColor: colors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _MetricCard(
                            label: 'Inactive',
                            value: stats.inactiveEngineers,
                            icon: LucideIcons.userMinus,
                            accentColor: colors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Top Designation Banner (if available)
                    if (topDesignation != null) ...[
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.cardPadding,
                          vertical: 14,
                        ),
                        color: colors.primaryActionSubtle,
                        borderColor: colors.primaryAction.withAlpha(40),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: colors.primaryAction.withAlpha(30),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                LucideIcons.trendingUp,
                                size: 16,
                                color: colors.primaryAction,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Primary Role: ${topDesignation.key}',
                                    style: AppTypography.body(
                                      color: colors.textPrimary,
                                      weight: AppFontWeight.semibold,
                                    ),
                                  ),
                                  Text(
                                    '${topDesignation.value} of ${stats.totalEngineers} engineers',
                                    style: AppTypography.caption(
                                        color: colors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            AppBadge(
                              label:
                                  '${((topDesignation.value / (stats.totalEngineers > 0 ? stats.totalEngineers : 1)) * 100).round()}%',
                              variant: AppBadgeVariant.info,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Experience Distribution Section
                    if (stats.experienceDistribution.isNotEmpty) ...[
                      Text(
                        'Experience Distribution',
                        style: AppTypography.title3(color: colors.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        child: Column(
                          children:
                              stats.experienceDistribution.entries.map((entry) {
                            final range = entry.key;
                            final count = entry.value;
                            final fraction = stats.totalEngineers > 0
                                ? (count / stats.totalEngineers).clamp(0.0, 1.0)
                                : 0.0;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 64,
                                    child: Text(
                                      '$range yrs',
                                      style: AppTypography.subhead(
                                          color: colors.textSecondary),
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
                                    width: 28,
                                    child: Text(
                                      '$count',
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.caption(
                  color: colors.textMuted,
                  weight: AppFontWeight.medium,
                ),
              ),
              Icon(icon, size: 14, color: accentColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: AppTypography.title1(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: isPrimary ? colors.primaryAction : colors.card,
      borderRadius: AppRadius.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardRadius,
            border:
                isPrimary ? null : Border.all(color: colors.border, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : colors.textPrimary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTypography.font(
                  fontSize: 12,
                  fontWeight: AppFontWeight.medium,
                  color: isPrimary ? Colors.white : colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
