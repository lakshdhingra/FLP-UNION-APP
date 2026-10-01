import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/issue.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_input.dart';
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
        _titleError = 'Title required';
        isValid = false;
      }

      if (description.length < 10) {
        _descriptionError = 'Description required (min 10 chars)';
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> _onSubmit() async {
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

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
          backgroundColor: AppColors.card,
          title: const Text('Submitted', style: TextStyle(color: AppColors.textPrimary)),
          content: const Text(
            'Your report has been submitted. We will get back to you.',
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
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $err'),
          backgroundColor: AppColors.danger,
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
    final issuesAsync = ref.watch(myIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                'Help & Support',
                style: AppTypography.xxl.copyWith(
                  fontWeight: AppFontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Segmented Control Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppRadius.borderMd,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 'new'),
                      child: Container(
                        padding: const EdgeInsets.vertical(10),
                        decoration: BoxDecoration(
                          color: _activeTab == 'new' ? AppColors.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'New Report',
                          style: AppTypography.sm.copyWith(
                            color: _activeTab == 'new'
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontWeight: AppFontWeight.medium,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 'history'),
                      child: Container(
                        padding: const EdgeInsets.vertical(10),
                        decoration: BoxDecoration(
                          color: _activeTab == 'history' ? AppColors.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'My Reports',
                          style: AppTypography.sm.copyWith(
                            color: _activeTab == 'history'
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontWeight: AppFontWeight.medium,
                          ),
                        ),
                      ),
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
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type Row Selector
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedType = 'ISSUE'),
                                  child: Container(
                                    padding: const EdgeInsets.vertical(10),
                                    decoration: BoxDecoration(
                                      color: _selectedType == 'ISSUE'
                                          ? AppColors.accentSubtle
                                          : Colors.transparent,
                                      borderRadius: AppRadius.borderMd,
                                      border: Border.all(
                                        color: _selectedType == 'ISSUE'
                                            ? AppColors.accent
                                            : AppColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Report Issue',
                                      style: AppTypography.sm.copyWith(
                                        color: _selectedType == 'ISSUE'
                                            ? AppColors.accent
                                            : AppColors.textSecondary,
                                        fontWeight: _selectedType == 'ISSUE'
                                            ? AppFontWeight.semibold
                                            : AppFontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedType = 'SUPPORT'),
                                  child: Container(
                                    padding: const EdgeInsets.vertical(10),
                                    decoration: BoxDecoration(
                                      color: _selectedType == 'SUPPORT'
                                          ? AppColors.accentSubtle
                                          : Colors.transparent,
                                      borderRadius: AppRadius.borderMd,
                                      border: Border.all(
                                        color: _selectedType == 'SUPPORT'
                                            ? AppColors.accent
                                            : AppColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Request Support',
                                      style: AppTypography.sm.copyWith(
                                        color: _selectedType == 'SUPPORT'
                                            ? AppColors.accent
                                            : AppColors.textSecondary,
                                        fontWeight: _selectedType == 'SUPPORT'
                                            ? AppFontWeight.semibold
                                            : AppFontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          AppTextInput(
                            label: 'Subject',
                            placeholder: 'Brief summary',
                            controller: _titleController,
                            error: _titleError,
                          ),

                          AppTextInput(
                            label: 'Description',
                            placeholder: 'Describe the issue in detail...',
                            multiline: true,
                            maxLines: 5,
                            controller: _descriptionController,
                            error: _descriptionError,
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          AppButton(
                            label: 'Submit Report',
                            onPress: _onSubmit,
                            loading: _isSubmitting,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    )
                  : issuesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppColors.accent),
                      ),
                      error: (err, stack) => Center(
                        child: Text(
                          'Unable to load reports.',
                          style: AppTypography.md.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      data: (issues) {
                        if (issues.isEmpty) {
                          return RefreshIndicator(
                            color: AppColors.accent,
                            backgroundColor: AppColors.card,
                            onRefresh: () async => ref.refresh(myIssuesProvider.future),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: 400,
                                child: Center(
                                  child: Text(
                                    'No reports submitted yet.',
                                    style: AppTypography.md.copyWith(color: AppColors.textMuted),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final dateFormat = DateFormat('MM/dd/yyyy');

                        return RefreshIndicator(
                          color: AppColors.accent,
                          backgroundColor: AppColors.card,
                          onRefresh: () async => ref.refresh(myIssuesProvider.future),
                          child: ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: issues.length,
                            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final issue = issues[index];
                              return _IssueCard(
                                issue: issue,
                                dateFormat: dateFormat,
                                statusVariant: _statusVariant(issue.status),
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

class _IssueCard extends StatelessWidget {
  final Issue issue;
  final DateFormat dateFormat;
  final AppBadgeVariant statusVariant;

  const _IssueCard({
    required this.issue,
    required this.dateFormat,
    required this.statusVariant,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.title,
                  style: AppTypography.md.copyWith(
                    fontWeight: AppFontWeight.semibold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  issue.description,
                  style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(issue.createdAt),
                  style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppBadge(
            label: issue.status.replaceAll('_', ' '),
            variant: statusVariant,
          ),
        ],
      ),
    );
  }
}
