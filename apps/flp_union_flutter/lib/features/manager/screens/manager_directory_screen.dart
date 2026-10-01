import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/other_manager.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/manager_directory_provider.dart';

class ManagerDirectoryScreen extends ConsumerStatefulWidget {
  const ManagerDirectoryScreen({super.key});

  @override
  ConsumerState<ManagerDirectoryScreen> createState() => _ManagerDirectoryScreenState();
}

class _ManagerDirectoryScreenState extends ConsumerState<ManagerDirectoryScreen> {
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
    final managersAsync = ref.watch(sameStateManagersProvider(_searchQuery));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manager Directory',
                    style: AppTypography.xxl.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Same-state managers',
                    style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              height: 44,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: AppTypography.md.copyWith(color: AppColors.textPrimary),
                      cursorColor: AppColors.accent,
                      decoration: const InputDecoration(
                        hintText: 'Search managers...',
                        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: AppFontSize.md),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // List Content
            Expanded(
              child: managersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (err, stack) => ErrorStateWidget(
                  message: 'Unable to load managers.',
                  onRetry: () => ref.refresh(sameStateManagersProvider(_searchQuery)),
                ),
                data: (managers) {
                  if (managers.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.accent,
                      backgroundColor: AppColors.card,
                      onRefresh: () async => ref.refresh(sameStateManagersProvider(_searchQuery).future),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 400,
                          child: EmptyStateWidget(
                            title: _searchQuery.isNotEmpty ? 'No managers found' : 'No other managers',
                            description: 'No managers in your state yet.',
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.card,
                    onRefresh: () async => ref.refresh(sameStateManagersProvider(_searchQuery).future),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      itemCount: managers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = managers[index];
                        return _ManagerCard(
                          manager: item,
                          onTap: () => context.push('/manager/managers/${item.id}'),
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
    );
  }
}

class _ManagerCard extends StatelessWidget {
  final OtherManager manager;
  final VoidCallback onTap;

  const _ManagerCard({
    required this.manager,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          AppAvatar(name: manager.fullName, size: 48),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manager.fullName,
                  style: AppTypography.md.copyWith(
                    fontWeight: AppFontWeight.semibold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  manager.email,
                  style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    AppBadge(
                      label: manager.district.name.isNotEmpty ? manager.district.name : 'District',
                      variant: AppBadgeVariant.defaultValue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${manager.totalEngineers} engineers',
                      style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(LucideIcons.chevronRight, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
