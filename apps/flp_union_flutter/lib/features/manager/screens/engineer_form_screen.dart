import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_text_input.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/engineer_provider.dart';
import '../providers/manager_dashboard_provider.dart';

class EngineerFormScreen extends ConsumerStatefulWidget {
  final String? engineerId;

  const EngineerFormScreen({
    super.key,
    this.engineerId,
  });

  bool get isEdit => engineerId != null && engineerId!.isNotEmpty;

  @override
  ConsumerState<EngineerFormScreen> createState() => _EngineerFormScreenState();
}

class _EngineerFormScreenState extends ConsumerState<EngineerFormScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _designationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillsController = TextEditingController();
  final _addressController = TextEditingController();
  final _salaryController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedDistrictId;
  String? _selectedDistrictName;

  String? _profilePhotoKey;
  String? _selectedFileName;
  bool _isUploadingPhoto = false;

  String? _fullNameError;
  String? _phoneError;
  String? _emailError;
  String? _districtError;

  bool _isLoading = false;
  bool _isPopulated = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _designationController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    _addressController.dispose();
    _salaryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateForm(dynamic engineer) {
    if (_isPopulated || engineer == null) return;
    _fullNameController.text = engineer.fullName;
    _phoneController.text = engineer.phone;
    _emailController.text = engineer.email ?? '';
    _designationController.text = engineer.designation ?? '';
    _experienceController.text = engineer.experienceYears?.toString() ?? '';
    _skillsController.text = engineer.skills.join(', ');
    _addressController.text = engineer.address ?? '';
    _salaryController.text = engineer.salary?.toString() ?? '';
    _notesController.text = engineer.privateNotes ?? '';
    _profilePhotoKey = engineer.profilePhotoUrl;
    if (engineer.district != null) {
      _selectedDistrictId = engineer.district!.id;
      _selectedDistrictName = engineer.district!.name;
    }
    _isPopulated = true;
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'pdf',
          'JPG',
          'JPEG',
          'PNG',
          'PDF'
        ],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) {
        throw Exception('Unable to read selected file');
      }

      setState(() {
        _isUploadingPhoto = true;
        _selectedFileName = file.name;
      });

      final fileName = file.name;
      final ext = (file.extension ??
              (fileName.contains('.') ? fileName.split('.').last : ''))
          .toLowerCase();

      String mimeType = 'image/jpeg';
      if (ext == 'png') {
        mimeType = 'image/png';
      } else if (ext == 'pdf') {
        mimeType = 'application/pdf';
      } else if (ext == 'jpg' || ext == 'jpeg') {
        mimeType = 'image/jpeg';
      } else {
        throw Exception(
            'Unsupported file format (.$ext). Please select a JPG, PNG, or PDF file.');
      }

      final key =
          await ref.read(engineerMutationsProvider.notifier).uploadFileToS3(
                fileName: fileName,
                mimeType: mimeType,
                bytes: bytes,
              );

      setState(() {
        _profilePhotoKey = key;
        _isUploadingPhoto = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File uploaded to S3 successfully'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (err) {
      setState(() => _isUploadingPhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $err'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  bool _validate() {
    bool isValid = true;
    setState(() {
      _fullNameError = null;
      _phoneError = null;
      _emailError = null;
      _districtError = null;

      final name = _fullNameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();

      if (name.length < 2) {
        _fullNameError = 'Full name is required (min 2 characters)';
        isValid = false;
      }

      final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
      if (!phoneRegex.hasMatch(phone)) {
        _phoneError = 'Valid phone number is required';
        isValid = false;
      }

      if (email.isNotEmpty) {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(email)) {
          _emailError = 'Please enter a valid email address';
          isValid = false;
        }
      }

      if (_selectedDistrictId == null || _selectedDistrictId!.isEmpty) {
        _districtError = 'Please select a district';
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> _onSubmit() async {
    if (_isLoading) return; // Prevent accidental duplicate submissions
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      final payload = <String, dynamic>{
        'fullName': _fullNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'districtId': _selectedDistrictId,
      };

      if (_emailController.text.trim().isNotEmpty) {
        payload['email'] = _emailController.text.trim();
      }
      if (_designationController.text.trim().isNotEmpty) {
        payload['designation'] = _designationController.text.trim();
      }
      if (_addressController.text.trim().isNotEmpty) {
        payload['address'] = _addressController.text.trim();
      }
      if (_skillsController.text.trim().isNotEmpty) {
        payload['skills'] = _skillsController.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      if (_experienceController.text.trim().isNotEmpty) {
        payload['experienceYears'] =
            double.tryParse(_experienceController.text.trim());
      }
      if (_salaryController.text.trim().isNotEmpty) {
        payload['salary'] = double.tryParse(_salaryController.text.trim());
      }
      if (_notesController.text.trim().isNotEmpty) {
        payload['privateNotes'] = _notesController.text.trim();
      }
      if (_profilePhotoKey != null && _profilePhotoKey!.isNotEmpty) {
        payload['profilePhotoUrl'] = _profilePhotoKey;
      }

      if (widget.isEdit) {
        await ref
            .read(engineerMutationsProvider.notifier)
            .updateEngineer(widget.engineerId!, payload);
      } else {
        await ref
            .read(engineerMutationsProvider.notifier)
            .createEngineer(payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEdit
                  ? 'Engineer updated successfully'
                  : 'Engineer created successfully',
            ),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
        context.pop();
      }
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $err'),
          backgroundColor: AppColors.darkDanger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openDistrictPicker(BuildContext context, String stateId) {
    final colors = AppColors.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final districtsAsync = ref.watch(districtsListProvider(stateId));

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, bottom: 12),
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select District',
                            style: AppTypography.title3(
                                color: colors.textPrimary)),
                        IconButton(
                          icon: Icon(LucideIcons.x,
                              size: 18, color: colors.textMuted),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: districtsAsync.when(
                      data: (districts) {
                        if (districts.isEmpty) {
                          return Center(
                            child: Text('No districts available',
                                style: AppTypography.subhead(
                                    color: colors.textSecondary)),
                          );
                        }
                        return ListView.separated(
                          itemCount: districts.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, idx) {
                            final d = districts[idx];
                            final isSelected = d.id == _selectedDistrictId;
                            return ListTile(
                              title: Text(
                                d.name,
                                style: AppTypography.body(
                                  color: isSelected
                                      ? colors.primaryAction
                                      : colors.textPrimary,
                                  weight: isSelected
                                      ? AppFontWeight.semibold
                                      : AppFontWeight.normal,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(LucideIcons.check,
                                      size: 18, color: colors.primaryAction)
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedDistrictId = d.id;
                                  _selectedDistrictName = d.name;
                                  _districtError = null;
                                });
                                Navigator.of(ctx).pop();
                              },
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(
                        child: Text('Error loading districts: $err',
                            style: AppTypography.caption(color: colors.danger)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // If edit, load existing engineer details
    if (widget.isEdit) {
      final engineerAsync =
          ref.watch(engineerDetailProvider(widget.engineerId!));
      engineerAsync.whenData((eng) => _populateForm(eng));
    }

    final dashboardAsync = ref.watch(managerDashboardProvider);
    final managerStateId = dashboardAsync.valueOrNull?.manager.state.id;

    return AppBackground(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Engineer' : 'New Engineer'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _onSubmit,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: AppTypography.body(
                      color: colors.primaryAction,
                      weight: AppFontWeight.semibold,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Basic & Contact Information
              StaggeredSlideFade(
                index: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FormSectionHeader(
                      title: 'Basic & Contact Information',
                      subtitle: 'Essential identity and contact credentials',
                    ),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      child: Column(
                        children: [
                          AppTextInput(
                            label: 'Full Name *',
                            placeholder: 'e.g. Rahul Sharma',
                            controller: _fullNameController,
                            error: _fullNameError,
                            prefixIcon: Icon(LucideIcons.user,
                                size: 16, color: colors.textMuted),
                          ),
                          AppTextInput(
                            label: 'Phone Number *',
                            placeholder: '+91 9876543210',
                            keyboardType: TextInputType.phone,
                            controller: _phoneController,
                            error: _phoneError,
                            prefixIcon: Icon(LucideIcons.phone,
                                size: 16, color: colors.textMuted),
                          ),
                          AppTextInput(
                            label: 'Email Address',
                            placeholder: 'rahul.sharma@example.com',
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            error: _emailError,
                            prefixIcon: Icon(LucideIcons.mail,
                                size: 16, color: colors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section 2: Professional Profile
              StaggeredSlideFade(
                index: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FormSectionHeader(
                      title: 'Professional Details',
                      subtitle: 'Role, experience level, and technical skills',
                    ),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      child: Column(
                        children: [
                          AppTextInput(
                            label: 'Designation / Title',
                            placeholder: 'e.g. Senior Hardware Engineer',
                            controller: _designationController,
                            prefixIcon: Icon(LucideIcons.briefcase,
                                size: 16, color: colors.textMuted),
                          ),
                          AppTextInput(
                            label: 'Experience (in years)',
                            placeholder: 'e.g. 4.5',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            controller: _experienceController,
                            prefixIcon: Icon(LucideIcons.calendar,
                                size: 16, color: colors.textMuted),
                          ),
                          AppTextInput(
                            label: 'Technical Skills (comma separated)',
                            placeholder:
                                'e.g. PCB Repair, Soldering, Diagnostics',
                            controller: _skillsController,
                            prefixIcon: Icon(LucideIcons.wrench,
                                size: 16, color: colors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section 3: Location & Assignment
              StaggeredSlideFade(
                index: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FormSectionHeader(
                      title: 'Location & Assignment',
                      subtitle: 'Jurisdiction and regional district assignment',
                    ),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assigned District *',
                            style: AppTypography.subhead(
                              color: colors.textSecondary,
                              weight: AppFontWeight.medium,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () {
                              if (managerStateId != null) {
                                _openDistrictPicker(context, managerStateId);
                              }
                            },
                            child: Container(
                              height: 48,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: colors.card,
                                borderRadius: AppRadius.inputRadius,
                                border: Border.all(
                                  color: _districtError != null
                                      ? colors.danger
                                      : colors.border,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(LucideIcons.mapPin,
                                          size: 16, color: colors.textMuted),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedDistrictName ??
                                            'Select assigned district',
                                        style: AppTypography.body(
                                          color: _selectedDistrictName != null
                                              ? colors.textPrimary
                                              : colors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(LucideIcons.chevronDown,
                                      size: 18, color: colors.textMuted),
                                ],
                              ),
                            ),
                          ),
                          if (_districtError != null) ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(LucideIcons.alertCircle,
                                    size: 13, color: colors.danger),
                                const SizedBox(width: 4),
                                Text(
                                  _districtError!,
                                  style: AppTypography.caption(
                                      color: colors.danger),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section 4: Identity Document & Photo Upload (AWS S3)
              StaggeredSlideFade(
                index: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FormSectionHeader(
                      title: 'Photo / Certification Document',
                      subtitle: 'Uploads securely to AWS S3 bucket',
                    ),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      child: _PhotoPickerSection(
                        profilePhotoKey: _profilePhotoKey,
                        fileName: _selectedFileName,
                        isUploading: _isUploadingPhoto,
                        onPickPhoto: _pickAndUploadPhoto,
                        onRemovePhoto: () {
                          setState(() {
                            _profilePhotoKey = null;
                            _selectedFileName = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Section 5: Confidential & Additional Details
              StaggeredSlideFade(
                index: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FormSectionHeader(
                      title: 'Internal & Confidential Records',
                      subtitle:
                          'Private data visible only to the managing supervisor',
                    ),
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      child: Column(
                        children: [
                          AppTextInput(
                            label: 'Full Address',
                            placeholder: 'Street, door no, city, pincode',
                            multiline: true,
                            maxLines: 2,
                            controller: _addressController,
                          ),
                          AppTextInput(
                            label: 'Monthly Compensation / Salary (₹)',
                            placeholder: 'e.g. 45000',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            controller: _salaryController,
                            prefixIcon: Icon(LucideIcons.indianRupee,
                                size: 16, color: colors.textMuted),
                          ),
                          AppTextInput(
                            label: 'Private Internal Notes',
                            placeholder:
                                'Private supervisor notes (never shared externally)',
                            multiline: true,
                            maxLines: 3,
                            controller: _notesController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit & Cancel Buttons
              StaggeredSlideFade(
                index: 5,
                child: Column(
                  children: [
                    AppButton(
                      label: widget.isEdit ? 'Save Changes' : 'Create Engineer',
                      onPress: _onSubmit,
                      loading: _isLoading,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Cancel',
                      onPress: () => context.pop(),
                      variant: AppButtonVariant.ghost,
                      disabled: _isLoading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    ));
  }
}

class _FormSectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _FormSectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.title3(color: colors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _PhotoPickerSection extends StatelessWidget {
  final String? profilePhotoKey;
  final String? fileName;
  final bool isUploading;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;

  const _PhotoPickerSection({
    required this.profilePhotoKey,
    required this.fileName,
    required this.isUploading,
    required this.onPickPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasPhoto = profilePhotoKey != null && profilePhotoKey!.isNotEmpty;
    final isPdf = (profilePhotoKey ?? '').toLowerCase().contains('.pdf') ||
        (fileName ?? '').toLowerCase().endsWith('.pdf');

    if (isUploading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: colors.secondarySurface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.primaryAction,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Uploading securely to S3 bucket...',
              style: AppTypography.body(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (hasPhoto) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colors.secondarySurface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.successBg,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(
                isPdf ? LucideIcons.fileText : LucideIcons.checkCircle2,
                color: colors.success,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPdf
                        ? 'PDF Document attached'
                        : 'Photo attached & verified',
                    style: AppTypography.body(
                      color: colors.textPrimary,
                      weight: AppFontWeight.semibold,
                    ),
                  ),
                  Text(
                    fileName ?? 'Saved in AWS S3',
                    style: AppTypography.caption(color: colors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(LucideIcons.trash2, color: colors.danger, size: 18),
              onPressed: onRemovePhoto,
              tooltip: 'Remove',
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: onPickPhoto,
      borderRadius: AppRadius.cardRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: colors.secondarySurface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.uploadCloud,
                color: colors.primaryAction, size: 22),
            const SizedBox(width: 12),
            Text(
              'Select JPG / PNG photo or PDF document',
              style: AppTypography.body(
                color: colors.primaryAction,
                weight: AppFontWeight.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
