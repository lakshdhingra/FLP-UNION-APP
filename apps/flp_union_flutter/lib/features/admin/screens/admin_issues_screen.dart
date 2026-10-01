import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
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

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Update Status',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Mark this issue as $displayStatus?',
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
              'Update',
              style: TextStyle(
                color: nextStatus == 'RESOLVED' ? AppColors.success : AppColors.accent,
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
              content: Text('Failed to update issue status: $err'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(adminIssuesFilterProvider);
    final issuesAsync = ref.watch(adminIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Page Header & Filter Tabs
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support Issues',
                    style: AppTypography.xxl.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _FilterTab(
                        label: 'All',
                        isSelected: filter.isEmpty,
                        onTap: () {
                          ref.read(adminIssuesFilterProvider.notifier).state = '';
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Open Only',
                        isSelected: filter == 'OPEN',
                        onTap: () {
                          ref.read(adminIssuesFilterProvider.notifier).state = 'OPEN';
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Body Content
            Expanded(
              child: issuesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (err, stack) => ErrorStateWidget(
                  message: 'Unable to load issues.',
                  onRetry: () => ref.refresh(adminIssuesProvider),
                ),
                data: (response) {
                  if (response.data.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.accent,
                      backgroundColor: AppColors.card,
                      onRefresh: () async => ref.refresh(adminIssuesProvider.future),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(top: 100),
                          child: const EmptyStateWidget(
                            title: 'No issues',
                            description: 'No support requests found.',
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.card,
                    onRefresh: () async => ref.refresh(adminIssuesProvider.future),
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
                        return _IssueCard(
                          item: item,
                          onUpdateStatus: () => _handleUpdateStatus(context, ref, item),
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

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentSubtle : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.xs.copyWith(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
            fontWeight: isSelected ? AppFontWeight.semibold : AppFontWeight.regular,
          ),
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final AdminIssueDto item;
  final VoidCallback onUpdateStatus;

  const _IssueCard({
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
    final showActionButton = item.status != 'RESOLVED' && item.status != 'CLOSED';
    final isOpen = item.status == 'OPEN';
    final formattedDate = DateFormat.yMd().format(item.createdAt);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Type + Badge + Date)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    item.type,
                    style: AppTypography.xs.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppBadge(
                    label: item.status.replaceAll('_', ' '),
                    variant: _getBadgeVariant(item.status),
                  ),
                ],
              ),
              Text(
                formattedDate,
                style: AppTypography.xs.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title & Description
          Text(
            item.title,
            style: AppTypography.md.copyWith(
              fontWeight: AppFontWeight.semibold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Reporter Box
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Text(
                  'Reporter: ',
                  style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                ),
                Expanded(
                  child: Text(
                    item.reporterName,
                    style: AppTypography.xs.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppFontWeight.medium,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          if (showActionButton) ...[
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: onUpdateStatus,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isOpen ? LucideIcons.clock : LucideIcons.checkCircle,
                      size: 16,
                      color: isOpen ? AppColors.accent : AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isOpen ? 'Mark In Progress' : 'Mark Resolved',
                      style: AppTypography.sm.copyWith(
                        fontWeight: AppFontWeight.semibold,
                        color: isOpen ? AppColors.accent : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
