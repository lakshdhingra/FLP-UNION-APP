import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../models/admin_manager_dto.dart';
import '../providers/admin_managers_provider.dart';

class AdminManagersScreen extends ConsumerStatefulWidget {
  const AdminManagersScreen({super.key});

  @override
  ConsumerState<AdminManagersScreen> createState() => _AdminManagersScreenState();
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
    final managersAsync = ref.watch(adminManagersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Managers',
                    style: AppTypography.xxl.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${managersAsync.valueOrNull?.total ?? 0} total',
                    style: AppTypography.sm.copyWith(color: AppColors.textMuted),
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
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.search,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.md.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (val) {
                        ref.read(adminManagersSearchProvider.notifier).state = val;
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Content Body
            Expanded(
              child: managersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (err, stack) => ErrorStateWidget(
                  message: 'Unable to load managers.',
                  onRetry: () => ref.refresh(adminManagersProvider),
                ),
                data: (response) {
                  if (response.data.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.accent,
                      backgroundColor: AppColors.card,
                      onRefresh: () async => ref.refresh(adminManagersProvider.future),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 100),
                          child: const EmptyStateWidget(
                            title: 'No managers',
                            description: 'No managers registered yet.',
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.card,
                    onRefresh: () async => ref.refresh(adminManagersProvider.future),
                    child: ListView.separated(
                      padding: const EdgeInsets.only(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        bottom: 40,
                      ),
                      itemCount: response.data.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = response.data[index];
                        return _ManagerCard(item: item);
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
  final AdminManagerDto item;

  const _ManagerCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          AppAvatar(name: item.fullName, size: 44),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.fullName,
                  style: AppTypography.md.copyWith(
                    fontWeight: AppFontWeight.semibold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.email,
                    style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 4),
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
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${item.totalEngineers} eng',
            style: AppTypography.sm.copyWith(
              fontWeight: AppFontWeight.medium,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
