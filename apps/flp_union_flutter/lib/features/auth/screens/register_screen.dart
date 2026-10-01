import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/models/district_entity.dart';
import '../../../shared/models/state_entity.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_input.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedStateId;
  String? _selectedStateName;
  String? _selectedDistrictId;
  String? _selectedDistrictName;

  bool _statePickerOpen = false;
  bool _districtPickerOpen = false;

  String? _fullNameError;
  String? _mobileError;
  String? _emailError;
  String? _stateError;
  String? _districtError;
  String? _passwordError;
  String? _confirmPasswordError;

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    setState(() {
      _fullNameError = null;
      _mobileError = null;
      _emailError = null;
      _stateError = null;
      _districtError = null;
      _passwordError = null;
      _confirmPasswordError = null;

      final name = _fullNameController.text.trim();
      final mobile = _mobileController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (name.length < 2) {
        _fullNameError = 'Full name required';
        isValid = false;
      }

      final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
      if (!phoneRegex.hasMatch(mobile)) {
        _mobileError = 'Enter a valid phone number';
        isValid = false;
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _emailError = 'Enter a valid email';
        isValid = false;
      }

      if (_selectedStateId == null || _selectedStateId!.isEmpty) {
        _stateError = 'Select a state';
        isValid = false;
      }

      if (_selectedDistrictId == null || _selectedDistrictId!.isEmpty) {
        _districtError = 'Select a district';
        isValid = false;
      }

      final passwordPattern = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)');
      if (password.length < 8 || !passwordPattern.hasMatch(password)) {
        _passwordError = 'Must contain a letter and number (min 8 chars)';
        isValid = false;
      }

      if (password != confirmPassword) {
        _confirmPasswordError = 'Passwords do not match';
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> _onSubmit() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).registerManager(
            fullName: _fullNameController.text.trim(),
            mobile: _mobileController.text.trim(),
            email: _emailController.text.trim(),
            stateId: _selectedStateId!,
            districtId: _selectedDistrictId!,
            password: _passwordController.text,
          );

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Success', style: TextStyle(color: AppColors.textPrimary)),
          content: const Text('Account created! Please log in.', style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/login');
              },
              child: const Text('OK', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString().replaceAll('ApiException: ', '')),
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
    final statesAsync = ref.watch(statesListProvider);
    final districtsAsync = _selectedStateId != null
        ? ref.watch(districtsListProvider(_selectedStateId!))
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xl),
                child: Column(
                  children: const [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: AppFontSize.xxxl,
                        fontWeight: AppFontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Join TASPU as a Manager',
                      style: TextStyle(
                        fontSize: AppFontSize.md,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Container Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppRadius.borderXl,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextInput(
                      label: 'Full Name',
                      placeholder: 'Your full name',
                      controller: _fullNameController,
                      error: _fullNameError,
                    ),

                    AppTextInput(
                      label: 'Mobile Number',
                      placeholder: '+91 9999999999',
                      keyboardType: TextInputType.phone,
                      controller: _mobileController,
                      error: _mobileError,
                    ),

                    AppTextInput(
                      label: 'Email Address',
                      placeholder: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      error: _emailError,
                    ),

                    // State Picker Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'State',
                          style: TextStyle(
                            fontSize: AppFontSize.sm,
                            fontWeight: AppFontWeight.medium,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => setState(() => _statePickerOpen = !_statePickerOpen),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.borderMd,
                              border: Border.all(color: AppColors.border, width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    statesAsync.when(
                                      data: (_) => _selectedStateName ?? 'Select State',
                                      loading: () => 'Loading states...',
                                      error: (_, __) => 'Failed to load',
                                    ),
                                    style: TextStyle(
                                      color: _selectedStateName != null
                                          ? AppColors.textPrimary
                                          : AppColors.textMuted,
                                      fontSize: AppFontSize.md,
                                    ),
                                  ),
                                ),
                                const Icon(LucideIcons.chevronDown, size: 18, color: AppColors.textMuted),
                              ],
                            ),
                          ),
                        ),
                        if (_stateError != null) ...[
                          const SizedBox(height: 4),
                          Text(_stateError!, style: const TextStyle(fontSize: 11, color: AppColors.danger)),
                        ],
                        if (_statePickerOpen)
                          statesAsync.when(
                            data: (states) => Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: Column(
                                children: states.map((s) => ListTile(
                                  title: Text(s.name, style: const TextStyle(color: AppColors.textPrimary)),
                                  onTap: () {
                                    setState(() {
                                      _selectedStateId = s.id;
                                      _selectedStateName = s.name;
                                      _selectedDistrictId = null;
                                      _selectedDistrictName = null;
                                      _statePickerOpen = false;
                                    });
                                  },
                                )).toList(),
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),

                    // District Picker Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'District',
                          style: TextStyle(
                            fontSize: AppFontSize.sm,
                            fontWeight: AppFontWeight.medium,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            if (_selectedStateId != null) {
                              setState(() => _districtPickerOpen = !_districtPickerOpen);
                            }
                          },
                          child: Opacity(
                            opacity: _selectedStateId != null ? 1.0 : 0.5,
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedStateId == null
                                          ? 'Select State first'
                                          : (districtsAsync?.when(
                                                data: (_) => _selectedDistrictName ?? 'Select District',
                                                loading: () => 'Loading districts...',
                                                error: (_, __) => 'Failed to load',
                                              ) ??
                                              'Select District'),
                                      style: TextStyle(
                                        color: _selectedDistrictName != null
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
                                        fontSize: AppFontSize.md,
                                      ),
                                    ),
                                  ),
                                  const Icon(LucideIcons.chevronDown, size: 18, color: AppColors.textMuted),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_districtError != null) ...[
                          const SizedBox(height: 4),
                          Text(_districtError!, style: const TextStyle(fontSize: 11, color: AppColors.danger)),
                        ],
                        if (_districtPickerOpen && districtsAsync != null)
                          districtsAsync.when(
                            data: (districts) => Container(
                              margin: const EdgeInsets.only(top: 4),
                              maxHeight: 200,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: AppRadius.borderMd,
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: ListView(
                                shrinkWrap: true,
                                children: districts.map((d) => ListTile(
                                  title: Text(d.name, style: const TextStyle(color: AppColors.textPrimary)),
                                  onTap: () {
                                    setState(() {
                                      _selectedDistrictId = d.id;
                                      _selectedDistrictName = d.name;
                                      _districtPickerOpen = false;
                                    });
                                  },
                                )).toList(),
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        const SizedBox(height: 16),
                      ],
                    ),

                    AppTextInput(
                      label: 'Password',
                      placeholder: 'Min 8 chars, letter + number',
                      isPassword: true,
                      controller: _passwordController,
                      error: _passwordError,
                    ),

                    AppTextInput(
                      label: 'Confirm Password',
                      placeholder: 'Repeat your password',
                      isPassword: true,
                      controller: _confirmPasswordController,
                      error: _confirmPasswordError,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    AppButton(
                      label: 'Create Account',
                      onPress: _onSubmit,
                      loading: _isLoading,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: AppFontSize.sm,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Sign in',
                            style: TextStyle(
                              fontSize: AppFontSize.sm,
                              color: AppColors.accent,
                              fontWeight: AppFontWeight.semibold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
