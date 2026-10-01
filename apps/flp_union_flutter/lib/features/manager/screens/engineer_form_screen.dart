import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/district_entity.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_input.dart';
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
  bool _districtPickerOpen = false;

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
    if (engineer.district != null) {
      _selectedDistrictId = engineer.district!.id;
      _selectedDistrictName = engineer.district!.name;
    }
    _isPopulated = true;
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
        _fullNameError = 'Name required';
        isValid = false;
      }

      final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
      if (!phoneRegex.hasMatch(phone)) {
        _phoneError = 'Valid phone required';
        isValid = false;
      }

      if (email.isNotEmpty) {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(email)) {
          _emailError = 'Valid email required';
          isValid = false;
        }
      }

      if (_selectedDistrictId == null || _selectedDistrictId!.isEmpty) {
        _districtError = 'Select district';
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> _onSubmit() async {
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
        payload['experienceYears'] = double.tryParse(_experienceController.text.trim());
      }
      if (_salaryController.text.trim().isNotEmpty) {
        payload['salary'] = double.tryParse(_salaryController.text.trim());
      }
      if (_notesController.text.trim().isNotEmpty) {
        payload['privateNotes'] = _notesController.text.trim();
      }

      if (widget.isEdit) {
        await ref.read(engineerMutationsProvider.notifier).updateEngineer(widget.engineerId!, payload);
      } else {
        await ref.read(engineerMutationsProvider.notifier).createEngineer(payload);
      }

      if (mounted) {
        context.pop();
      }
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If edit, load existing engineer details
    if (widget.isEdit) {
      final engineerAsync = ref.watch(engineerDetailProvider(widget.engineerId!));
      engineerAsync.whenData((eng) => _populateForm(eng));
    }

    final dashboardAsync = ref.watch(managerDashboardProvider);
    final managerStateId = dashboardAsync.valueOrNull?.manager.state.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(widget.isEdit ? 'Edit Engineer' : 'Add Engineer'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextInput(
                label: 'Full Name *',
                placeholder: 'Engineer full name',
                controller: _fullNameController,
                error: _fullNameError,
              ),

              AppTextInput(
                label: 'Phone *',
                placeholder: '+91 9999999999',
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                error: _phoneError,
              ),

              AppTextInput(
                label: 'Email',
                placeholder: 'email@example.com',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
                error: _emailError,
              ),

              AppTextInput(
                label: 'Designation',
                placeholder: 'e.g. Senior Engineer',
                controller: _designationController,
              ),

              AppTextInput(
                label: 'Experience (years)',
                placeholder: 'e.g. 5.5',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _experienceController,
              ),

              AppTextInput(
                label: 'Skills (comma-separated)',
                placeholder: 'e.g. React, Node.js, SQL',
                controller: _skillsController,
              ),

              // District Picker Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'District *',
                    style: TextStyle(
                      fontSize: AppFontSize.sm,
                      fontWeight: AppFontWeight.medium,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _districtPickerOpen = !_districtPickerOpen),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: AppRadius.borderMd,
                        border: Border.all(
                          color: _districtError != null ? AppColors.danger : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDistrictName ?? 'Select District',
                            style: TextStyle(
                              color: _selectedDistrictName != null
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontSize: AppFontSize.md,
                            ),
                          ),
                          const Icon(LucideIcons.chevronDown, size: 18, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  if (_districtError != null) ...[
                    const SizedBox(height: 4),
                    Text(_districtError!, style: const TextStyle(fontSize: 11, color: AppColors.danger)),
                  ],
                  if (_districtPickerOpen && managerStateId != null)
                    _DistrictDropdownOptions(
                      stateId: managerStateId,
                      onSelected: (d) {
                        setState(() {
                          _selectedDistrictId = d.id;
                          _selectedDistrictName = d.name;
                          _districtPickerOpen = false;
                        });
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),

              AppTextInput(
                label: 'Address',
                placeholder: 'Full address',
                multiline: true,
                maxLines: 2,
                controller: _addressController,
              ),

              AppTextInput(
                label: 'Salary (Rs.)',
                placeholder: 'e.g. 50000',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _salaryController,
              ),

              AppTextInput(
                label: 'Private Notes',
                placeholder: 'Internal notes (not visible to others)',
                multiline: true,
                maxLines: 3,
                controller: _notesController,
              ),

              const SizedBox(height: AppSpacing.md),

              AppButton(
                label: widget.isEdit ? 'Save Changes' : 'Add Engineer',
                onPress: _onSubmit,
                loading: _isLoading,
              ),

              const SizedBox(height: AppSpacing.sm),

              AppButton(
                label: 'Cancel',
                onPress: () => context.pop(),
                variant: AppButtonVariant.ghost,
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _DistrictDropdownOptions extends ConsumerWidget {
  final String stateId;
  final ValueChanged<DistrictEntity> onSelected;

  const _DistrictDropdownOptions({
    required this.stateId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final districtsAsync = ref.watch(districtsListProvider(stateId));

    return districtsAsync.when(
      data: (districts) => Container(
        margin: const EdgeInsets.only(top: 4),
        constraints: const BoxConstraints(maxHeight: 200),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: ListView(
          shrinkWrap: true,
          children: districts.map((d) => ListTile(
            title: Text(d.name, style: const TextStyle(color: AppColors.textPrimary)),
            onTap: () => onSelected(d),
          )).toList(),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
