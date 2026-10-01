import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/engineer_provider.dart';

class EngineerDetailScreen extends ConsumerWidget {
  final String id;

  const EngineerDetailScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineerAsync = ref.watch(engineerDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: engineerAsync.when(
          data: (eng) => Text(eng.fullName, style: AppTypography.lg),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Engineer'),
        ),
      ),
      body: SafeArea(
        top: false,
        child: engineerAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (err, stack) => ErrorStateWidget(
            message: 'Engineer not found.',
            onRetry: () => ref.refresh(engineerDetailProvider(id)),
          ),
          data: (engineer) {
            final isMasked = engineer.isOwned == false;
            final currencyFormat = NumberFormat('#,##,###');

            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: () async => ref.refresh(engineerDetailProvider(id).future),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    // Profile Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Column(
                        children: [
                          AppAvatar(name: engineer.fullName, size: 72),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            engineer.fullName,
                            style: AppTypography.xxl.copyWith(
                              fontWeight: AppFontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (engineer.designation != null && engineer.designation!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              engineer.designation!,
                              style: AppTypography.md.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              AppBadge(
                                label: engineer.isActive ? 'Active' : 'Inactive',
                                variant: engineer.isActive
                                    ? AppBadgeVariant.success
                                    : AppBadgeVariant.warning,
                              ),
                              if (isMasked)
                                const AppBadge(
                                  label: 'External Engineer',
                                  variant: AppBadgeVariant.defaultValue,
                                ),
                            ],
                          ),
                          if (isMasked) ...[
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(LucideIcons.lock, size: 14, color: AppColors.textMuted),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Sensitive information is hidden because this engineer belongs to another manager.',
                                      style: AppTypography.xs.copyWith(color: AppColors.textMuted, height: 1.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),

                    // Contact Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Column(
                        children: [
                          _InfoRow(label: 'Phone', value: engineer.phone),
                          if (engineer.email != null && engineer.email!.isNotEmpty)
                            _InfoRow(label: 'Email', value: engineer.email!),
                          if (!isMasked && engineer.address != null && engineer.address!.isNotEmpty)
                            _InfoRow(label: 'Address', value: engineer.address!),
                        ],
                      ),
                    ),

                    // Regional & Professional Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Column(
                        children: [
                          _InfoRow(label: 'District', value: engineer.district?.name ?? '-'),
                          _InfoRow(label: 'State', value: engineer.state?.name ?? '-'),
                          if (engineer.experienceYears != null)
                            _InfoRow(label: 'Experience', value: '${engineer.experienceYears} years'),
                          if (engineer.skills.isNotEmpty)
                            _InfoRow(label: 'Skills', value: engineer.skills.join(', ')),
                        ],
                      ),
                    ),

                    // Confidential Card (Only when owned)
                    if (!isMasked &&
                        (engineer.govIdType != null ||
                            engineer.salary != null ||
                            (engineer.privateNotes != null && engineer.privateNotes!.isNotEmpty)))
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Column(
                          children: [
                            if (engineer.govIdType != null)
                              _InfoRow(
                                label: engineer.govIdType!,
                                value: engineer.govIdNumber ?? '-',
                              ),
                            if (engineer.salary != null)
                              _InfoRow(
                                label: 'Salary',
                                value: 'Rs.${currencyFormat.format(engineer.salary)}',
                              ),
                            if (engineer.privateNotes != null && engineer.privateNotes!.isNotEmpty)
                              _InfoRow(label: 'Notes', value: engineer.privateNotes!),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: AppTypography.sm.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: AppTypography.sm.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
