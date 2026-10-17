import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/predefined_options.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_multi_select.dart';
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
  bool _editingName = false;
  final _nameController = TextEditingController();

  bool _isUploadingPhoto = false;
  bool _isEditingBrands = false;
  List<String> _selectedBrands = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEditName(String currentName) {
    setState(() {
      _nameController.text = currentName;
      _editingName = true;
    });
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    try {
      await ref
          .read(managerProfileMutationsProvider.notifier)
          .updateProfile(fullName: newName);
      setState(() => _editingName = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Name updated successfully'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update name: $err'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'JPG', 'JPEG', 'PNG'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null && file.path!.isNotEmpty) {
        bytes = await XFile(file.path!).readAsBytes();
      }
      if (bytes == null) {
        throw Exception('Unable to read selected image');
      }
      if (bytes.length > 5 * 1024 * 1024) {
        throw Exception(
            'Photo exceeds 5MB limit. Please select a smaller file.');
      }

      setState(() => _isUploadingPhoto = true);

      final ext = (file.extension ??
              (file.name.contains('.') ? file.name.split('.').last : ''))
          .toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      final key = await ref
          .read(managerProfileMutationsProvider.notifier)
          .uploadProfilePhotoToS3(
            fileName: file.name,
            mimeType: mimeType,
            bytes: bytes,
          );

      await ref
          .read(managerProfileMutationsProvider.notifier)
          .updateProfile(profilePhotoUrl: key);

      setState(() => _isUploadingPhoto = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (err) {
      setState(() => _isUploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update photo: $err'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  Future<void> _removePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.of(context).card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          side: BorderSide(color: AppColors.of(context).border, width: 1),
        ),
        title: Text('Remove Photo',
            style:
                AppTypography.title2(color: AppColors.of(context).textPrimary)),
        content: Text('Are you sure you want to remove your profile photo?',
            style:
                AppTypography.body(color: AppColors.of(context).textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await ref
            .read(managerProfileMutationsProvider.notifier)
            .updateProfile(profilePhotoUrl: '');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo removed'),
              backgroundColor: AppColors.darkSuccess,
            ),
          );
        }
      } catch (err) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove photo: $err'),
              backgroundColor: AppColors.darkDanger,
            ),
          );
        }
      }
    }
  }

  Future<void> _saveBrands() async {
    try {
      await ref
          .read(managerProfileMutationsProvider.notifier)
          .updateProfile(brandsWorkedWith: _selectedBrands);
      setState(() => _isEditingBrands = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brands updated successfully'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update brands: $err'),
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

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
              final photoKey = profile.profilePhotoUrl ?? '';
              final photoUrlAsync = photoKey.isNotEmpty
                  ? ref.watch(managerDocumentUrlProvider(photoKey))
                  : const AsyncValue<String>.data('');
              final photoUrl = photoUrlAsync.valueOrNull;

              return RefreshIndicator(
                color: colors.primaryAction,
                backgroundColor: colors.card,
                onRefresh: () async =>
                    ref.refresh(managerProfileProvider.future),
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
                          padding:
                              const EdgeInsets.all(AppSpacing.cardPaddingLg),
                          child: Column(
                            children: [
                              Center(
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colors.border,
                                          width: 2,
                                        ),
                                      ),
                                      child: _isUploadingPhoto
                                          ? SizedBox(
                                              width: 74,
                                              height: 74,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: colors.primaryAction,
                                                ),
                                              ),
                                            )
                                          : AppAvatar(
                                              name: profile.fullName,
                                              size: 74,
                                              url: photoUrl,
                                            ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: _isUploadingPhoto
                                            ? null
                                            : _pickAndUploadPhoto,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: colors.primaryAction,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: colors.card,
                                              width: 2,
                                            ),
                                          ),
                                          child: const Icon(
                                            LucideIcons.camera,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (photoKey.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed:
                                      _isUploadingPhoto ? null : _removePhoto,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'Remove Photo',
                                    style: AppTypography.caption(
                                      color: colors.danger,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.sm),

                              // Name Editor (Fixed to eliminate 14px mobile overflow)
                              if (_editingName)
                                Row(
                                  children: [
                                    Expanded(
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
                                    const SizedBox(width: 6),
                                    IconButton(
                                      icon: Icon(LucideIcons.check,
                                          size: 18, color: colors.success),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          minWidth: 32, minHeight: 32),
                                      onPressed: _saveName,
                                    ),
                                    IconButton(
                                      icon: Icon(LucideIcons.x,
                                          size: 18, color: colors.textMuted),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                          minWidth: 32, minHeight: 32),
                                      onPressed: () =>
                                          setState(() => _editingName = false),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        profile.fullName,
                                        style: AppTypography.title1(
                                            color: colors.textPrimary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () =>
                                          _startEditName(profile.fullName),
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
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  const AppBadge(
                                    label: 'District Manager',
                                    variant: AppBadgeVariant.info,
                                    showDot: true,
                                  ),
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

                      // Section 1: Organization & Contact
                      StaggeredSlideFade(
                        index: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account & Region Details',
                              style: AppTypography.title3(
                                  color: colors.textPrimary),
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

                      // Section 2: Brands Worked With
                      StaggeredSlideFade(
                        index: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Brands Worked With',
                                  style: AppTypography.title3(
                                      color: colors.textPrimary),
                                ),
                                if (!_isEditingBrands)
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedBrands = List<String>.from(
                                            profile.brandsWorkedWith);
                                        _isEditingBrands = true;
                                      });
                                    },
                                    icon: const Icon(LucideIcons.pencil,
                                        size: 13),
                                    label: const Text('Edit'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: colors.primaryAction,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      minimumSize: Size.zero,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppCard(
                              padding:
                                  const EdgeInsets.all(AppSpacing.cardPadding),
                              child: _isEditingBrands
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppMultiSelect(
                                          label: 'Select Affiliated Brands',
                                          placeholder: 'Choose brands...',
                                          options: PredefinedOptions.brands,
                                          selectedValues: _selectedBrands,
                                          onChanged: (brands) => setState(
                                              () => _selectedBrands = brands),
                                          dialogTitle: 'Select Brands',
                                          allowCustom: true,
                                          customOptionLabel: 'Other Brand',
                                        ),
                                        const SizedBox(height: 14),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () => setState(() =>
                                                  _isEditingBrands = false),
                                              child: Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: colors.textMuted),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: _saveBrands,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    colors.primaryAction,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                              ),
                                              child: const Text('Save Brands'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : (profile.brandsWorkedWith.isNotEmpty
                                      ? Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: profile.brandsWorkedWith
                                              .map((brand) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: colors.secondarySurface,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: colors.border,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                brand,
                                                style: AppTypography.caption(
                                                  color: colors.textPrimary,
                                                  weight: AppFontWeight.medium,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      : Text(
                                          'No brands specified. Tap Edit to add brands.',
                                          style: AppTypography.subhead(
                                            color: colors.textMuted,
                                          ),
                                        )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Section 3: Support & Assistance
                      StaggeredSlideFade(
                        index: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Support & Assistance',
                              style: AppTypography.title3(
                                  color: colors.textPrimary),
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

                      // Section 4: Preferences & Theme
                      StaggeredSlideFade(
                        index: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preferences',
                              style: AppTypography.title3(
                                  color: colors.textPrimary),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppCard(
                              padding:
                                  const EdgeInsets.all(AppSpacing.cardPadding),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      const SizedBox(width: 14),
                                      Text(
                                        'Dark Mode',
                                        style: AppTypography.body(
                                            color: colors.textPrimary),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: isDark,
                                    activeThumbColor: colors.primaryAction,
                                    onChanged: (val) {
                                      ref
                                          .read(themeModeProvider.notifier)
                                          .setTheme(
                                            val
                                                ? ThemeMode.dark
                                                : ThemeMode.light,
                                          );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Sign Out Button
                      AppButton(
                        label: 'Sign Out',
                        icon: const Icon(LucideIcons.logOut, size: 18),
                        variant: AppButtonVariant.danger,
                        fullWidth: true,
                        onPress: _handleLogout,
                      ),
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
        const SizedBox(width: 12),
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
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
