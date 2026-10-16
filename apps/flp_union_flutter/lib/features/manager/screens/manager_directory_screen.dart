import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/other_manager.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_search_input.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/manager_directory_provider.dart';

class ManagerDirectoryScreen extends ConsumerStatefulWidget {
  const ManagerDirectoryScreen({super.key});

  @override
  ConsumerState<ManagerDirectoryScreen> createState() =>
      _ManagerDirectoryScreenState();
}

class _ManagerDirectoryScreenState
    extends ConsumerState<ManagerDirectoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final managersAsync = ref.watch(sameStateManagersProvider(_searchQuery));

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          top: true,
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Managers Directory',
                          style:
                              AppTypography.title1(color: colors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        managersAsync.when(
                          data: (list) => Text(
                            '${list.length} managers in your state',
                            style:
                                AppTypography.caption(color: colors.textMuted),
                          ),
                          loading: () => Text(
                            'Loading directory...',
                            style:
                                AppTypography.caption(color: colors.textMuted),
                          ),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const AppLogo(size: 38),
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
                  placeholder: 'Search managers by name, district...',
                  onChanged: _onSearchChanged,
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Directory List Content
              Expanded(
                child: managersAsync.when(
                  loading: () => const AppSkeletonList(count: 5),
                  error: (err, stack) => ErrorStateWidget(
                    message: 'Unable to load manager directory.',
                    onRetry: () =>
                        ref.refresh(sameStateManagersProvider(_searchQuery)),
                  ),
                  data: (managers) {
                    if (managers.isEmpty) {
                      return RefreshIndicator(
                        color: colors.primaryAction,
                        backgroundColor: colors.card,
                        onRefresh: () async => ref.refresh(
                            sameStateManagersProvider(_searchQuery).future),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 420,
                            child: EmptyStateWidget(
                              title: _searchQuery.isNotEmpty
                                  ? 'No managers found'
                                  : 'No other managers',
                              description: _searchQuery.isNotEmpty
                                  ? 'No managers match "$_searchQuery".'
                                  : 'No other registered managers found in your state yet.',
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: colors.primaryAction,
                      backgroundColor: colors.card,
                      onRefresh: () async => ref.refresh(
                          sameStateManagersProvider(_searchQuery).future),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding,
                          vertical: AppSpacing.xs,
                        ),
                        itemCount: managers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = managers[index];
                          return StaggeredSlideFade(
                            index: index < 8 ? index : 8,
                            child: _ManagerRowCard(
                              manager: item,
                              onTap: () =>
                                  context.push('/manager/managers/${item.id}'),
                            ),
                          );
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

class _ManagerRowCard extends StatelessWidget {
  final OtherManager manager;
  final VoidCallback onTap;

  const _ManagerRowCard({
    required this.manager,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          Hero(
            tag: 'manager-avatar-${manager.id}',
            child: AppAvatar(name: manager.fullName, size: 48),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manager.fullName,
                  style: AppTypography.body(
                    color: colors.textPrimary,
                    weight: AppFontWeight.semibold,
                  ),
                ),
                if (manager.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    manager.email,
                    style: AppTypography.subhead(color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    AppBadge(
                      label: manager.district.name.isNotEmpty
                          ? manager.district.name
                          : 'District',
                      variant: AppBadgeVariant.defaultValue,
                    ),
                    const SizedBox(width: 8),
                    Icon(LucideIcons.users, size: 12, color: colors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      '${manager.totalEngineers} engineers',
                      style: AppTypography.caption(color: colors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(LucideIcons.chevronRight, size: 18, color: colors.textMuted),
        ],
      ),
    );
  }
}
