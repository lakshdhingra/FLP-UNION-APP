import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/manager_dashboard_provider.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(managerDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: dashboardAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (err, stack) => ErrorStateWidget(
            message: 'Unable to load dashboard.',
            onRetry: () => ref.refresh(managerDashboardProvider),
          ),
          data: (data) {
            final manager = data.manager;
            final stats = data.stats;

            // Sort designation entries to find top role
            final sortedDesignations = stats.designationDistribution.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final topDesignation = sortedDesignations.isNotEmpty ? sortedDesignations.first : null;

            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: () async => ref.refresh(managerDashboardProvider.future),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Row(
                        children: [
                          AppAvatar(name: manager.fullName, size: 56),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  manager.fullName,
                                  style: AppTypography.lg.copyWith(
                                    fontWeight: AppFontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  manager.email,
                                  style: AppTypography.sm.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 4,
                                  children: [
                                    AppBadge(
                                      label: manager.district.name.isNotEmpty
                                          ? manager.district.name
                                          : 'District',
                                      variant: AppBadgeVariant.defaultValue,
                                    ),
                                    const Text('•', style: TextStyle(color: AppColors.textMuted)),
                                    AppBadge(
                                      label: manager.state.name.isNotEmpty
                                          ? manager.state.name
                                          : 'State',
                                      variant: AppBadgeVariant.info,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Overview Section
                    Text(
                      'Overview',
                      style: AppTypography.md.copyWith(
                        fontWeight: AppFontWeight.semibold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: const Icon(LucideIcons.users, size: 20, color: AppColors.accent),
                            value: stats.totalEngineers,
                            label: 'Total',
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _StatCard(
                            icon: const Icon(LucideIcons.userCheck, size: 20, color: AppColors.success),
                            value: stats.activeEngineers,
                            label: 'Active',
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _StatCard(
                            icon: const Icon(LucideIcons.award, size: 20, color: AppColors.warning),
                            value: stats.inactiveEngineers,
                            label: 'Inactive',
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Experience Distribution Section
                    Text(
                      'Experience',
                      style: AppTypography.md.copyWith(
                        fontWeight: AppFontWeight.semibold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Column(
                        children: stats.experienceDistribution.entries.map((entry) {
                          final range = entry.key;
                          final count = entry.value;
                          final fraction = stats.totalEngineers > 0
                              ? (count / stats.totalEngineers).clamp(0.0, 1.0)
                              : 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    '$range yrs',
                                    style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: fraction,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.accent,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 24,
                                  child: Text(
                                    '$count',
                                    style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Top Designation Insight Banner
                    if (topDesignation != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.accentSubtle,
                          borderRadius: AppRadius.borderMd,
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.trendingUp,
                              size: 18,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                                  children: [
                                    const TextSpan(text: 'Most common role: '),
                                    TextSpan(
                                      text: topDesignation.key,
                                      style: AppTypography.sm.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: AppFontWeight.semibold,
                                      ),
                                    ),
                                    TextSpan(text: ' (${topDesignation.value} engineers)'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
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

class _StatCard extends StatelessWidget {
  final Widget icon;
  final int value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.20),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: AppTypography.xxl.copyWith(
              fontWeight: AppFontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.xs.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
