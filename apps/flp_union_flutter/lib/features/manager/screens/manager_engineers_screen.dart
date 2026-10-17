import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/engineer.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_filter_chip.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_search_input.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/engineer_provider.dart';

class ManagerEngineersScreen extends ConsumerStatefulWidget {
  const ManagerEngineersScreen({super.key});

  @override
  ConsumerState<ManagerEngineersScreen> createState() =>
      _ManagerEngineersScreenState();
}

class _ManagerEngineersScreenState
    extends ConsumerState<ManagerEngineersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'ALL'; // 'ALL' | 'ACTIVE' | 'INACTIVE'
  String _sortBy = 'NAME'; // 'NAME' | 'EXPERIENCE'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val.trim());
  }

  Future<void> _handleDelete(String id, String name) async {
    final colors = AppColors.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          side: BorderSide(color: colors.border, width: 1),
        ),
        title: Text('Delete Engineer',
            style: AppTypography.title2(color: colors.textPrimary)),
        content: Text(
            'Are you sure you want to remove $name? This action cannot be undone.',
            style: AppTypography.body(color: colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: AppTypography.body(
                    color: colors.textSecondary, weight: AppFontWeight.medium)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete',
                style: AppTypography.body(
                    color: colors.danger, weight: AppFontWeight.semibold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref.read(engineerMutationsProvider.notifier).deleteEngineer(id);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Engineer removed successfully'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      } catch (err) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to delete engineer: $err'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final engineersAsync = ref.watch(myEngineersProvider(_searchQuery));

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
                    Row(
                      children: [
                        const AppLogo(size: 34),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Engineers',
                              style: AppTypography.title1(
                                  color: colors.textPrimary),
                            ),
                            engineersAsync.when(
                              data: (list) => Text(
                                '${list.length} in your workforce',
                                style: AppTypography.caption(
                                    color: colors.textMuted),
                              ),
                              loading: () => Text(
                                'Loading directory...',
                                style: AppTypography.caption(
                                    color: colors.textMuted),
                              ),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      icon: Icon(
                        LucideIcons.refreshCw,
                        size: 18,
                        color: colors.textSecondary,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ref.invalidate(myEngineersProvider(_searchQuery));
                      },
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
                  placeholder: 'Search by name, role, phone...',
                  onChanged: _onSearchChanged,
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Status Filter Chips Row
              engineersAsync.maybeWhen(
                data: (list) {
                  final activeCount = list.where((e) => e.isActive).length;
                  final inactiveCount = list.where((e) => !e.isActive).length;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        AppFilterChip(
                          label: 'All',
                          isSelected: _statusFilter == 'ALL',
                          count: list.length,
                          onTap: () => setState(() => _statusFilter = 'ALL'),
                        ),
                        const SizedBox(width: 8),
                        AppFilterChip(
                          label: 'Active',
                          isSelected: _statusFilter == 'ACTIVE',
                          count: activeCount,
                          onTap: () => setState(() => _statusFilter = 'ACTIVE'),
                        ),
                        const SizedBox(width: 8),
                        AppFilterChip(
                          label: 'Inactive',
                          isSelected: _statusFilter == 'INACTIVE',
                          count: inactiveCount,
                          onTap: () =>
                              setState(() => _statusFilter = 'INACTIVE'),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _sortBy =
                                  _sortBy == 'NAME' ? 'EXPERIENCE' : 'NAME';
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: colors.border, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.arrowUpDown,
                                    size: 13, color: colors.primaryAction),
                                const SizedBox(width: 4),
                                Text(
                                  _sortBy == 'NAME'
                                      ? 'By Name'
                                      : 'By Experience',
                                  style: AppTypography.caption(
                                    color: colors.textPrimary,
                                    weight: AppFontWeight.medium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.xs),

              // List of Engineers
              Expanded(
                child: engineersAsync.when(
                  loading: () => const AppSkeletonList(count: 6),
                  error: (err, stack) => ErrorStateWidget(
                    message: 'Unable to load engineers.',
                    onRetry: () =>
                        ref.refresh(myEngineersProvider(_searchQuery)),
                  ),
                  data: (allEngineers) {
                    // Apply active/inactive filter
                    final engineers = allEngineers.where((e) {
                      if (_statusFilter == 'ACTIVE') return e.isActive;
                      if (_statusFilter == 'INACTIVE') return !e.isActive;
                      return true;
                    }).toList();

                    // Apply sorting
                    if (_sortBy == 'EXPERIENCE') {
                      engineers.sort((a, b) => (b.experienceYears ?? 0)
                          .compareTo(a.experienceYears ?? 0));
                    } else {
                      engineers.sort((a, b) => a.fullName
                          .toLowerCase()
                          .compareTo(b.fullName.toLowerCase()));
                    }

                    if (engineers.isEmpty) {
                      return RefreshIndicator(
                        color: colors.primaryAction,
                        backgroundColor: colors.card,
                        onRefresh: () async => ref
                            .refresh(myEngineersProvider(_searchQuery).future),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 420,
                            child: EmptyStateWidget(
                              title: _searchQuery.isNotEmpty
                                  ? 'No results found'
                                  : (_statusFilter != 'ALL'
                                      ? 'No ${_statusFilter.toLowerCase()} engineers'
                                      : 'No engineers yet'),
                              description: _searchQuery.isNotEmpty
                                  ? 'No engineers matched "$_searchQuery".'
                                  : 'Add engineers to manage assignments, documents, and credentials.',
                              actionLabel:
                                  _searchQuery.isEmpty && _statusFilter == 'ALL'
                                      ? 'Add First Engineer'
                                      : null,
                              onAction: () =>
                                  context.push('/manager/engineers/create'),
                            ),
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: colors.primaryAction,
                      backgroundColor: colors.card,
                      onRefresh: () async =>
                          ref.refresh(myEngineersProvider(_searchQuery).future),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.screenPadding,
                          right: AppSpacing.screenPadding,
                          top: AppSpacing.sm,
                          bottom: 84,
                        ),
                        itemCount: engineers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = engineers[index];
                          return StaggeredSlideFade(
                            index: index < 8 ? index : 8,
                            child: _EngineerRowCard(
                              engineer: item,
                              onTap: () =>
                                  context.push('/manager/engineers/${item.id}'),
                              onEdit: () => context.push(
                                  '/manager/engineers/edit?id=${item.id}'),
                              onDelete: () =>
                                  _handleDelete(item.id, item.fullName),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push('/manager/engineers/create');
          },
          backgroundColor: colors.primaryAction,
          foregroundColor: Colors.white,
          elevation: 2,
          highlightElevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
            side: BorderSide(
              color: Colors.white.withAlpha(30),
              width: 1,
            ),
          ),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: Text(
            'Add Engineer',
            style: AppTypography.body(
              color: Colors.white,
              weight: AppFontWeight.semibold,
            ),
          ),
        ),
      ),
    );
  }
}

class _EngineerRowCard extends ConsumerWidget {
  final Engineer engineer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EngineerRowCard({
    required this.engineer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final photoKey = engineer.profilePhotoUrl ?? '';
    final avatarUrlAsync = photoKey.isNotEmpty
        ? ref.watch(engineerDocumentUrlProvider(photoKey))
        : const AsyncValue<String>.data('');
    final avatarUrl = avatarUrlAsync.valueOrNull;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: 'engineer-avatar-${engineer.id}',
            child: AppAvatar(
              name: engineer.fullName,
              size: 44,
              url: avatarUrl,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        engineer.fullName,
                        style: AppTypography.body(
                          color: colors.textPrimary,
                          weight: AppFontWeight.semibold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AppBadge(
                      label: engineer.isActive ? 'Active' : 'Inactive',
                      variant: engineer.isActive
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.warning,
                      showDot: true,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  (engineer.designation != null &&
                          engineer.designation!.isNotEmpty)
                      ? engineer.designation!
                      : 'Field Engineer',
                  style: AppTypography.subhead(color: colors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (engineer.district?.name != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.mapPin,
                              size: 12, color: colors.textMuted),
                          const SizedBox(width: 3),
                          Text(
                            engineer.district!.name,
                            style:
                                AppTypography.caption(color: colors.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    if (engineer.experienceYears != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.briefcase,
                              size: 12, color: colors.textMuted),
                          const SizedBox(width: 3),
                          Text(
                            '${engineer.experienceYears}y exp',
                            style:
                                AppTypography.caption(color: colors.textMuted),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(LucideIcons.pencil,
                    size: 16, color: colors.textSecondary),
                tooltip: 'Edit',
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: onEdit,
              ),
              IconButton(
                icon: Icon(LucideIcons.trash2, size: 16, color: colors.danger),
                tooltip: 'Delete',
                splashRadius: 18,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
