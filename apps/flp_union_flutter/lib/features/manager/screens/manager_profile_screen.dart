import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/manager_profile_provider.dart';

class ManagerProfileScreen extends ConsumerStatefulWidget {
  const ManagerProfileScreen({super.key});

  @override
  ConsumerState<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends ConsumerState<ManagerProfileScreen> {
  bool _editing = false;
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEdit(String currentName) {
    setState(() {
      _nameController.text = currentName;
      _editing = true;
    });
  }

  Future<void> _saveEdit() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    try {
      await ref
          .read(managerProfileMutationsProvider.notifier)
          .updateProfile(fullName: newName);
      setState(() => _editing = false);
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $err'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Sign Out', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(managerProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (err, stack) => ErrorStateWidget(
            message: 'Unable to load profile.',
            onRetry: () => ref.refresh(managerProfileProvider),
          ),
          data: (profile) {
            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.card,
              onRefresh: () async => ref.refresh(managerProfileProvider.future),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    // Profile Header Section
                    Padding(
                      padding: const EdgeInsets.vertical(AppSpacing.lg),
                      child: Column(
                        children: [
                          AppAvatar(name: profile.fullName, size: 80),

                          // Inline Name Editor
                          if (_editing)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: SizedBox(
                                width: 280,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _nameController,
                                        style: AppTypography.md.copyWith(color: AppColors.textPrimary),
                                        cursorColor: AppColors.accent,
                                        decoration: const InputDecoration(
                                          hintText: 'Your name',
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _saveEdit,
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(LucideIcons.check, size: 18, color: AppColors.success),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => setState(() => _editing = false),
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(LucideIcons.x, size: 18, color: AppColors.danger),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.sm),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    profile.fullName,
                                    style: AppTypography.xl.copyWith(
                                      fontWeight: AppFontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _startEdit(profile.fullName),
                                    child: const Icon(
                                      LucideIcons.edit2,
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 4),
                          Text(
                            profile.email,
                            style: AppTypography.sm.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const AppBadge(label: 'Manager', variant: AppBadgeVariant.info),
                              const SizedBox(width: 8),
                              AppBadge(
                                label: profile.state.name.isNotEmpty
                                    ? profile.state.name
                                    : 'State',
                                variant: AppBadgeVariant.defaultValue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),

                    // Info Details Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Column(
                        children: [
                          _InfoRow(label: 'Mobile', value: profile.mobile),
                          const SizedBox(height: 12),
                          _InfoRow(label: 'Email', value: profile.email),
                          const SizedBox(height: 12),
                          _InfoRow(label: 'State', value: profile.state.name),
                          const SizedBox(height: 12),
                          _InfoRow(label: 'District', value: profile.district.name),
                          const SizedBox(height: 12),
                          _InfoRow(label: 'Total Engineers', value: '${profile.totalEngineers}'),
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),

                    // Sign Out Button
                    AppButton(
                      label: 'Sign Out',
                      onPress: _handleLogout,
                      variant: AppButtonVariant.danger,
                    ),
                    const SizedBox(height: 60),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.sm.copyWith(color: AppColors.textMuted),
        ),
        Text(
          value,
          style: AppTypography.sm.copyWith(
            color: AppColors.textPrimary,
            fontWeight: AppFontWeight.medium,
          ),
        ),
      ],
    );
  }
}
