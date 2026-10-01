import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/engineer.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/manager_directory_provider.dart';

class OtherManagerProfileScreen extends ConsumerWidget {
  final String id;

  const OtherManagerProfileScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final managerAsync = ref.watch(managerProfileByIdProvider(id));
    final engineersAsync = ref.watch(otherManagerEngineersProvider(id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: managerAsync.when(
          data: (mgr) => Text(mgr.fullName, style: AppTypography.lg),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Manager Profile'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: managerAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (err, stack) => ErrorStateWidget(
            message: 'Manager not found.',
            onRetry: () => ref.refresh(managerProfileByIdProvider(id)),
          ),
          data: (manager) {
            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: () async {
                ref.refresh(managerProfileByIdProvider(id));
                ref.refresh(otherManagerEngineersProvider(id));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header Section
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Column(
                          children: [
                            AppAvatar(name: manager.fullName, size: 72),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              manager.fullName,
                              style: AppTypography.xxl.copyWith(
                                fontWeight: AppFontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              manager.email,
                              style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                AppBadge(
                                  label: manager.district.name.isNotEmpty
                                      ? manager.district.name
                                      : 'District',
                                  variant: AppBadgeVariant.defaultValue,
                                ),
                                AppBadge(
                                  label: manager.state.name.isNotEmpty
                                      ? manager.state.name
                                      : 'State',
                                  variant: AppBadgeVariant.info,
                                ),
                                AppBadge(
                                  label: '${manager.totalEngineers} engineers',
                                  variant: AppBadgeVariant.success,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Contact Section Title
                    Text(
                      'CONTACT',
                      style: AppTypography.xs.copyWith(
                        fontWeight: AppFontWeight.semibold,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.phone, size: 14, color: AppColors.accent),
                              const SizedBox(width: 10),
                              Text(
                                manager.mobile.isNotEmpty ? manager.mobile : 'N/A',
                                style: AppTypography.md.copyWith(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(LucideIcons.mail, size: 14, color: AppColors.accent),
                              const SizedBox(width: 10),
                              Text(
                                manager.email.isNotEmpty ? manager.email : 'N/A',
                                style: AppTypography.md.copyWith(color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Engineers Section Title & List
                    engineersAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(color: AppColors.accent),
                        ),
                      ),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (engineers) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ENGINEERS (${engineers.length})',
                              style: AppTypography.xs.copyWith(
                                fontWeight: AppFontWeight.semibold,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            if (engineers.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: AppSpacing.xl),
                                child: Center(
                                  child: Text(
                                    'No engineers assigned to this manager.',
                                    style: TextStyle(color: AppColors.textMuted, fontSize: AppFontSize.md),
                                  ),
                                ),
                              )
                            else
                              ...engineers.map((eng) => _ManagerEngineerCard(engineer: eng)),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
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

class _ManagerEngineerCard extends StatelessWidget {
  final Engineer engineer;

  const _ManagerEngineerCard({required this.engineer});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          AppAvatar(name: engineer.fullName, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  engineer.fullName,
                  style: AppTypography.md.copyWith(
                    fontWeight: AppFontWeight.medium,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  engineer.phone,
                  style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                ),
                if (engineer.designation != null && engineer.designation!.isNotEmpty)
                  Text(
                    engineer.designation!,
                    style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          AppBadge(
            label: engineer.isActive ? 'Active' : 'Inactive',
            variant: engineer.isActive ? AppBadgeVariant.success : AppBadgeVariant.warning,
          ),
        ],
      ),
    );
  }
}
