import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/admin_summary_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Sign Out', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Sign out of admin?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out', style: TextStyle(color: AppColors.danger)),
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
    final summaryAsync = ref.watch(adminSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: summaryAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (err, stack) => ErrorStateWidget(
            message: 'Unable to load analytics.',
            onRetry: () => ref.refresh(adminSummaryProvider),
          ),
          data: (data) {
            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: () async => ref.refresh(adminSummaryProvider.future),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Admin Dashboard',
                              style: AppTypography.xxl.copyWith(
                                fontWeight: AppFontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'TASPU Platform Overview',
                              style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => _handleLogout(context, ref),
                          child: const Padding(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            child: Icon(LucideIcons.logOut, size: 20, color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 4 Stat Cards Grid
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _StatGridCard(
                          label: 'States',
                          value: data.states,
                          icon: const Icon(LucideIcons.map, size: 20, color: AppColors.info),
                          color: AppColors.info,
                        ),
                        _StatGridCard(
                          label: 'Managers',
                          value: data.managers,
                          icon: const Icon(LucideIcons.userCheck, size: 20, color: AppColors.accent),
                          color: AppColors.accent,
                        ),
                        _StatGridCard(
                          label: 'Engineers',
                          value: data.engineers,
                          icon: const Icon(LucideIcons.users, size: 20, color: AppColors.success),
                          color: AppColors.success,
                        ),
                        _StatGridCard(
                          label: 'Open Issues',
                          value: data.openIssues,
                          icon: const Icon(LucideIcons.alertCircle, size: 20, color: AppColors.warning),
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Active vs Inactive Engineers Row
                    Row(
                      children: [
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              children: [
                                Text(
                                  'Active Engineers',
                                  style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${data.activeEngineers}',
                                  style: AppTypography.xl.copyWith(
                                    fontWeight: AppFontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              children: [
                                Text(
                                  'Inactive',
                                  style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${data.inactiveEngineers}',
                                  style: AppTypography.xl.copyWith(
                                    fontWeight: AppFontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Engineers by State Section Title
                    Text(
                      'ENGINEERS BY STATE',
                      style: AppTypography.xs.copyWith(
                        fontWeight: AppFontWeight.semibold,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Engineers by State List Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: data.engineersByState.map((s) {
                          final fraction = data.engineers > 0
                              ? (s.count / data.engineers).clamp(0.0, 1.0)
                              : 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    s.state,
                                    style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                                    overflow: TextOverflow.ellipsis,
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
                                    '${s.count}',
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
                    const SizedBox(height: 60),
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

class _StatGridCard extends StatelessWidget {
  final String label;
  final int value;
  final Widget icon;
  final Color color;

  const _StatGridCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final width = (MediaQuery.of(context).size.width - (AppSpacing.md * 2) - AppSpacing.sm) / 2;

    return SizedBox(
      width: width,
      child: AppCard(
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
      ),
    );
  }
}
