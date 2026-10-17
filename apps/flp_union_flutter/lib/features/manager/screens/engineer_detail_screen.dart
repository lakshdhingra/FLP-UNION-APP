import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/engineer_provider.dart';

class EngineerDetailScreen extends ConsumerWidget {
  final String id;

  const EngineerDetailScreen({
    super.key,
    required this.id,
  });

  void _showDocumentPreview(
      BuildContext context, String signedUrl, bool isPdf) {
    final colors = AppColors.of(context);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          side: BorderSide(color: colors.border, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isPdf ? 'PDF Document' : 'Profile Photo',
                    style: AppTypography.title3(color: colors.textPrimary),
                  ),
                  IconButton(
                    icon:
                        Icon(LucideIcons.x, size: 18, color: colors.textMuted),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (!isPdf)
                ClipRRect(
                  borderRadius: AppRadius.cardRadius,
                  child: Image.network(
                    signedUrl,
                    fit: BoxFit.contain,
                    height: 280,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        'Unable to render image preview.',
                        style: AppTypography.subhead(color: colors.danger),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.secondarySurface,
                    borderRadius: AppRadius.cardRadius,
                  ),
                  child: Column(
                    children: [
                      Icon(LucideIcons.fileText,
                          size: 48, color: colors.primaryAction),
                      const SizedBox(height: 12),
                      Text(
                        'Attached PDF Document',
                        style: AppTypography.body(
                            color: colors.textPrimary,
                            weight: AppFontWeight.semibold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Presigned AWS S3 document link active.',
                        style: AppTypography.caption(color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Copy Document URL',
                icon: const Icon(LucideIcons.copy, size: 16),
                variant: AppButtonVariant.secondary,
                onPress: () {
                  Clipboard.setData(ClipboardData(text: signedUrl));
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Presigned document link copied to clipboard'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final engineerAsync = ref.watch(engineerDetailProvider(id));

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: engineerAsync.when(
            data: (eng) => Text(eng.fullName),
            loading: () => const Text('Loading...'),
            error: (_, __) => const Text('Engineer'),
          ),
          actions: [
            engineerAsync.maybeWhen(
              data: (eng) {
                if (eng.isOwned != false) {
                  return IconButton(
                    icon: const Icon(LucideIcons.pencil, size: 18),
                    tooltip: 'Edit Engineer',
                    onPressed: () =>
                        context.push('/manager/engineers/edit?id=${eng.id}'),
                  );
                }
                return const SizedBox.shrink();
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: engineerAsync.when(
            loading: () => const AppDetailSkeleton(),
            error: (err, stack) => ErrorStateWidget(
              title: 'Engineer Not Found',
              message: 'Could not load details for this engineer.',
              onRetry: () => ref.refresh(engineerDetailProvider(id)),
            ),
            data: (engineer) {
              final isMasked = engineer.isOwned == false;
              final currencyFormat = NumberFormat('#,##,###');

              final photoKey = engineer.profilePhotoUrl ?? '';
              final avatarUrlAsync = photoKey.isNotEmpty
                  ? ref.watch(engineerDocumentUrlProvider(photoKey))
                  : const AsyncValue<String>.data('');
              final avatarUrl = avatarUrlAsync.valueOrNull;
              final isPdf = photoKey.toLowerCase().contains('.pdf');

              final aadhaarKey = engineer.aadhaarCardUrl ?? '';
              final aadhaarUrlAsync = (aadhaarKey.isNotEmpty && !isMasked)
                  ? ref.watch(engineerDocumentUrlProvider(aadhaarKey))
                  : const AsyncValue<String>.data('');
              final aadhaarUrl = aadhaarUrlAsync.valueOrNull;
              final isAadhaarPdf = aadhaarKey.toLowerCase().contains('.pdf');

              return RefreshIndicator(
                color: colors.primaryAction,
                backgroundColor: colors.card,
                onRefresh: () async =>
                    ref.refresh(engineerDetailProvider(id).future),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPadding,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Profile Card
                      StaggeredSlideFade(
                        index: 0,
                        child: AppCard(
                          padding:
                              const EdgeInsets.all(AppSpacing.cardPaddingLg),
                          child: Column(
                            children: [
                              Center(
                                child: Hero(
                                  tag: 'engineer-avatar-${engineer.id}',
                                  child: AppAvatar(
                                    name: engineer.fullName,
                                    size: 72,
                                    url: avatarUrl,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                engineer.fullName,
                                style: AppTypography.title1(
                                    color: colors.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                (engineer.designation != null &&
                                        engineer.designation!.isNotEmpty)
                                    ? engineer.designation!
                                    : 'Field Engineer',
                                style: AppTypography.subhead(
                                    color: colors.textSecondary),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                alignment: WrapAlignment.center,
                                children: [
                                  AppBadge(
                                    label: engineer.isActive
                                        ? 'Active Status'
                                        : 'Inactive Status',
                                    variant: engineer.isActive
                                        ? AppBadgeVariant.success
                                        : AppBadgeVariant.warning,
                                    showDot: true,
                                  ),
                                  if (photoKey.isNotEmpty)
                                    AppBadge(
                                      label: isPdf
                                          ? 'PDF Attached'
                                          : 'Photo Attached',
                                      variant: AppBadgeVariant.info,
                                      icon: Icon(
                                        isPdf
                                            ? LucideIcons.fileText
                                            : LucideIcons.image,
                                        size: 11,
                                        color: colors.info,
                                      ),
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
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.secondarySurface,
                                    borderRadius: AppRadius.inputRadius,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.lock,
                                          size: 14, color: colors.textMuted),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Private fields hidden (belongs to another manager).',
                                          style: AppTypography.caption(
                                              color: colors.textMuted),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Document Preview Card (if photo or PDF attached)
                      if (photoKey.isNotEmpty) ...[
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colors.primaryActionSubtle,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  isPdf
                                      ? LucideIcons.fileText
                                      : LucideIcons.image,
                                  size: 20,
                                  color: colors.primaryAction,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isPdf
                                          ? 'Identity / Certification (PDF)'
                                          : 'Profile Photo (S3)',
                                      style: AppTypography.body(
                                        color: colors.textPrimary,
                                        weight: AppFontWeight.semibold,
                                      ),
                                    ),
                                    Text(
                                      'Secure presigned S3 storage',
                                      style: AppTypography.caption(
                                          color: colors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              if (avatarUrl != null && avatarUrl.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () => _showDocumentPreview(
                                      context, avatarUrl, isPdf),
                                  icon: const Icon(LucideIcons.externalLink,
                                      size: 14),
                                  label: const Text('View'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: colors.primaryAction,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Aadhaar Document Card (Confidential, owned only)
                      if (aadhaarKey.isNotEmpty && !isMasked) ...[
                        AppCard(
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colors.successBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  isAadhaarPdf
                                      ? LucideIcons.fileText
                                      : LucideIcons.fileCheck,
                                  size: 20,
                                  color: colors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            isAadhaarPdf
                                                ? 'Aadhaar Card (PDF)'
                                                : 'Aadhaar Card (Image)',
                                            style: AppTypography.body(
                                              color: colors.textPrimary,
                                              weight: AppFontWeight.semibold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(LucideIcons.lock,
                                            size: 12, color: colors.textMuted),
                                      ],
                                    ),
                                    Text(
                                      'Private verification document (S3)',
                                      style: AppTypography.caption(
                                          color: colors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              if (aadhaarUrl != null && aadhaarUrl.isNotEmpty)
                                TextButton.icon(
                                  onPressed: () => _showDocumentPreview(
                                      context, aadhaarUrl, isAadhaarPdf),
                                  icon: const Icon(LucideIcons.externalLink,
                                      size: 14),
                                  label: const Text('View'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: colors.primaryAction,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Contact Information Section
                      StaggeredSlideFade(
                        index: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Information',
                              style: AppTypography.title3(
                                  color: colors.textPrimary),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppCard(
                              padding:
                                  const EdgeInsets.all(AppSpacing.cardPadding),
                              child: Column(
                                children: [
                                  _DetailRow(
                                    icon: LucideIcons.phone,
                                    label: 'Phone',
                                    value: engineer.phone,
                                    onTap: () {
                                      Clipboard.setData(
                                          ClipboardData(text: engineer.phone));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Phone number copied')),
                                      );
                                    },
                                  ),
                                  if (engineer.email != null &&
                                      engineer.email!.isNotEmpty) ...[
                                    const Divider(height: 16),
                                    _DetailRow(
                                      icon: LucideIcons.mail,
                                      label: 'Email',
                                      value: engineer.email!,
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: engineer.email!));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('Email copied')),
                                        );
                                      },
                                    ),
                                  ],
                                  if (!isMasked &&
                                      engineer.address != null &&
                                      engineer.address!.isNotEmpty) ...[
                                    const Divider(height: 16),
                                    _DetailRow(
                                      icon: LucideIcons.home,
                                      label: 'Address',
                                      value: engineer.address!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Professional & Regional Information Section
                      StaggeredSlideFade(
                        index: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Professional & Regional',
                              style: AppTypography.title3(
                                  color: colors.textPrimary),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppCard(
                              padding:
                                  const EdgeInsets.all(AppSpacing.cardPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _DetailRow(
                                    icon: LucideIcons.mapPin,
                                    label: 'District',
                                    value: engineer.district?.name ??
                                        'Not assigned',
                                  ),
                                  const Divider(height: 16),
                                  _DetailRow(
                                    icon: LucideIcons.building2,
                                    label: 'State',
                                    value:
                                        engineer.state?.name ?? 'Not assigned',
                                  ),
                                  if (engineer.experienceYears != null) ...[
                                    const Divider(height: 16),
                                    _DetailRow(
                                      icon: LucideIcons.briefcase,
                                      label: 'Experience',
                                      value:
                                          '${engineer.experienceYears} years',
                                    ),
                                  ],
                                  const Divider(height: 16),
                                  Text(
                                    'Technical Skills',
                                    style: AppTypography.caption(
                                        color: colors.textMuted),
                                  ),
                                  const SizedBox(height: 8),
                                  if (engineer.skills.isNotEmpty)
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: engineer.skills.map((skill) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: colors.secondarySurface,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: colors.border, width: 1),
                                          ),
                                          child: Text(
                                            skill,
                                            style: AppTypography.caption(
                                              color: colors.textPrimary,
                                              weight: AppFontWeight.medium,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  else
                                    Text(
                                      'No technical skills listed',
                                      style: AppTypography.subhead(
                                        color: colors.textMuted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Confidential / Private Section (when owned)
                      if (!isMasked &&
                          (engineer.salary != null ||
                              (engineer.privateNotes != null &&
                                  engineer.privateNotes!.isNotEmpty) ||
                              engineer.govIdType != null)) ...[
                        StaggeredSlideFade(
                          index: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Confidential Records',
                                style: AppTypography.title3(
                                    color: colors.textPrimary),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppCard(
                                padding: const EdgeInsets.all(
                                    AppSpacing.cardPadding),
                                child: Column(
                                  children: [
                                    if (engineer.salary != null)
                                      _DetailRow(
                                        icon: LucideIcons.indianRupee,
                                        label: 'Monthly Compensation',
                                        value:
                                            '₹ ${currencyFormat.format(engineer.salary)}',
                                      ),
                                    if (engineer.govIdType != null) ...[
                                      const Divider(height: 16),
                                      _DetailRow(
                                        icon: LucideIcons.creditCard,
                                        label: engineer.govIdType!,
                                        value:
                                            engineer.govIdNumber ?? 'On file',
                                      ),
                                    ],
                                    if (engineer.privateNotes != null &&
                                        engineer.privateNotes!.isNotEmpty) ...[
                                      const Divider(height: 16),
                                      _DetailRow(
                                        icon: LucideIcons.lock,
                                        label: 'Private Notes',
                                        value: engineer.privateNotes!,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: colors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: AppTypography.subhead(color: colors.textSecondary),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: AppTypography.body(
                  color: colors.textPrimary,
                  weight: AppFontWeight.medium,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(LucideIcons.copy, size: 13, color: colors.textMuted),
            ],
          ],
        ),
      ),
    );
  }
}
