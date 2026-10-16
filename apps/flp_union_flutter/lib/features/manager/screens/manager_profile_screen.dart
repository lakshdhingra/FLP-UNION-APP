import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_skeleton.dart';
import '../../../shared/widgets/error_state_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/manager_profile_provider.dart';

class ManagerProfileScreen extends ConsumerStatefulWidget {
  const ManagerProfileScreen({super.key});

  @override
  ConsumerState<ManagerProfileScreen> createState() =>
      _ManagerProfileScreenState();
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
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final colors = AppColors.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          side: BorderSide(color: colors.border, width: 1),
        ),
        title: Text('Sign Out',
            style: AppTypography.title2(color: colors.textPrimary)),
        content: Text('Are you sure you want to sign out of your account?',
            style: AppTypography.body(color: colors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: AppTypography.body(
                    color: colors.textSecondary, weight: AppFontWeight.medium)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Sign Out',
                style: AppTypography.body(
                    color: colors.danger, weight: AppFontWeight.semibold)),
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
    final colors = AppColors.of(context);
    final profileAsync = ref.watch(managerProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: profileAsync.when(
          loading: () => const AppDetailSkeleton(),
          error: (err, stack) => ErrorStateWidget(
            message: 'Unable to load profile information.',
            onRetry: () => ref.refresh(managerProfileProvider),
          ),
          data: (profile) {
            return RefreshIndicator(
              color: colors.primaryAction,
              backgroundColor: colors.card,
              onRefresh: () async => ref.refresh(managerProfileProvider.future),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Top Card
                    StaggeredSlideFade(
                      index: 0,
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                        child: Column(
                          children: [
                            Center(
                              child:
                                  AppAvatar(name: profile.fullName, size: 76),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Inline Name Editor
                            if (_editing)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 220,
                                    child: TextField(
                                      controller: _nameController,
                                      style: AppTypography.title2(
                                          color: colors.textPrimary),
                                      cursorColor: colors.primaryAction,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                        hintText: 'Enter name',
                                        border: OutlineInputBorder(
                                          borderRadius: AppRadius.inputRadius,
                                          borderSide: BorderSide(
                                              color: colors.primaryAction),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(LucideIcons.check,
                                        size: 20, color: colors.success),
                                    onPressed: _saveEdit,
                                  ),
                                  IconButton(
                                    icon: Icon(LucideIcons.x,
                                        size: 20, color: colors.textMuted),
                                    onPressed: () =>
                                        setState(() => _editing = false),
                                  ),
                                ],
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    profile.fullName,
                                    style: AppTypography.title1(
                                        color: colors.textPrimary),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _startEdit(profile.fullName),
                                    child: Icon(
                                      LucideIcons.pencil,
                                      size: 15,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 3),
                            Text(
                              profile.email,
                              style: AppTypography.subhead(
                                  color: colors.textSecondary),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const AppBadge(
                                  label: 'District Manager',
                                  variant: AppBadgeVariant.info,
                                  showDot: true,
                                ),
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
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Organization & Contact Section
                    StaggeredSlideFade(
                      index: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account & Region Details',
                            style:
                                AppTypography.title3(color: colors.textPrimary),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppCard(
                            padding:
                                const EdgeInsets.all(AppSpacing.cardPadding),
                            child: Column(
                              children: [
                                _ProfileInfoRow(
                                  icon: LucideIcons.phone,
                                  label: 'Mobile',
                                  value: profile.mobile.isNotEmpty
                                      ? profile.mobile
                                      : 'N/A',
                                ),
                                const Divider(height: 16),
                                _ProfileInfoRow(
                                  icon: LucideIcons.mail,
                                  label: 'Official Email',
                                  value: profile.email,
                                ),
                                const Divider(height: 16),
                                _ProfileInfoRow(
                                  icon: LucideIcons.building2,
                                  label: 'Assigned State',
                                  value: profile.state.name,
                                ),
                                const Divider(height: 16),
                                _ProfileInfoRow(
                                  icon: LucideIcons.mapPin,
                                  label: 'Assigned District',
                                  value: profile.district.name,
                                ),
                                const Divider(height: 16),
                                _ProfileInfoRow(
                                  icon: LucideIcons.users,
                                  label: 'Managed Engineers',
                                  value: '${profile.totalEngineers}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Support & Assistance Section
                    StaggeredSlideFade(
                      index: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Support & Assistance',
                            style:
                                AppTypography.title3(color: colors.textPrimary),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppCard(
                            padding:
                                const EdgeInsets.all(AppSpacing.cardPadding),
                            onTap: () => context.push('/manager/help'),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colors.primaryActionSubtle,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    LucideIcons.helpCircle,
                                    size: 18,
                                    color: colors.primaryAction,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Help & Support Center',
                                        style: AppTypography.body(
                                          color: colors.textPrimary,
                                          weight: AppFontWeight.medium,
                                        ),
                                      ),
                                      Text(
                                        'Report system issues and track support tickets',
                                        style: AppTypography.caption(
                                            color: colors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(LucideIcons.chevronRight,
                                    size: 16, color: colors.textMuted),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Preferences & Theme Section
                    StaggeredSlideFade(
                      index: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Preferences',
                            style:
                                AppTypography.title3(color: colors.textPrimary),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppCard(
                            padding:
                                const EdgeInsets.all(AppSpacing.cardPadding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isDark
                                          ? LucideIcons.moon
                                          : LucideIcons.sun,
                                      size: 18,
                                      color: colors.primaryAction,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dark Appearance',
                                          style: AppTypography.body(
                                            color: colors.textPrimary,
                                            weight: AppFontWeight.medium,
                                          ),
                                        ),
                                        Text(
                                          isDark
                                              ? 'Dark theme active'
                                              : 'Light theme active',
                                          style: AppTypography.caption(
                                              color: colors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Switch.adaptive(
                                  value: isDark,
                                  activeTrackColor: colors.primaryAction,
                                  onChanged: (val) {
                                    HapticFeedback.lightImpact();
                                    ref
                                        .read(themeModeProvider.notifier)
                                        .toggleTheme();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Sign Out Button (Separated from regular settings)
                    StaggeredSlideFade(
                      index: 4,
                      child: AppButton(
                        label: 'Sign Out',
                        icon: const Icon(LucideIcons.logOut, size: 16),
                        onPress: _handleLogout,
                        variant: AppButtonVariant.danger,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
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

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
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
      ],
    );
  }
}
