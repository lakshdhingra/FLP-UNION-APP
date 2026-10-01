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
import '../models/admin_engineer_dto.dart';
import '../providers/admin_engineers_provider.dart';

class AdminEngineersScreen extends ConsumerStatefulWidget {
  const AdminEngineersScreen({super.key});

  @override
  ConsumerState<AdminEngineersScreen> createState() => _AdminEngineersScreenState();
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
    final engineersAsync = ref.watch(adminEngineersProvider);

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
                    'All Engineers',
                    style: AppTypography.xxl.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${engineersAsync.valueOrNull?.total ?? 0} total',
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
                        ref.read(adminEngineersSearchProvider.notifier).state = val;
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Content Body
            Expanded(
              child: engineersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (err, stack) => ErrorStateWidget(
                  message: 'Unable to load engineers.',
                  onRetry: () => ref.refresh(adminEngineersProvider),
                ),
                data: (response) {
                  if (response.data.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.accent,
                      backgroundColor: AppColors.card,
                      onRefresh: () async => ref.refresh(adminEngineersProvider.future),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 100),
                          child: const EmptyStateWidget(
                            title: 'No engineers',
                            description: 'No engineers registered yet.',
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.card,
                    onRefresh: () async => ref.refresh(adminEngineersProvider.future),
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
                        return _EngineerCard(item: item);
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

class _EngineerCard extends StatelessWidget {
  final AdminEngineerDto item;

  const _EngineerCard({required this.item});

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
                if (item.designation != null && item.designation!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.designation!,
                    style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    AppBadge(
                      label: item.stateName ?? '-',
                      variant: AppBadgeVariant.info,
                    ),
                    AppBadge(
                      label: item.isActive ? 'Active' : 'Inactive',
                      variant: item.isActive ? AppBadgeVariant.success : AppBadgeVariant.warning,
                    ),
                  ],
                ),
                if (item.managerName != null && item.managerName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Mgr: ${item.managerName}',
                    style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
