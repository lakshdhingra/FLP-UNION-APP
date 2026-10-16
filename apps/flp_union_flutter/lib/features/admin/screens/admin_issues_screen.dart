import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_filter_chip.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../models/admin_issue_dto.dart';
import '../providers/admin_issues_provider.dart';

class AdminIssuesScreen extends ConsumerWidget {
  const AdminIssuesScreen({super.key});

  Future<void> _handleUpdateStatus(
    BuildContext context,
    WidgetRef ref,
    AdminIssueDto item,
  ) async {
    if (item.status == 'RESOLVED' || item.status == 'CLOSED') return;

    final nextStatus = item.status == 'OPEN' ? 'IN_PROGRESS' : 'RESOLVED';
    final displayStatus = nextStatus.replaceAll('_', ' ');
    final colors = AppColors.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          side: BorderSide(color: colors.border, width: 1),
        ),
        title: Text(
          'Update Issue Status',
          style: AppTypography.title2(color: colors.textPrimary),
        ),
        content: Text(
          'Mark "${item.title}" as $displayStatus?',
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
              'Update',
              style: AppTypography.body(
                color: nextStatus == 'RESOLVED'
                    ? colors.success
                    : colors.primaryAction,
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
            .read(adminIssueStatusProvider.notifier)
            .updateIssueStatus(item.id, nextStatus);
      } catch (err) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update status: $err'),
              backgroundColor: AppColors.darkDanger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final filter = ref.watch(adminIssuesFilterProvider);
    final issuesAsync = ref.watch(adminIssuesProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Header Bar & Filters
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support Tickets',
                    style: AppTypography.title1(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Platform requests submitted by district managers',
                    style: AppTypography.caption(color: colors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      AppFilterChip(
                        label: 'All Tickets',
                        isSelected: filter.isEmpty,
                        onTap: () {
                          ref.read(adminIssuesFilterProvider.notifier).state =
                              '';
                        },
                      ),
                      const SizedBox(width: 8),
                      AppFilterChip(
                        label: 'Open Only',
                        isSelected: filter == 'OPEN',
                        onTap: () {
                          ref.read(adminIssuesFilterProvider.notifier).state =
                              'OPEN';
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tickets List
            Expanded(
              child: issuesAsync.when(
                loading: () => const AppSkeletonList(count: 5),
                error: (err, stack) => ErrorStateWidget(
                  message: 'Unable to load support issues.',
                  onRetry: () => ref.refresh(adminIssuesProvider),
                ),
                data: (response) {
                  if (response.data.isEmpty) {
                    return RefreshIndicator(
                      color: colors.primaryAction,
                      backgroundColor: colors.card,
                      onRefresh: () async =>
                          ref.refresh(adminIssuesProvider.future),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 420,
                          child: EmptyStateWidget(
                            title: 'No issues found',
                            description: filter == 'OPEN'
                                ? 'No open tickets requiring resolution right now.'
                                : 'No support requests recorded in the system.',
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: colors.primaryAction,
                    backgroundColor: colors.card,
                    onRefresh: () async =>
                        ref.refresh(adminIssuesProvider.future),
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
                        return _AdminIssueCard(
                          item: item,
                          onUpdateStatus: () =>
                              _handleUpdateStatus(context, ref, item),
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

class _AdminIssueCard extends StatelessWidget {
  final AdminIssueDto item;
  final VoidCallback onUpdateStatus;

  const _AdminIssueCard({
    required this.item,
    required this.onUpdateStatus,
  });

  AppBadgeVariant _getBadgeVariant(String status) {
    switch (status) {
      case 'OPEN':
        return AppBadgeVariant.warning;
      case 'IN_PROGRESS':
        return AppBadgeVariant.info;
      case 'RESOLVED':
        return AppBadgeVariant.success;
      case 'CLOSED':
      default:
        return AppBadgeVariant.defaultValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final showActionButton =
        item.status != 'RESOLVED' && item.status != 'CLOSED';
    final isOpen = item.status == 'OPEN';
    final formattedDate = DateFormat.yMMMd().format(item.createdAt);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    item.type,
                    style: AppTypography.label(color: colors.primaryAction),
                  ),
                  const SizedBox(width: 8),
                  AppBadge(
                    label: item.status.replaceAll('_', ' '),
                    variant: _getBadgeVariant(item.status),
                    showDot: true,
                  ),
                ],
              ),
              Text(
                formattedDate,
                style: AppTypography.caption(color: colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: AppTypography.body(
              color: colors.textPrimary,
              weight: AppFontWeight.semibold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: AppTypography.subhead(color: colors.textSecondary),
          ),
          const SizedBox(height: 10),

          // Reporter info pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colors.secondarySurface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.user, size: 12, color: colors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Reporter: ',
                  style: AppTypography.caption(color: colors.textMuted),
                ),
                Expanded(
                  child: Text(
                    item.reporterName,
                    style: AppTypography.caption(
                      color: colors.textPrimary,
                      weight: AppFontWeight.medium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          if (showActionButton) ...[
            const SizedBox(height: 10),
            Material(
              color: colors.secondarySurface,
              borderRadius: AppRadius.buttonRadius,
              child: InkWell(
                onTap: onUpdateStatus,
                borderRadius: AppRadius.buttonRadius,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.buttonRadius,
                    border: Border.all(color: colors.border, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isOpen ? LucideIcons.clock : LucideIcons.checkCircle,
                        size: 15,
                        color: isOpen ? colors.primaryAction : colors.success,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOpen ? 'Mark In Progress' : 'Mark Resolved',
                        style: AppTypography.caption(
                          color: isOpen ? colors.primaryAction : colors.success,
                          weight: AppFontWeight.semibold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
