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
import '../../../shared/widgets/app_background.dart';
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
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _hasAnimated = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final dashboardAsync = ref.watch(managerDashboardProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
              final total = stats.totalEngineers;
              final activePct = total > 0
                  ? ((stats.activeEngineers / total) * 100).round()
                  : 0;

              // Sort designations by count descending
              final sortedDesignations = stats.designationDistribution.entries
                  .toList()
                ..sort((a, b) => b.value.compareTo(a.value));

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
                      // Header: Tag, Greeting, Regional Info, Avatar
                      StaggeredSlideFade(
                        index: 0,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Good day, ${manager.fullName.split(' ').first}',
                                        style: AppTypography.title1(
                                            color: colors.textPrimary),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(LucideIcons.mapPin,
                                              size: 13,
                                              color: colors.textMuted),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${manager.district.name.isNotEmpty ? manager.district.name : 'District'}, ${manager.state.name.isNotEmpty ? manager.state.name : 'State'} • Regional Manager',
                                              style: AppTypography.subhead(
                                                  color: colors.textSecondary),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () => context.go('/manager/profile'),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colors.border,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: AppAvatar(
                                      name: manager.fullName,
                                      size: 46,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Quick Actions Section
                      StaggeredSlideFade(
                        index: 1,
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

                      // Section Heading: Workforce Overview
                      StaggeredSlideFade(
                        index: 2,
                        duration: _hasAnimated
                            ? Duration.zero
                            : const Duration(milliseconds: 400),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Workforce Overview',
                              style: AppTypography.title3(
                                  color: colors.textPrimary),
                            ),
                            if (total > 0)
                              AppBadge(
                                label: '$activePct% Active',
                                variant: activePct >= 50
                                    ? AppBadgeVariant.success
                                    : AppBadgeVariant.warning,
                                showDot: true,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // 3 Metric Cards Row
                      StaggeredSlideFade(
                        index: 3,
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

                      // When No Engineers Exist: Onboarding Card
                      if (stats.totalEngineers == 0) ...[
                        StaggeredSlideFade(
                          index: 4,
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
                                  icon: const Icon(LucideIcons.userPlus,
                                      size: 16),
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

                      // Role / Designation Breakdown Section (All Available Roles)
                      if (sortedDesignations.isNotEmpty &&
                          stats.totalEngineers > 0) ...[
                        StaggeredSlideFade(
                          index: 4,
                          duration: _hasAnimated
                              ? Duration.zero
                              : const Duration(milliseconds: 450),
                          child: Text(
                            'Roles & Designations',
                            style:
                                AppTypography.title3(color: colors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        StaggeredSlideFade(
                          index: 5,
                          duration: _hasAnimated
                              ? Duration.zero
                              : const Duration(milliseconds: 470),
                          child: AppCard(
                            padding:
                                const EdgeInsets.all(AppSpacing.cardPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: sortedDesignations.map((entry) {
                                final count = entry.value;
                                final fraction = total > 0
                                    ? (count / total).clamp(0.0, 1.0)
                                    : 0.0;
                                final pct = (fraction * 100).round();

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              entry.key,
                                              style: AppTypography.body(
                                                color: colors.textPrimary,
                                                weight: AppFontWeight.medium,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$count ($pct%)',
                                            style: AppTypography.subhead(
                                              color: colors.textSecondary,
                                              weight: AppFontWeight.semibold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        height: 6,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: colors.secondarySurface,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: TweenAnimationBuilder<double>(
                                          tween: Tween<double>(
                                              begin: 0, end: fraction),
                                          duration:
                                              const Duration(milliseconds: 600),
                                          curve: Curves.easeOutCubic,
                                          builder: (context, val, child) {
                                            return FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: val,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: colors.primaryAction,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      // Experience Distribution Section
                      if (stats.experienceDistribution.isNotEmpty &&
                          stats.totalEngineers > 0) ...[
                        StaggeredSlideFade(
                          index: 6,
                          duration: _hasAnimated
                              ? Duration.zero
                              : const Duration(milliseconds: 490),
                          child: Text(
                            'Experience Distribution',
                            style:
                                AppTypography.title3(color: colors.textPrimary),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        StaggeredSlideFade(
                          index: 7,
                          duration: _hasAnimated
                              ? Duration.zero
                              : const Duration(milliseconds: 510),
                          child: AppCard(
                            padding:
                                const EdgeInsets.all(AppSpacing.cardPadding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: stats.experienceDistribution.entries
                                  .map((entry) {
                                final count = entry.value;
                                final fraction = total > 0
                                    ? (count / total).clamp(0.0, 1.0)
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
                                            duration: const Duration(
                                                milliseconds: 650),
                                            curve: Curves.easeOutCubic,
                                            builder: (context, val, child) {
                                              return FractionallySizedBox(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: val,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: colors.primaryAction,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
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
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(22),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: accentColor),
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
