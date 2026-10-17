import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/app_animations.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_text_input.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    setState(() {
      _emailError = null;
      _passwordError = null;

      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (email.isEmpty || !emailRegex.hasMatch(email)) {
        _emailError = 'Please enter a valid email address';
        isValid = false;
      }

      if (password.isEmpty) {
        _passwordError = 'Password is required';
        isValid = false;
      }
    });
    return isValid;
  }

  Future<void> _onSubmit() async {
    if (_isLoading) return;
    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      await ref.read(authProvider.notifier).login(
            email: email,
            password: password,
          );
      // Router redirect handles navigation on auth state change
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
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Brand Logo & Headline with Staggered Entrance
                    StaggeredSlideFade(
                      index: 0,
                      child: Column(
                        children: [
                          const AppLogo(
                            size: 88,
                            heroTag: 'app_logo',
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'TAPSU',
                            style:
                                AppTypography.title1(color: colors.textPrimary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Workforce Management Platform',
                            style: AppTypography.subhead(
                                color: colors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Login Card with Staggered Entrance
                    StaggeredSlideFade(
                      index: 1,
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sign In',
                                style: AppTypography.title2(
                                    color: colors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Enter your manager or administrator credentials',
                                style: AppTypography.caption(
                                    color: colors.textMuted),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              AppTextInput(
                                label: 'Email Address',
                                placeholder: 'name@taspu.in',
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                error: _emailError,
                                prefixIcon: Icon(LucideIcons.mail,
                                    size: 16, color: colors.textMuted),
                              ),

                              AppTextInput(
                                label: 'Password',
                                placeholder: 'Enter your password',
                                isPassword: true,
                                controller: _passwordController,
                                error: _passwordError,
                                prefixIcon: Icon(LucideIcons.lock,
                                    size: 16, color: colors.textMuted),
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              AppButton(
                                label: 'Sign In',
                                onPress: _onSubmit,
                                loading: _isLoading,
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Register Navigation Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Need a manager account? ',
                                    style: AppTypography.subhead(
                                        color: colors.textSecondary),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push('/register'),
                                    child: Text(
                                      'Register here',
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
                    ),
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
