import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/engineer.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/manager_directory_provider.dart';
import '../providers/manager_profile_provider.dart';

class OtherManagerProfileScreen extends ConsumerWidget {
  final String id;

  const OtherManagerProfileScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final managerAsync = ref.watch(managerProfileByIdProvider(id));
    final engineersAsync = ref.watch(otherManagerEngineersProvider(id));

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: managerAsync.when(
            data: (mgr) => Text(mgr.fullName),
            loading: () => const Text('Loading...'),
            error: (_, __) => const Text('Proprietor Profile'),
          ),
        ),
        body: SafeArea(
          top: false,
          child: managerAsync.when(
            loading: () => const AppDetailSkeleton(),
            error: (err, stack) => ErrorStateWidget(
              title: 'Proprietor Not Found',
              message: 'Unable to load profile information.',
              onRetry: () => ref.refresh(managerProfileByIdProvider(id)),
            ),
            data: (manager) {
              final photoKey = manager.profilePhotoUrl ?? '';
              final photoUrlAsync = photoKey.isNotEmpty
                  ? ref.watch(managerDocumentUrlProvider(photoKey))
                  : const AsyncValue<String>.data('');
              final photoUrl = photoUrlAsync.valueOrNull;
              return RefreshIndicator(
                color: colors.primaryAction,
                backgroundColor: colors.card,
                onRefresh: () async {
                  ref.invalidate(managerProfileByIdProvider(id));
                  ref.invalidate(otherManagerEngineersProvider(id));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header Card
                      StaggeredSlideFade(
                        index: 0,
                        child: AppCard(
                          padding:
                              const EdgeInsets.all(AppSpacing.cardPaddingLg),
                          child: Column(
                            children: [
                              Center(
                                child: Hero(
                                  tag: 'manager-avatar-${manager.id}',
                                  child: AppAvatar(
                                    name: manager.fullName,
                                    size: 72,
                                    url: photoUrl,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                manager.fullName,
                                style: AppTypography.title1(
                                    color: colors.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                manager.email,
                                style: AppTypography.subhead(
                                    color: colors.textSecondary),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
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
                                    label:
                                        '${manager.totalEngineers} engineers',
                                    variant: AppBadgeVariant.success,
                                    showDot: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Contact Details Section
                      StaggeredSlideFade(
                        index: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Information',
                              style: AppTypography.title3(
                                  color: colors.textPrimary),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppCard(
                              padding:
                                  const EdgeInsets.all(AppSpacing.cardPadding),
                              child: Column(
                                children: [
                                  _ContactRow(
                                    icon: LucideIcons.phone,
                                    label: 'Mobile',
                                    value: manager.mobile.isNotEmpty
                                        ? manager.mobile
                                        : 'Not available',
                                    onTap: manager.mobile.isNotEmpty
                                        ? () {
                                            Clipboard.setData(ClipboardData(
                                                text: manager.mobile));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Phone number copied')),
                                            );
                                          }
                                        : null,
                                  ),
                                  const Divider(height: 16),
                                  _ContactRow(
                                    icon: LucideIcons.mail,
                                    label: 'Email',
                                    value: manager.email.isNotEmpty
                                        ? manager.email
                                        : 'Not available',
                                    onTap: manager.email.isNotEmpty
                                        ? () {
                                            Clipboard.setData(ClipboardData(
                                                text: manager.email));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content:
                                                      Text('Email copied')),
                                            );
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Brands Worked With Section
                      StaggeredSlideFade(
                        index: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Brands Worked With',
                              style: AppTypography.title3(
                                  color: colors.textPrimary),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppCard(
                              padding:
                                  const EdgeInsets.all(AppSpacing.cardPadding),
                              child: manager.brandsWorkedWith.isNotEmpty
                                  ? Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          manager.brandsWorkedWith.map((brand) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: colors.secondarySurface,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: colors.border, width: 1),
                                          ),
                                          child: Text(
                                            brand,
                                            style: AppTypography.caption(
                                              color: colors.textPrimary,
                                              weight: AppFontWeight.medium,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  : Text(
                                      'No brands listed',
                                      style: AppTypography.subhead(
                                        color: colors.textMuted,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Managed Engineers Section
                      engineersAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (engineers) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Engineers in District',
                                    style: AppTypography.title3(
                                        color: colors.textPrimary),
                                  ),
                                  Text(
                                    '${engineers.length} total',
                                    style: AppTypography.caption(
                                        color: colors.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              if (engineers.isEmpty)
                                AppCard(
                                  padding: const EdgeInsets.all(
                                      AppSpacing.cardPaddingLg),
                                  child: Center(
                                    child: Text(
                                      'No engineers currently assigned to this proprietor.',
                                      style: AppTypography.subhead(
                                          color: colors.textMuted),
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: engineers.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: AppSpacing.sm),
                                  itemBuilder: (context, index) {
                                    final eng = engineers[index];
                                    return _OtherEngineerCard(engineer: eng);
                                  },
                                ),
                            ],
                          );
                        },
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

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 16, color: colors.primaryAction),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.caption(color: colors.textMuted),
                  ),
                  Text(
                    value,
                    style: AppTypography.body(
                      color: colors.textPrimary,
                      weight: AppFontWeight.medium,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(LucideIcons.copy, size: 14, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _OtherEngineerCard extends StatelessWidget {
  final Engineer engineer;

  const _OtherEngineerCard({required this.engineer});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          AppAvatar(name: engineer.fullName, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  engineer.fullName,
                  style: AppTypography.body(
                    color: colors.textPrimary,
                    weight: AppFontWeight.semibold,
                  ),
                ),
                Text(
                  (engineer.designation != null &&
                          engineer.designation!.isNotEmpty)
                      ? engineer.designation!
                      : 'Field Engineer',
                  style: AppTypography.caption(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          AppBadge(
            label: engineer.isActive ? 'Active' : 'Inactive',
            variant: engineer.isActive
                ? AppBadgeVariant.success
                : AppBadgeVariant.warning,
            showDot: true,
          ),
        ],
      ),
    );
  }
}
