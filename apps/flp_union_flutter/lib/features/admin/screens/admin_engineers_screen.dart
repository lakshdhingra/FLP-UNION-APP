import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_search_input.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../models/admin_engineer_dto.dart';
import '../providers/admin_engineers_provider.dart';

class AdminEngineersScreen extends ConsumerStatefulWidget {
  const AdminEngineersScreen({super.key});

  @override
  ConsumerState<AdminEngineersScreen> createState() =>
      _AdminEngineersScreenState();
}

class _AdminEngineersScreenState extends ConsumerState<AdminEngineersScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(adminEngineersSearchProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final engineersAsync = ref.watch(adminEngineersProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Engineers',
                        style: AppTypography.title1(color: colors.textPrimary),
                      ),
                      Text(
                        '${engineersAsync.valueOrNull?.total ?? 0} total enrolled',
                        style: AppTypography.caption(color: colors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: AppSearchInput(
                controller: _searchController,
                placeholder: 'Search engineers across all states...',
                onChanged: (val) {
                  ref.read(adminEngineersSearchProvider.notifier).state = val;
                },
                onClear: () {
                  ref.read(adminEngineersSearchProvider.notifier).state = '';
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Engineers List
            Expanded(
              child: engineersAsync.when(
                loading: () => const AppSkeletonList(count: 6),
                error: (err, stack) => ErrorStateWidget(
                  message: 'Unable to load engineers list.',
                  onRetry: () => ref.refresh(adminEngineersProvider),
                ),
                data: (response) {
                  if (response.data.isEmpty) {
                    return RefreshIndicator(
                      color: colors.primaryAction,
                      backgroundColor: colors.card,
                      onRefresh: () async =>
                          ref.refresh(adminEngineersProvider.future),
                      child: const SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 420,
                          child: EmptyStateWidget(
                            title: 'No engineers found',
                            description:
                                'No engineers registered matching your query.',
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: colors.primaryAction,
                    backgroundColor: colors.card,
                    onRefresh: () async =>
                        ref.refresh(adminEngineersProvider.future),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                        vertical: AppSpacing.xs,
                      ),
                      itemCount: response.data.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = response.data[index];
                        return _AdminEngineerRowCard(item: item);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminEngineerRowCard extends StatelessWidget {
  final AdminEngineerDto item;

  const _AdminEngineerRowCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(name: item.fullName, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.fullName,
                        style: AppTypography.body(
                          color: colors.textPrimary,
                          weight: AppFontWeight.semibold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppBadge(
                      label: item.isActive ? 'Active' : 'Inactive',
                      variant: item.isActive
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.warning,
                      showDot: true,
                    ),
                  ],
                ),
                if (item.designation != null &&
                    item.designation!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.designation!,
                    style: AppTypography.subhead(color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (item.stateName != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.mapPin,
                              size: 12, color: colors.textMuted),
                          const SizedBox(width: 3),
                          Text(
                            item.stateName!,
                            style:
                                AppTypography.caption(color: colors.textMuted),
                          ),
                        ],
                      ),
                    ],
                    if (item.managerName != null &&
                        item.managerName!.isNotEmpty) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.userCheck,
                              size: 12, color: colors.textMuted),
                          const SizedBox(width: 3),
                          Text(
                            'Mgr: ${item.managerName}',
                            style:
                                AppTypography.caption(color: colors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
