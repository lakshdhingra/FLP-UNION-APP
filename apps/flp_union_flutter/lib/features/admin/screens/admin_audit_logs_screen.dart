import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../models/admin_audit_log_dto.dart';
import '../providers/admin_audit_logs_provider.dart';

class AdminAuditLogsScreen extends ConsumerWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditLogsAsync = ref.watch(adminAuditLogsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('System Audit Logs'),
      ),
      body: SafeArea(
        top: false,
        child: auditLogsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (err, stack) => ErrorStateWidget(
            message: 'Unable to load audit logs.',
            onRetry: () => ref.refresh(adminAuditLogsProvider),
          ),
          data: (response) {
            if (response.data.isEmpty) {
              return RefreshIndicator(
                color: AppColors.accent,
                backgroundColor: AppColors.card,
                onRefresh: () async => ref.refresh(adminAuditLogsProvider.future),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(top: 100),
                    child: const EmptyStateWidget(
                      title: 'No activity logs',
                      description: 'No system audit logs recorded yet.',
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: () async => ref.refresh(adminAuditLogsProvider.future),
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: response.data.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final log = response.data[index];
                  return _AuditLogCard(log: log);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AuditLogCard extends StatelessWidget {
  final AdminAuditLogDto log;

  const _AuditLogCard({required this.log});

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
    final formattedDate = DateFormat.yMd().add_jm().format(log.createdAt);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
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
                  ),
                  const SizedBox(width: 8),
                  Text(
                    log.targetType,
                    style: AppTypography.xs.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                formattedDate,
                style: AppTypography.xs.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(LucideIcons.user, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Actor: ${log.actorName}',
                  style: AppTypography.sm.copyWith(
                    fontWeight: AppFontWeight.medium,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (log.targetId != null && log.targetId!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Target ID: ${log.targetId}',
              style: AppTypography.xs.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
