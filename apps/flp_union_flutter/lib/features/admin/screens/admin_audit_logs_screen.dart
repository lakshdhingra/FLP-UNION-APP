import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../models/admin_audit_log_dto.dart';
import '../providers/admin_audit_logs_provider.dart';

class AdminAuditLogsScreen extends ConsumerWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final auditLogsAsync = ref.watch(adminAuditLogsProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(size: 26),
              SizedBox(width: 8),
              Text('System Audit Logs'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: auditLogsAsync.when(
            loading: () => const AppSkeletonList(count: 6),
            error: (err, stack) => ErrorStateWidget(
              message: 'Unable to load audit logs.',
              onRetry: () => ref.refresh(adminAuditLogsProvider),
            ),
            data: (response) {
              if (response.data.isEmpty) {
                return RefreshIndicator(
                  color: colors.primaryAction,
                  backgroundColor: colors.card,
                  onRefresh: () async =>
                      ref.refresh(adminAuditLogsProvider.future),
                  child: const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: 420,
                      child: EmptyStateWidget(
                        title: 'No activity logs',
                        description:
                            'No system audit logs recorded in this period.',
                      ),
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                color: colors.primaryAction,
                backgroundColor: colors.card,
                onRefresh: () async =>
                    ref.refresh(adminAuditLogsProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: response.data.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final log = response.data[index];
                    return _AuditLogRowCard(log: log);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuditLogRowCard extends StatelessWidget {
  final AdminAuditLogDto log;

  const _AuditLogRowCard({required this.log});

  AppBadgeVariant _getActionVariant(String action) {
    switch (action.toUpperCase()) {
      case 'CREATE':
        return AppBadgeVariant.success;
      case 'UPDATE':
      case 'UPDATE_PROFILE':
        return AppBadgeVariant.info;
      case 'DELETE':
        return AppBadgeVariant.danger;
      case 'LOGIN':
        return AppBadgeVariant.warning;
      default:
        return AppBadgeVariant.defaultValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final formattedDate =
        DateFormat('MMM dd, yyyy • hh:mm a').format(log.createdAt);

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
                  AppBadge(
                    label: log.action,
                    variant: _getActionVariant(log.action),
                    showDot: true,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    log.targetType,
                    style: AppTypography.label(color: colors.textSecondary),
                  ),
                ],
              ),
              Text(
                formattedDate,
                style: AppTypography.caption(color: colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(LucideIcons.user, size: 14, color: colors.textMuted),
              const SizedBox(width: 8),
              Text(
                'Actor: ',
                style: AppTypography.caption(color: colors.textMuted),
              ),
              Text(
                log.actorName,
                style: AppTypography.subhead(
                  color: colors.textPrimary,
                  weight: AppFontWeight.semibold,
                ),
              ),
            ],
          ),
          if (log.targetId != null && log.targetId!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(LucideIcons.hash, size: 12, color: colors.textMuted),
                const SizedBox(width: 8),
                Text(
                  'Target ID: ',
                  style: AppTypography.caption(color: colors.textMuted),
                ),
                Expanded(
                  child: Text(
                    log.targetId!,
                    style: AppTypography.caption(color: colors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
