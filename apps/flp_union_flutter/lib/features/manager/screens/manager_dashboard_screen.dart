import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/manager_dashboard_provider.dart';

class ManagerDashboardScreen extends ConsumerStatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  ConsumerState<ManagerDashboardScreen> createState() =>
      _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState
    extends ConsumerState<ManagerDashboardScreen> {
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    // After initial entrance duration, mark animated to prevent replay on tab switch
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _hasAnimated = true);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    // Brand Tag & User Header
                    StaggeredSlideFade(
                      index: _hasAnimated ? 0 : 0,
                      duration: _hasAnimated
                          ? Duration.zero
                          : const Duration(milliseconds: 350),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: colors.primaryAction,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'TASPU FLP UNION',
                                style: AppTypography.font(
                                  fontSize: 11,
                                  fontWeight: AppFontWeight.bold,
                                  color: colors.primaryAction,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
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
                                        if (manager
                                            .district.name.isNotEmpty) ...[
                                          Icon(LucideIcons.mapPin,
                                              size: 13,
                                              color: colors.textMuted),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Quick Actions Row
                    StaggeredSlideFade(
                      index: _hasAnimated ? 0 : 1,
                      duration: _hasAnimated
                          ? Duration.zero
                          : const Duration(milliseconds: 380),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
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
                            flex: 3,
                            child: _QuickActionButton(
                              icon: LucideIcons.users,
                              label: 'Engineers',
                              isPrimary: false,
                              onTap: () => context.go('/manager/engineers'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            flex: 3,
                            child: _QuickActionButton(
                              icon: LucideIcons.helpCircle,
                              label: 'Support',
                              isPrimary: false,
                              onTap: () => context.push('/manager/help'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section Heading: Workforce Metrics
                    StaggeredSlideFade(
                      index: _hasAnimated ? 0 : 2,
                      duration: _hasAnimated
                          ? Duration.zero
                          : const Duration(milliseconds: 400),
                      child: Text(
                        'Workforce Overview',
                        style: AppTypography.title3(color: colors.textPrimary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // 3 Metric Cards Row (Animated Counting Numbers)
                    StaggeredSlideFade(
                      index: _hasAnimated ? 0 : 3,
                      duration: _hasAnimated
                          ? Duration.zero
                          : const Duration(milliseconds: 420),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MetricCard(
                              label: 'Total',
                              value: stats.totalEngineers,
                              icon: LucideIcons.users,
                              accentColor: colors.primaryAction,
                              animate: !_hasAnimated,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _MetricCard(
                              label: 'Active',
                              value: stats.activeEngineers,
                              icon: LucideIcons.userCheck,
                              accentColor: colors.success,
                              animate: !_hasAnimated,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _MetricCard(
                              label: 'Inactive',
                              value: stats.inactiveEngineers,
                              icon: LucideIcons.userMinus,
                              accentColor: colors.warning,
                              animate: !_hasAnimated,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // When No Engineers Exist: Attractive Onboarding Card
                    if (stats.totalEngineers == 0) ...[
                      StaggeredSlideFade(
                        index: _hasAnimated ? 0 : 4,
                        duration: _hasAnimated
                            ? Duration.zero
                            : const Duration(milliseconds: 450),
                        child: AppCard(
                          padding:
                              const EdgeInsets.all(AppSpacing.cardPaddingLg),
                          child: Column(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: colors.primaryActionSubtle,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  LucideIcons.users,
                                  size: 26,
                                  color: colors.primaryAction,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Start Building Your Regional Team',
                                style: AppTypography.title2(
                                    color: colors.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'No engineers registered yet in ${manager.district.name.isNotEmpty ? manager.district.name : 'your assigned district'}. Add your first field engineer with verified technical skills, contact details, and certifications.',
                                style: AppTypography.body(
                                    color: colors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    context.push('/manager/engineers/create'),
                                icon:
                                    const Icon(LucideIcons.userPlus, size: 16),
                                label: const Text('Add First Engineer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primaryAction,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: AppRadius.buttonRadius),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    // Top Designation Banner (if available)
                    if (topDesignation != null && stats.totalEngineers > 0) ...[
                      StaggeredSlideFade(
                        index: _hasAnimated ? 0 : 4,
                        duration: _hasAnimated
                            ? Duration.zero
                            : const Duration(milliseconds: 450),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.cardPadding,
                            vertical: 14,
                          ),
                          color: colors.primaryActionSubtle,
                          borderColor: colors.primaryAction.withAlpha(40),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
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
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Experience Distribution Section with Animated Bars
                    if (stats.experienceDistribution.isNotEmpty &&
                        stats.totalEngineers > 0) ...[
                      StaggeredSlideFade(
                        index: _hasAnimated ? 0 : 5,
                        duration: _hasAnimated
                            ? Duration.zero
                            : const Duration(milliseconds: 480),
                        child: Text(
                          'Experience Distribution',
                          style:
                              AppTypography.title3(color: colors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      StaggeredSlideFade(
                        index: _hasAnimated ? 0 : 6,
                        duration: _hasAnimated
                            ? Duration.zero
                            : const Duration(milliseconds: 500),
                        child: AppCard(
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: stats.experienceDistribution.entries
                                .map((entry) {
                              final count = entry.value;
                              final fraction = stats.totalEngineers > 0
                                  ? (count / stats.totalEngineers)
                                      .clamp(0.0, 1.0)
                                  : 0.0;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 90,
                                      child: Text(
                                        entry.key,
                                        style: AppTypography.caption(
                                          color: colors.textSecondary,
                                          weight: AppFontWeight.medium,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 8,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: colors.secondarySurface,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                              begin: 0, end: fraction),
                                          duration:
                                              const Duration(milliseconds: 650),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, val, child) {
                                            return FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: val,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: colors.primaryAction,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            );
                                          },
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
  final bool animate;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.animate = true,
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
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 13, color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (animate)
            AnimatedCountUpText(
              value: value,
              style: AppTypography.title1(color: colors.textPrimary),
            )
          else
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
      borderRadius: AppRadius.buttonRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.buttonRadius,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: AppRadius.buttonRadius,
            border: Border.all(
              color: isPrimary ? colors.primaryAction : colors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isPrimary ? Colors.white : colors.textPrimary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.subhead(
                    color: isPrimary ? Colors.white : colors.textPrimary,
                    weight: AppFontWeight.medium,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
