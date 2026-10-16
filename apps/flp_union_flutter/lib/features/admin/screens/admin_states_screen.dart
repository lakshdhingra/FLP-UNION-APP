import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../models/admin_state_dto.dart';
import '../providers/admin_states_provider.dart';

class AdminStatesScreen extends ConsumerWidget {
  const AdminStatesScreen({super.key});

  Future<void> _handleToggle(
      BuildContext context, WidgetRef ref, AdminStateDto item) async {
    final colors = AppColors.of(context);
    final currentStatus = item.isActive;
    final actionText = currentStatus ? 'Deactivate' : 'Activate';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          side: BorderSide(color: colors.border, width: 1),
        ),
        title: Text('$actionText State',
            style: AppTypography.title2(color: colors.textPrimary)),
        content: Text(
          'Are you sure you want to ${actionText.toLowerCase()} coverage for ${item.name}?',
          style: AppTypography.body(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: AppTypography.body(
                    color: colors.textSecondary, weight: AppFontWeight.medium)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              actionText,
              style: AppTypography.body(
                color: currentStatus ? colors.danger : colors.success,
                weight: AppFontWeight.semibold,
              ),
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
              backgroundColor: AppColors.darkDanger,
            ),
          );
        }
      }
    }
  }

  void _showAddStateNotice(BuildContext context) {
    final colors = AppColors.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          side: BorderSide(color: colors.border, width: 1),
        ),
        title: Text('State Creation',
            style: AppTypography.title2(color: colors.textPrimary)),
        content: Text(
          'Adding new administrative states is managed via web console to configure regional union policies.',
          style: AppTypography.body(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Understood',
                style: AppTypography.body(
                    color: colors.primaryAction,
                    weight: AppFontWeight.semibold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final statesAsync = ref.watch(adminStatesProvider);

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
                        'States & Regions',
                        style: AppTypography.title1(color: colors.textPrimary),
                      ),
                      statesAsync.when(
                        data: (list) => Text(
                          '${list.length} regional jurisdictions',
                          style: AppTypography.caption(color: colors.textMuted),
                        ),
                        loading: () => Text(
                          'Loading regions...',
                          style: AppTypography.caption(color: colors.textMuted),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddStateNotice(context),
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Add State'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primaryAction,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ],
              ),
            ),

            // States List
            Expanded(
              child: statesAsync.when(
                loading: () => const AppSkeletonList(count: 4),
                error: (err, stack) => ErrorStateWidget(
                  message: 'Unable to load regional jurisdictions.',
                  onRetry: () => ref.refresh(adminStatesProvider),
                ),
                data: (states) {
                  return RefreshIndicator(
                    color: colors.primaryAction,
                    backgroundColor: colors.card,
                    onRefresh: () async =>
                        ref.refresh(adminStatesProvider.future),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                        vertical: AppSpacing.xs,
                      ),
                      itemCount: states.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppSpacing.sm),
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
    final colors = AppColors.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.primaryActionSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(LucideIcons.building2,
                size: 20, color: colors.primaryAction),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.body(
                    color: colors.textPrimary,
                    weight: AppFontWeight.semibold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${item.count.districts} districts',
                      style: AppTypography.caption(color: colors.textSecondary),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Text('•',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 10)),
                    ),
                    Text(
                      '${item.count.managerProfiles} managers',
                      style: AppTypography.caption(color: colors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppBadge(
                label: item.isActive ? 'Active' : 'Inactive',
                variant: item.isActive
                    ? AppBadgeVariant.success
                    : AppBadgeVariant.defaultValue,
                showDot: true,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isActive ? colors.dangerBg : colors.successBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: item.isActive
                          ? colors.danger.withAlpha(50)
                          : colors.success.withAlpha(50),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isActive
                            ? LucideIcons.powerOff
                            : LucideIcons.power,
                        size: 11,
                        color: item.isActive ? colors.danger : colors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.isActive ? 'Disable' : 'Enable',
                        style: AppTypography.font(
                          fontSize: 10,
                          fontWeight: AppFontWeight.semibold,
                          color: item.isActive ? colors.danger : colors.success,
                        ),
                      ),
                    ],
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
