import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/issue.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/app_text_input.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/issue_provider.dart';

class ManagerHelpScreen extends ConsumerStatefulWidget {
  const ManagerHelpScreen({super.key});

  @override
  ConsumerState<ManagerHelpScreen> createState() => _ManagerHelpScreenState();
}

class _ManagerHelpScreenState extends ConsumerState<ManagerHelpScreen> {
  String _activeTab = 'new'; // 'new' | 'history'
  String _selectedType = 'ISSUE'; // 'ISSUE' | 'SUPPORT'

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _titleError;
  String? _descriptionError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    setState(() {
      _titleError = null;
      _descriptionError = null;

      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();

      if (title.length < 3) {
        _titleError = 'Subject is required (min 3 characters)';
        isValid = false;
      }

      if (description.length < 10) {
        _descriptionError = 'Description is required (min 10 characters)';
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    if (!_validate()) return;

    setState(() => _isSubmitting = true);
    final colors = AppColors.of(context);

    try {
      await ref.read(issueMutationsProvider.notifier).createIssue(
            type: _selectedType,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
          );

      if (!mounted) return;
      _titleController.clear();
      _descriptionController.clear();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sheet),
            side: BorderSide(color: colors.border, width: 1),
          ),
          title: Row(
            children: [
              Icon(LucideIcons.checkCircle2, color: colors.success, size: 22),
              const SizedBox(width: 10),
              Text('Report Submitted',
                  style: AppTypography.title2(color: colors.textPrimary)),
            ],
          ),
          content: Text(
            'Your ticket has been logged with TASPU administration. You can track progress under "My Reports".',
            style: AppTypography.body(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() => _activeTab = 'history');
              },
              child: Text(
                'View Reports',
                style: AppTypography.body(
                  color: colors.primaryAction,
                  weight: AppFontWeight.semibold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report: $err'),
          backgroundColor: AppColors.darkDanger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  AppBadgeVariant _statusVariant(String status) {
    switch (status.toUpperCase()) {
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
    final issuesAsync = ref.watch(myIssuesProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Help & Support',
                    style: AppTypography.title1(color: colors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Submit inquiries or review existing requests',
                    style: AppTypography.caption(color: colors.textMuted),
                  ),
                ],
              ),
            ),

            // Apple-style Segmented Control Tabs
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: colors.secondarySurface,
                borderRadius: AppRadius.inputRadius,
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentTab(
                      label: 'New Request',
                      isSelected: _activeTab == 'new',
                      icon: LucideIcons.send,
                      onTap: () => setState(() => _activeTab = 'new'),
                    ),
                  ),
                  Expanded(
                    child: _SegmentTab(
                      label: 'My Reports',
                      isSelected: _activeTab == 'history',
                      icon: LucideIcons.fileText,
                      onTap: () => setState(() => _activeTab = 'history'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Tab Content Body
            Expanded(
              child: _activeTab == 'new'
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type Toggle Row
                          Text(
                            'Request Type',
                            style: AppTypography.subhead(
                              color: colors.textSecondary,
                              weight: AppFontWeight.medium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _TypeOption(
                                  label: 'Technical Issue',
                                  icon: LucideIcons.alertCircle,
                                  isSelected: _selectedType == 'ISSUE',
                                  onTap: () =>
                                      setState(() => _selectedType = 'ISSUE'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _TypeOption(
                                  label: 'General Support',
                                  icon: LucideIcons.helpCircle,
                                  isSelected: _selectedType == 'SUPPORT',
                                  onTap: () =>
                                      setState(() => _selectedType = 'SUPPORT'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Form Card
                          AppCard(
                            padding:
                                const EdgeInsets.all(AppSpacing.cardPadding),
                            child: Column(
                              children: [
                                AppTextInput(
                                  label: 'Subject / Title *',
                                  placeholder: 'Brief summary of the inquiry',
                                  controller: _titleController,
                                  error: _titleError,
                                  prefixIcon: Icon(LucideIcons.messageSquare,
                                      size: 16, color: colors.textMuted),
                                ),
                                AppTextInput(
                                  label: 'Detailed Description *',
                                  placeholder:
                                      'Provide comprehensive details or steps...',
                                  multiline: true,
                                  maxLines: 5,
                                  controller: _descriptionController,
                                  error: _descriptionError,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          AppButton(
                            label: 'Submit Ticket',
                            onPress: _onSubmit,
                            loading: _isSubmitting,
                            icon: const Icon(LucideIcons.send, size: 16),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    )
                  : issuesAsync.when(
                      loading: () => const AppSkeletonList(count: 4),
                      error: (err, stack) => ErrorStateWidget(
                        message: 'Unable to load tickets.',
                        onRetry: () => ref.refresh(myIssuesProvider),
                      ),
                      data: (issues) {
                        if (issues.isEmpty) {
                          return RefreshIndicator(
                            color: colors.primaryAction,
                            backgroundColor: colors.card,
                            onRefresh: () async =>
                                ref.refresh(myIssuesProvider.future),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: 420,
                                child: EmptyStateWidget(
                                  title: 'No requests yet',
                                  description:
                                      'Tickets submitted by you will be tracked here.',
                                  actionLabel: 'Create Request',
                                  onAction: () =>
                                      setState(() => _activeTab = 'new'),
                                ),
                              ),
                            ),
                          );
                        }

                        final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

                        return RefreshIndicator(
                          color: colors.primaryAction,
                          backgroundColor: colors.card,
                          onRefresh: () async =>
                              ref.refresh(myIssuesProvider.future),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenPadding,
                              vertical: AppSpacing.xs,
                            ),
                            itemCount: issues.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final issue = issues[index];
                              return StaggeredSlideFade(
                                index: index < 8 ? index : 8,
                                child: _IssueCard(
                                  issue: issue,
                                  formattedDate:
                                      dateFormat.format(issue.createdAt),
                                  statusVariant: _statusVariant(issue.status),
                                ),
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

class _SegmentTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? colors.card : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? colors.primaryAction : colors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.subhead(
                color: isSelected ? colors.textPrimary : colors.textMuted,
                weight:
                    isSelected ? AppFontWeight.semibold : AppFontWeight.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryActionSubtle : colors.card,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(
            color: isSelected ? colors.primaryAction : colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? colors.primaryAction : colors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.caption(
                color: isSelected ? colors.primaryAction : colors.textPrimary,
                weight:
                    isSelected ? AppFontWeight.semibold : AppFontWeight.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final Issue issue;
  final String formattedDate;
  final AppBadgeVariant statusVariant;

  const _IssueCard({
    required this.issue,
    required this.formattedDate,
    required this.statusVariant,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                issue.type.toUpperCase(),
                style: AppTypography.label(color: colors.primaryAction),
              ),
              AppBadge(
                label: issue.status.replaceAll('_', ' '),
                variant: statusVariant,
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            issue.title,
            style: AppTypography.body(
              color: colors.textPrimary,
              weight: AppFontWeight.semibold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            issue.description,
            style: AppTypography.subhead(color: colors.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(LucideIcons.clock, size: 12, color: colors.textMuted),
              const SizedBox(width: 4),
              Text(
                formattedDate,
                style: AppTypography.caption(color: colors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
