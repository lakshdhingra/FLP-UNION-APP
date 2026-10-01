import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../models/admin_state_dto.dart';
import '../providers/admin_states_provider.dart';

class AdminStatesScreen extends ConsumerWidget {
  const AdminStatesScreen({super.key});

  Future<void> _handleToggle(BuildContext context, WidgetRef ref, AdminStateDto item) async {
    final currentStatus = item.isActive;
    final actionText = currentStatus ? 'Deactivate' : 'Activate';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('$actionText State', style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to ${actionText.toLowerCase()} ${item.name}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              actionText,
              style: TextStyle(color: currentStatus ? AppColors.danger : AppColors.success),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref
            .read(adminStatesMutationsProvider.notifier)
            .toggleStateStatus(item.id, !currentStatus);
      } catch (err) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update state: $err'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  void _showAddStateNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Coming Soon', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Adding states from mobile will be available in next update.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statesAsync = ref.watch(adminStatesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'States & Regions',
                    style: AppTypography.xxl.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAddStateNotice(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        LucideIcons.plus,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // States List Body
            Expanded(
              child: statesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (err, stack) => ErrorStateWidget(
                  message: 'Unable to load states.',
                  onRetry: () => ref.refresh(adminStatesProvider),
                ),
                data: (states) {
                  return RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.card,
                    onRefresh: () async => ref.refresh(adminStatesProvider.future),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      itemCount: states.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = states[index];
                        return _StateCard(
                          item: item,
                          onToggle: () => _handleToggle(context, ref, item),
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

class _StateCard extends StatelessWidget {
  final AdminStateDto item;
  final VoidCallback onToggle;

  const _StateCard({
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.building2, size: 20, color: AppColors.accent),
          ),
          const SizedBox(width: AppSpacing.sm),

          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.md.copyWith(
                    fontWeight: AppFontWeight.semibold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item.count.districts} districts',
                      style: AppTypography.xs.copyWith(color: AppColors.textSecondary),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '•',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                    Text(
                      '${item.count.managerProfiles} managers',
                      style: AppTypography.xs.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppBadge(
                label: item.isActive ? 'Active' : 'Inactive',
                variant: item.isActive
                    ? AppBadgeVariant.success
                    : AppBadgeVariant.defaultValue,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: item.isActive ? AppColors.dangerBg : AppColors.successBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: item.isActive ? AppColors.danger : AppColors.success,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    item.isActive ? LucideIcons.powerOff : LucideIcons.power,
                    size: 14,
                    color: item.isActive ? AppColors.danger : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
