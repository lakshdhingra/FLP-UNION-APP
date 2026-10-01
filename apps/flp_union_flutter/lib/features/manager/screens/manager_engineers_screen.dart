import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/engineer.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../providers/engineer_provider.dart';

class ManagerEngineersScreen extends ConsumerStatefulWidget {
  const ManagerEngineersScreen({super.key});

  @override
  ConsumerState<ManagerEngineersScreen> createState() => _ManagerEngineersScreenState();
}

class _ManagerEngineersScreenState extends ConsumerState<ManagerEngineersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val.trim());
  }

  Future<void> _handleDelete(BuildContext context, String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Delete Engineer', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Remove $name? This cannot be undone.', style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref.read(engineerMutationsProvider.notifier).deleteEngineer(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Engineer deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete engineer: $err'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final engineersAsync = ref.watch(myEngineersProvider(_searchQuery));

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
                    'My Engineers',
                    style: AppTypography.xxl.copyWith(
                      fontWeight: AppFontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/manager/engineers/create'),
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

            // Search Bar
            Container(
              height: 44,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: AppTypography.md.copyWith(color: AppColors.textPrimary),
                      cursorColor: AppColors.accent,
                      decoration: const InputDecoration(
                        hintText: 'Search engineers...',
                        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: AppFontSize.md),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Engineers List / States
            Expanded(
              child: engineersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                ),
                error: (err, stack) => ErrorStateWidget(
                  message: 'Unable to load engineers.',
                  onRetry: () => ref.refresh(myEngineersProvider(_searchQuery)),
                ),
                data: (engineers) {
                  if (engineers.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.accent,
                      backgroundColor: AppColors.card,
                      onRefresh: () async => ref.refresh(myEngineersProvider(_searchQuery).future),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 400,
                          child: EmptyStateWidget(
                            title: _searchQuery.isNotEmpty ? 'No engineers found' : 'No engineers yet',
                            description: _searchQuery.isNotEmpty
                                ? 'Try a different search term.'
                                : 'Tap the + button to add your first engineer.',
                            actionLabel: _searchQuery.isEmpty ? 'Add Engineer' : null,
                            onAction: _searchQuery.isEmpty
                                ? () => context.push('/manager/engineers/create')
                                : null,
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.accent,
                    backgroundColor: AppColors.card,
                    onRefresh: () async => ref.refresh(myEngineersProvider(_searchQuery).future),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      itemCount: engineers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = engineers[index];
                        return _EngineerCard(
                          engineer: item,
                          onTap: () => context.push('/manager/engineers/${item.id}'),
                          onEdit: () => context.push('/manager/engineers/edit?id=${item.id}'),
                          onDelete: () => _handleDelete(context, item.id, item.fullName),
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

class _EngineerCard extends StatelessWidget {
  final Engineer engineer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EngineerCard({
    required this.engineer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          AppAvatar(name: engineer.fullName, size: 44),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  engineer.fullName,
                  style: AppTypography.md.copyWith(
                    fontWeight: AppFontWeight.semibold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (engineer.designation != null && engineer.designation!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    engineer.designation!,
                    style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (engineer.district?.name != null)
                      Text(
                        engineer.district!.name,
                        style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                      ),
                    if (engineer.experienceYears != null)
                      Text(
                        '${engineer.experienceYears} yrs exp',
                        style: AppTypography.xs.copyWith(color: AppColors.textMuted),
                      ),
                    AppBadge(
                      label: engineer.isActive ? 'Active' : 'Inactive',
                      variant: engineer.isActive
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.pencil, size: 16, color: AppColors.accent),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.trash2, size: 16, color: AppColors.danger),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
