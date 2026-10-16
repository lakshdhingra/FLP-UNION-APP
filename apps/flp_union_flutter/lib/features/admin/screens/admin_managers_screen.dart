import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_search_input.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../models/admin_manager_dto.dart';
import '../providers/admin_managers_provider.dart';

class AdminManagersScreen extends ConsumerStatefulWidget {
  const AdminManagersScreen({super.key});

  @override
  ConsumerState<AdminManagersScreen> createState() =>
      _AdminManagersScreenState();
}

class _AdminManagersScreenState extends ConsumerState<AdminManagersScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(adminManagersSearchProvider),
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
    final managersAsync = ref.watch(adminManagersProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                          'District Managers',
                          style:
                              AppTypography.title1(color: colors.textPrimary),
                        ),
                        Text(
                          '${managersAsync.valueOrNull?.total ?? 0} registered managers',
                          style: AppTypography.caption(color: colors.textMuted),
                        ),
                      ],
                    ),
                    const AppLogo(size: 36),
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
                  placeholder: 'Search managers by name, district, state...',
                  onChanged: (val) {
                    ref.read(adminManagersSearchProvider.notifier).state = val;
                  },
                  onClear: () {
                    ref.read(adminManagersSearchProvider.notifier).state = '';
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Content List
              Expanded(
                child: managersAsync.when(
                  loading: () => const AppSkeletonList(count: 6),
                  error: (err, stack) => ErrorStateWidget(
                    message: 'Unable to load managers.',
                    onRetry: () => ref.refresh(adminManagersProvider),
                  ),
                  data: (response) {
                    if (response.data.isEmpty) {
                      return RefreshIndicator(
                        color: colors.primaryAction,
                        backgroundColor: colors.card,
                        onRefresh: () async =>
                            ref.refresh(adminManagersProvider.future),
                        child: const SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 420,
                            child: EmptyStateWidget(
                              title: 'No managers found',
                              description:
                                  'No district managers registered matching your search criteria.',
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: colors.primaryAction,
                      backgroundColor: colors.card,
                      onRefresh: () async =>
                          ref.refresh(adminManagersProvider.future),
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
                          return _AdminManagerRowCard(item: item);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminManagerRowCard extends StatelessWidget {
  final AdminManagerDto item;

  const _AdminManagerRowCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          AppAvatar(name: item.fullName, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fullName,
                  style: AppTypography.body(
                    color: colors.textPrimary,
                    weight: AppFontWeight.semibold,
                  ),
                ),
                if (item.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.email,
                    style: AppTypography.subhead(color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (item.stateName.isNotEmpty)
                      AppBadge(
                        label: item.stateName,
                        variant: AppBadgeVariant.info,
                      ),
                    if (item.districtName.isNotEmpty)
                      AppBadge(
                        label: item.districtName,
                        variant: AppBadgeVariant.defaultValue,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.secondarySurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.users, size: 12, color: colors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${item.totalEngineers}',
                  style: AppTypography.caption(
                    color: colors.textPrimary,
                    weight: AppFontWeight.semibold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
