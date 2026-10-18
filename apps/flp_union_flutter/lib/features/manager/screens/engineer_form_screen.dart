import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/predefined_options.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_multi_select.dart';
import '../../../shared/widgets/app_text_input.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/engineer_provider.dart';
import '../providers/manager_dashboard_provider.dart';
import '../providers/manager_profile_provider.dart';

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
  final _addressController = TextEditingController();
  final _salaryController = TextEditingController();
  final _notesController = TextEditingController();

  List<String> _selectedSkills = [];

  String? _selectedDistrictId;
  String? _selectedDistrictName;

  // Profile Photo state
  String? _profilePhotoKey;
  Uint8List? _profilePhotoBytes;
  bool _isUploadingProfilePhoto = false;

  // Aadhaar Document state
  String? _aadhaarKey;
  String? _aadhaarFileName;
  int? _aadhaarFileSizeBytes;
  bool _isUploadingAadhaar = false;
  String? _aadhaarError;

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
    _selectedSkills = List<String>.from(engineer.skills);
    _addressController.text = engineer.address ?? '';
    _salaryController.text = engineer.salary?.toString() ?? '';
    _notesController.text = engineer.privateNotes ?? '';
    _profilePhotoKey = engineer.profilePhotoUrl;
    _aadhaarKey = engineer.aadhaarCardUrl;
    if (engineer.district != null) {
      _selectedDistrictId = engineer.district!.id;
      _selectedDistrictName = engineer.district!.name;
    }
    _isPopulated = true;
  }

  Future<void> _pickAndUploadProfilePhoto() async {
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
            'Profile photo exceeds 5MB limit. Please select a smaller image.');
      }

      setState(() {
        _isUploadingProfilePhoto = true;
        _profilePhotoBytes = bytes;
      });

      final ext = (file.extension ??
              (file.name.contains('.') ? file.name.split('.').last : ''))
          .toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      final key =
          await ref.read(engineerMutationsProvider.notifier).uploadFileToS3(
                fileName: file.name,
                mimeType: mimeType,
                bytes: bytes,
              );

      setState(() {
        _profilePhotoKey = key;
        _isUploadingProfilePhoto = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo uploaded successfully'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (err) {
      setState(() => _isUploadingProfilePhoto = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile photo upload failed: $err'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadAadhaar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'jpg',
          'jpeg',
          'png',
          'PDF',
          'JPG',
          'JPEG',
          'PNG'
        ],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null && file.path!.isNotEmpty) {
        bytes = await XFile(file.path!).readAsBytes();
      }
      if (bytes == null) {
        throw Exception('Unable to read document file');
      }
      if (bytes.length > 10 * 1024 * 1024) {
        throw Exception(
            'Document exceeds 10MB limit. Please select a smaller file.');
      }

      setState(() {
        _isUploadingAadhaar = true;
        _aadhaarFileName = file.name;
        _aadhaarFileSizeBytes = bytes!.length;
        _aadhaarError = null;
      });

      final ext = (file.extension ??
              (file.name.contains('.') ? file.name.split('.').last : ''))
          .toLowerCase();
      String mimeType = 'application/pdf';
      if (ext == 'png') {
        mimeType = 'image/png';
      } else if (ext == 'jpg' || ext == 'jpeg') {
        mimeType = 'image/jpeg';
      }

      final key =
          await ref.read(engineerMutationsProvider.notifier).uploadFileToS3(
                fileName: file.name,
                mimeType: mimeType,
                bytes: bytes,
              );

      setState(() {
        _aadhaarKey = key;
        _isUploadingAadhaar = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aadhaar document uploaded securely to S3'),
            backgroundColor: AppColors.darkSuccess,
          ),
        );
      }
    } catch (err) {
      setState(() {
        _isUploadingAadhaar = false;
        _aadhaarError = err.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aadhaar upload failed: $err'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    }
  }

  bool _validate() {
    bool isValid = true;

    final name = _fullNameController.text.trim();
    if (name.isEmpty) {
      _fullNameError = 'Full name is required';
      isValid = false;
    } else {
      _fullNameError = null;
    }

    final phone = _phoneController.text.trim();
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (phone.isEmpty) {
      _phoneError = 'Phone number is required';
      isValid = false;
    } else if (!phoneRegex.hasMatch(phone)) {
      _phoneError = 'Enter a valid phone number (7-15 digits)';
      isValid = false;
    } else {
      _phoneError = null;
    }

    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _emailError = 'Enter a valid email address';
        isValid = false;
      } else {
        _emailError = null;
      }
    } else {
      _emailError = null;
    }

    if (_selectedDistrictId == null || _selectedDistrictId!.isEmpty) {
      _districtError = 'Assigned district is required';
      isValid = false;
    } else {
      _districtError = null;
    }

    setState(() {});
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
        'skills': _selectedSkills,
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
      } else if (widget.isEdit) {
        payload['profilePhotoUrl'] = null;
      }
      if (_aadhaarKey != null && _aadhaarKey!.isNotEmpty) {
        payload['aadhaarCardUrl'] = _aadhaarKey;
      } else if (widget.isEdit) {
        payload['aadhaarCardUrl'] = null;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save engineer: $err'),
            backgroundColor: AppColors.darkDanger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openDistrictPicker(List<dynamic> districts) {
    final colors = AppColors.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.sheet),
            ),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Assigned District',
                        style: AppTypography.title2(color: colors.textPrimary),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.x,
                            size: 18, color: colors.textMuted),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding, vertical: 8),
                    itemCount: districts.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = districts[index];
                      final isSelected = item.id == _selectedDistrictId;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDistrictId = item.id;
                            _selectedDistrictName = item.name;
                            _districtError = null;
                          });
                          Navigator.of(context).pop();
                        },
                        borderRadius: AppRadius.cardRadius,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.name,
                                style: AppTypography.body(
                                  color: isSelected
                                      ? colors.primaryAction
                                      : colors.textPrimary,
                                  weight: isSelected
                                      ? AppFontWeight.semibold
                                      : AppFontWeight.regular,
                                ),
                              ),
                              if (isSelected)
                                Icon(LucideIcons.check,
                                    size: 18, color: colors.primaryAction),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final profileAsync = ref.watch(managerProfileProvider);
    final dashboardAsync = ref.watch(managerDashboardProvider);
    final managerStateId = dashboardAsync.valueOrNull?.manager.state.id ??
        profileAsync.valueOrNull?.state.id;
    final districtsAsync = (managerStateId != null && managerStateId.isNotEmpty)
        ? ref.watch(districtsListProvider(managerStateId))
        : null;
    final districts = districtsAsync?.valueOrNull ?? [];

    if (widget.isEdit) {
      final engineerAsync =
          ref.watch(engineerDetailProvider(widget.engineerId!));
      engineerAsync.whenData((eng) => _populateForm(eng));
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Edit Engineer' : 'Add Engineer'),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14.0),
              child: TextButton(
                onPressed: _isLoading ? null : _onSubmit,
                style: TextButton.styleFrom(
                  foregroundColor: colors.primaryAction,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.primaryAction,
                        ),
                      )
                    : Text(
                        'Save',
                        style: AppTypography.body(
                          color: colors.primaryAction,
                          weight: AppFontWeight.semibold,
                        ),
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
                // Section 1: Basic Identity
                StaggeredSlideFade(
                  index: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FormSectionHeader(
                        title: 'Basic Identity',
                        subtitle: 'Primary contact information and name',
                      ),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        child: Column(
                          children: [
                            AppTextInput(
                              label: 'Full Name *',
                              placeholder: 'e.g. Ramesh Kumar',
                              controller: _fullNameController,
                              error: _fullNameError,
                              prefixIcon: Icon(LucideIcons.user,
                                  size: 16, color: colors.textMuted),
                            ),
                            AppTextInput(
                              label: 'Phone Number *',
                              placeholder: 'e.g. +91 9876543210',
                              keyboardType: TextInputType.phone,
                              controller: _phoneController,
                              error: _phoneError,
                              prefixIcon: Icon(LucideIcons.phone,
                                  size: 16, color: colors.textMuted),
                            ),
                            AppTextInput(
                              label: 'Email Address',
                              placeholder: 'e.g. ramesh@example.com',
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

                // Section 2: Professional Details
                StaggeredSlideFade(
                  index: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FormSectionHeader(
                        title: 'Professional Details',
                        subtitle:
                            'Role, experience level, and technical skills',
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              controller: _experienceController,
                              prefixIcon: Icon(LucideIcons.calendar,
                                  size: 16, color: colors.textMuted),
                            ),
                            AppMultiSelect(
                              label: 'Technical Skills',
                              placeholder: 'Select technical skills...',
                              options: PredefinedOptions.technicalSkills,
                              selectedValues: _selectedSkills,
                              onChanged: (skills) =>
                                  setState(() => _selectedSkills = skills),
                              prefixIcon: Icon(LucideIcons.wrench,
                                  size: 16, color: colors.textMuted),
                              dialogTitle: 'Select Technical Skills',
                              allowCustom: true,
                              customOptionLabel: 'Custom Skill',
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
                        subtitle:
                            'Jurisdiction and regional district assignment',
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
                            InkWell(
                              onTap: () {
                                if (districts.isNotEmpty) {
                                  _openDistrictPicker(districts);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Loading proprietor territory data. Please try again in a moment.'),
                                    ),
                                  );
                                }
                              },
                              borderRadius: AppRadius.inputRadius,
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
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(LucideIcons.mapPin,
                                              size: 16,
                                              color: colors.textMuted),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _selectedDistrictName ??
                                                  'Select assigned district',
                                              style: AppTypography.body(
                                                color: _selectedDistrictName !=
                                                        null
                                                    ? colors.textPrimary
                                                    : colors.textMuted,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
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
                                  Expanded(
                                    child: Text(
                                      _districtError!,
                                      style: AppTypography.caption(
                                          color: colors.danger),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 14),
                            profileAsync.when(
                              data: (p) => Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.secondarySurface,
                                  borderRadius: AppRadius.inputRadius,
                                ),
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.info,
                                        size: 15, color: colors.info),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Engineers are restricted to your assigned territory: ${p.state.name}',
                                        style: AppTypography.caption(
                                            color: colors.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 14),
                            AppTextInput(
                              label: 'Residential / Base Address',
                              placeholder:
                                  'Street address, landmark, pin code...',
                              multiline: true,
                              maxLines: 2,
                              controller: _addressController,
                              prefixIcon: Icon(LucideIcons.home,
                                  size: 16, color: colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Section 4: Profile Photo and Aadhaar Uploads
                StaggeredSlideFade(
                  index: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FormSectionHeader(
                        title: 'Profile Photo & Identity Document',
                        subtitle:
                            'Upload profile picture and confidential Aadhaar document',
                      ),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // A. Profile Photo Control
                            _ProfilePhotoControl(
                              profilePhotoKey: _profilePhotoKey,
                              localBytes: _profilePhotoBytes,
                              isUploading: _isUploadingProfilePhoto,
                              onPickPhoto: _pickAndUploadProfilePhoto,
                              onRemovePhoto: () {
                                setState(() {
                                  _profilePhotoKey = null;
                                  _profilePhotoBytes = null;
                                });
                              },
                              fullName: _fullNameController.text.trim(),
                            ),
                            const Divider(height: 28),

                            // B. Aadhaar Card Document Control
                            _AadhaarDocumentControl(
                              aadhaarKey: _aadhaarKey,
                              fileName: _aadhaarFileName,
                              fileSizeBytes: _aadhaarFileSizeBytes,
                              isUploading: _isUploadingAadhaar,
                              error: _aadhaarError,
                              onPickDocument: _pickAndUploadAadhaar,
                              onRemoveDocument: () {
                                setState(() {
                                  _aadhaarKey = null;
                                  _aadhaarFileName = null;
                                  _aadhaarFileSizeBytes = null;
                                  _aadhaarError = null;
                                });
                              },
                            ),
                          ],
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
                        title: 'Confidential Information',
                        subtitle:
                            'Strictly visible to you only (proprietor privileged)',
                      ),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.cardPadding),
                        child: Column(
                          children: [
                            AppTextInput(
                              label: 'Monthly Compensation / Salary (₹)',
                              placeholder: 'e.g. 25000',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              controller: _salaryController,
                              prefixIcon: Icon(LucideIcons.indianRupee,
                                  size: 16, color: colors.textMuted),
                            ),
                            AppTextInput(
                              label: 'Private Administrative Notes',
                              placeholder:
                                  'Performance observations, tools issued, shift schedules...',
                              multiline: true,
                              maxLines: 3,
                              controller: _notesController,
                              prefixIcon: Icon(LucideIcons.fileText,
                                  size: 16, color: colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit Action Button
                AppButton(
                  label: widget.isEdit
                      ? 'Save Engineer Profile'
                      : 'Create Engineer Record',
                  icon: const Icon(LucideIcons.check, size: 18),
                  loading: _isLoading,
                  fullWidth: true,
                  onPress: _onSubmit,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
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

class _ProfilePhotoControl extends ConsumerWidget {
  final String? profilePhotoKey;
  final Uint8List? localBytes;
  final bool isUploading;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemovePhoto;
  final String fullName;

  const _ProfilePhotoControl({
    required this.profilePhotoKey,
    required this.localBytes,
    required this.isUploading,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final hasPhoto = (profilePhotoKey != null && profilePhotoKey!.isNotEmpty) ||
        localBytes != null;

    final photoUrlAsync = (profilePhotoKey != null &&
            profilePhotoKey!.isNotEmpty &&
            localBytes == null)
        ? ref.watch(engineerDocumentUrlProvider(profilePhotoKey!))
        : const AsyncValue<String>.data('');
    final remotePhotoUrl = photoUrlAsync.valueOrNull;

    Widget avatarWidget;
    if (isUploading) {
      avatarWidget = Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.primaryAction,
          ),
        ),
      );
    } else if (localBytes != null) {
      avatarWidget = Image.memory(
        localBytes!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
      );
    } else if (remotePhotoUrl != null && remotePhotoUrl.isNotEmpty) {
      avatarWidget = Image.network(
        remotePhotoUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(LucideIcons.camera, size: 24, color: colors.textMuted),
        ),
      );
    } else {
      avatarWidget = Center(
        child: Icon(LucideIcons.camera, size: 24, color: colors.textMuted),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.image, size: 16, color: colors.primaryAction),
            const SizedBox(width: 8),
            Text(
              'Engineer Profile Photo',
              style: AppTypography.body(
                color: colors.textPrimary,
                weight: AppFontWeight.semibold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Personal portrait shown on avatar badges (JPG or PNG, max 5MB)',
          style: AppTypography.caption(color: colors.textMuted),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.secondarySurface,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border, width: 1.5),
              ),
              child: ClipOval(child: avatarWidget),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: isUploading ? null : onPickPhoto,
                    icon: Icon(
                      hasPhoto ? LucideIcons.refreshCw : LucideIcons.upload,
                      size: 14,
                      color: colors.primaryAction,
                    ),
                    label: Text(
                      hasPhoto ? 'Replace Photo' : 'Upload Photo',
                      style: AppTypography.caption(
                        color: colors.primaryAction,
                        weight: AppFontWeight.medium,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primaryAction,
                      side: BorderSide(color: colors.border),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.buttonRadius,
                      ),
                    ),
                  ),
                  if (hasPhoto && !isUploading)
                    TextButton.icon(
                      onPressed: onRemovePhoto,
                      icon: Icon(LucideIcons.trash2,
                          size: 14, color: colors.danger),
                      label: Text(
                        'Remove',
                        style: AppTypography.caption(
                          color: colors.danger,
                          weight: AppFontWeight.medium,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.danger,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AadhaarDocumentControl extends StatelessWidget {
  final String? aadhaarKey;
  final String? fileName;
  final int? fileSizeBytes;
  final bool isUploading;
  final String? error;
  final VoidCallback onPickDocument;
  final VoidCallback onRemoveDocument;

  const _AadhaarDocumentControl({
    required this.aadhaarKey,
    required this.fileName,
    required this.fileSizeBytes,
    required this.isUploading,
    required this.error,
    required this.onPickDocument,
    required this.onRemoveDocument,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasDocument = aadhaarKey != null && aadhaarKey!.isNotEmpty;
    final isPdf = (aadhaarKey ?? '').toLowerCase().contains('.pdf') ||
        (fileName ?? '').toLowerCase().endsWith('.pdf');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.fileText, size: 16, color: colors.primaryAction),
            const SizedBox(width: 8),
            Text(
              'Aadhaar Card Document',
              style: AppTypography.body(
                color: colors.textPrimary,
                weight: AppFontWeight.semibold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Confidential ID verification document (PDF, JPG, or PNG, max 10MB)',
          style: AppTypography.caption(color: colors.textMuted),
        ),
        const SizedBox(height: 12),
        if (isUploading)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                Expanded(
                  child: Text(
                    'Uploading Aadhaar document securely to S3...',
                    style: AppTypography.body(color: colors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )
        else if (hasDocument)
          Container(
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
                        isPdf ? 'Aadhaar Card (PDF)' : 'Aadhaar Card (Image)',
                        style: AppTypography.body(
                          color: colors.textPrimary,
                          weight: AppFontWeight.semibold,
                        ),
                      ),
                      Text(
                        fileName ?? 'Stored in secure private storage',
                        style: AppTypography.caption(color: colors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.refreshCw,
                      color: colors.textSecondary, size: 16),
                  onPressed: onPickDocument,
                  tooltip: 'Replace Document',
                ),
                IconButton(
                  icon:
                      Icon(LucideIcons.trash2, color: colors.danger, size: 16),
                  onPressed: onRemoveDocument,
                  tooltip: 'Remove',
                ),
              ],
            ),
          )
        else
          InkWell(
            onTap: onPickDocument,
            borderRadius: AppRadius.cardRadius,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: colors.secondarySurface,
                borderRadius: AppRadius.cardRadius,
                border: Border.all(color: colors.border, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.uploadCloud,
                      color: colors.primaryAction, size: 20),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Upload Aadhaar Card (PDF / Image)',
                      style: AppTypography.body(
                        color: colors.primaryAction,
                        weight: AppFontWeight.medium,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (error != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(LucideIcons.alertCircle, size: 13, color: colors.danger),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  error!,
                  style: AppTypography.caption(color: colors.danger),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
