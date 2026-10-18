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
import '../../../shared/widgets/app_logo.dart';
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
        _fullNameError = 'Full name is required';
        isValid = false;
      }

      final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
      if (!phoneRegex.hasMatch(mobile)) {
        _mobileError = 'Enter a valid phone number';
        isValid = false;
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _emailError = 'Enter a valid email address';
        isValid = false;
      }

      if (_selectedStateId == null || _selectedStateId!.isEmpty) {
        _stateError = 'Please select a state';
        isValid = false;
      }

      if (_selectedDistrictId == null || _selectedDistrictId!.isEmpty) {
        _districtError = 'Please select a district';
        isValid = false;
      }

      final passwordPattern = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)');
      if (password.length < 8 || !passwordPattern.hasMatch(password)) {
        _passwordError = 'Must contain at least 8 chars with letters & numbers';
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
    if (_isLoading) return;
    if (!_validate()) return;

    setState(() => _isLoading = true);
    final colors = AppColors.of(context);

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
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sheet),
            side: BorderSide(color: colors.border, width: 1),
          ),
          title: Row(
            children: [
              Icon(LucideIcons.checkCircle, color: colors.success, size: 22),
              const SizedBox(width: 8),
              Text('Account Created',
                  style: AppTypography.title2(color: colors.textPrimary)),
            ],
          ),
          content: Text(
            'Your proprietor account has been registered successfully. Please sign in.',
            style: AppTypography.body(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/login');
              },
              child: Text(
                'Sign In Now',
                style: AppTypography.body(
                    color: colors.primaryAction,
                    weight: AppFontWeight.semibold),
              ),
            ),
          ],
        ),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.toString().replaceAll('ApiException: ', '')),
          backgroundColor: AppColors.darkDanger,
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
    final colors = AppColors.of(context);
    final statesAsync = ref.watch(statesListProvider);
    final districtsAsync = _selectedStateId != null
        ? ref.watch(districtsListProvider(_selectedStateId!))
        : null;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    // Header with Staggered Entrance
                    StaggeredSlideFade(
                      index: 0,
                      child: Column(
                        children: [
                          const AppLogo(
                            size: 72,
                            heroTag: 'app_logo',
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Create Proprietor Account',
                            style:
                                AppTypography.title1(color: colors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Join TAPSU workforce network',
                            style: AppTypography.subhead(
                                color: colors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Form Container Card with Staggered Entrance
                    StaggeredSlideFade(
                      index: 1,
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppTextInput(
                              label: 'Full Name *',
                              placeholder: 'e.g. Ramesh Reddy',
                              controller: _fullNameController,
                              error: _fullNameError,
                              prefixIcon: Icon(LucideIcons.user,
                                  size: 16, color: colors.textMuted),
                            ),

                            AppTextInput(
                              label: 'Mobile Number *',
                              placeholder: '+91 9999999999',
                              keyboardType: TextInputType.phone,
                              controller: _mobileController,
                              error: _mobileError,
                              prefixIcon: Icon(LucideIcons.phone,
                                  size: 16, color: colors.textMuted),
                            ),

                            AppTextInput(
                              label: 'Email Address *',
                              placeholder: 'ramesh@example.com',
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              error: _emailError,
                              prefixIcon: Icon(LucideIcons.mail,
                                  size: 16, color: colors.textMuted),
                            ),

                            // State Picker Dropdown
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'State *',
                                  style: AppTypography.subhead(
                                    color: colors.textSecondary,
                                    weight: AppFontWeight.medium,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () => setState(() =>
                                      _statePickerOpen = !_statePickerOpen),
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: colors.card,
                                      borderRadius: AppRadius.inputRadius,
                                      border: Border.all(
                                        color: _stateError != null
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
                                            Icon(LucideIcons.building2,
                                                size: 16,
                                                color: colors.textMuted),
                                            const SizedBox(width: 8),
                                            Text(
                                              statesAsync.when(
                                                data: (_) =>
                                                    _selectedStateName ??
                                                    'Select State',
                                                loading: () =>
                                                    'Loading states...',
                                                error: (_, __) =>
                                                    'Failed to load',
                                              ),
                                              style: AppTypography.body(
                                                color:
                                                    _selectedStateName != null
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
                                if (_stateError != null) ...[
                                  const SizedBox(height: 5),
                                  Text(_stateError!,
                                      style: AppTypography.caption(
                                          color: colors.danger)),
                                ],
                                if (_statePickerOpen)
                                  statesAsync.when(
                                    data: (states) => Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      constraints:
                                          const BoxConstraints(maxHeight: 200),
                                      decoration: BoxDecoration(
                                        color: colors.secondarySurface,
                                        borderRadius: AppRadius.cardRadius,
                                        border: Border.all(
                                            color: colors.border, width: 1),
                                      ),
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: states
                                            .map((s) => ListTile(
                                                  title: Text(s.name,
                                                      style: AppTypography.body(
                                                          color: colors
                                                              .textPrimary)),
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedStateId = s.id;
                                                      _selectedStateName =
                                                          s.name;
                                                      _selectedDistrictId =
                                                          null;
                                                      _selectedDistrictName =
                                                          null;
                                                      _statePickerOpen = false;
                                                    });
                                                  },
                                                ))
                                            .toList(),
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
                                Text(
                                  'District *',
                                  style: AppTypography.subhead(
                                    color: colors.textSecondary,
                                    weight: AppFontWeight.medium,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () {
                                    if (_selectedStateId != null) {
                                      setState(() => _districtPickerOpen =
                                          !_districtPickerOpen);
                                    }
                                  },
                                  child: Opacity(
                                    opacity:
                                        _selectedStateId != null ? 1.0 : 0.5,
                                    child: Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
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
                                                  size: 16,
                                                  color: colors.textMuted),
                                              const SizedBox(width: 8),
                                              Text(
                                                _selectedStateId == null
                                                    ? 'Select State first'
                                                    : (districtsAsync?.when(
                                                          data: (_) =>
                                                              _selectedDistrictName ??
                                                              'Select District',
                                                          loading: () =>
                                                              'Loading districts...',
                                                          error: (_, __) =>
                                                              'Failed to load',
                                                        ) ??
                                                        'Select District'),
                                                style: AppTypography.body(
                                                  color:
                                                      _selectedDistrictName !=
                                                              null
                                                          ? colors.textPrimary
                                                          : colors.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Icon(LucideIcons.chevronDown,
                                              size: 18,
                                              color: colors.textMuted),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (_districtError != null) ...[
                                  const SizedBox(height: 5),
                                  Text(_districtError!,
                                      style: AppTypography.caption(
                                          color: colors.danger)),
                                ],
                                if (_districtPickerOpen &&
                                    districtsAsync != null)
                                  districtsAsync.when(
                                    data: (districts) => Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      constraints:
                                          const BoxConstraints(maxHeight: 200),
                                      decoration: BoxDecoration(
                                        color: colors.secondarySurface,
                                        borderRadius: AppRadius.cardRadius,
                                        border: Border.all(
                                            color: colors.border, width: 1),
                                      ),
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: districts
                                            .map((d) => ListTile(
                                                  title: Text(d.name,
                                                      style: AppTypography.body(
                                                          color: colors
                                                              .textPrimary)),
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedDistrictId =
                                                          d.id;
                                                      _selectedDistrictName =
                                                          d.name;
                                                      _districtPickerOpen =
                                                          false;
                                                    });
                                                  },
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                    loading: () => const SizedBox.shrink(),
                                    error: (_, __) => const SizedBox.shrink(),
                                  ),
                                const SizedBox(height: 16),
                              ],
                            ),

                            AppTextInput(
                              label: 'Password *',
                              placeholder:
                                  'Minimum 8 characters with letters & numbers',
                              isPassword: true,
                              controller: _passwordController,
                              error: _passwordError,
                              prefixIcon: Icon(LucideIcons.lock,
                                  size: 16, color: colors.textMuted),
                            ),

                            AppTextInput(
                              label: 'Confirm Password *',
                              placeholder: 'Repeat your password',
                              isPassword: true,
                              controller: _confirmPasswordController,
                              error: _confirmPasswordError,
                              prefixIcon: Icon(LucideIcons.shieldCheck,
                                  size: 16, color: colors.textMuted),
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
                                Text(
                                  'Already have an account? ',
                                  style: AppTypography.subhead(
                                      color: colors.textSecondary),
                                ),
                                GestureDetector(
                                  onTap: () => context.go('/login'),
                                  child: Text(
                                    'Sign in',
                                    style: AppTypography.subhead(
                                      color: colors.primaryAction,
                                      weight: AppFontWeight.semibold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
