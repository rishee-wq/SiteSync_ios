import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/animated_background.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessController = TextEditingController();
  final _websiteController = TextEditingController();
  bool _isLoading = false;
  bool _acceptTerms = false;
  double _passwordStrength = 0;
  String _passwordStrengthLabel = '';
  Color _passwordStrengthColor = Colors.red;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessController.dispose();
    _websiteController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    String label;
    Color color;
    if (strength <= 0.25) {
      label = 'Weak';
      color = Colors.red;
    } else if (strength <= 0.5) {
      label = 'Fair';
      color = Colors.orange;
    } else if (strength <= 0.75) {
      label = 'Good';
      color = Colors.amber;
    } else {
      label = 'Strong';
      color = AppColors.accentGreen;
    }

    setState(() {
      _passwordStrength = strength;
      _passwordStrengthLabel = label;
      _passwordStrengthColor = color;
    });
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
            businessName: _businessController.text.trim(),
            websiteUrl: _websiteController.text.trim(),
          );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/verify-email');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<AuthProvider>().error ?? 'Sign up failed',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            colors: const [
              Color(0xFF0A0E21),
              Color(0xFF1A1F45),
              Color(0xFF0F1535),
            ],
            child: const SizedBox.expand(),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Back button
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      // Header
                      Center(
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.primaryGradient.createShader(bounds),
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Join SyncSpace to manage your website',
                              style: AppTextStyles.bodyMedium.copyWith(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Full name
                      CustomTextField(
                        label: 'FULL NAME',
                        hint: 'Enter your full name',
                        controller: _nameController,
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textTertiary, size: 20),
                        validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      // Email
                      CustomTextField(
                        label: 'EMAIL',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textTertiary, size: 20),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email is required';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Password
                      CustomTextField(
                        label: 'PASSWORD',
                        hint: 'Create a strong password',
                        controller: _passwordController,
                        showPasswordToggle: true,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 20),
                        onChanged: _checkPasswordStrength,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required';
                          if (value.length < 8) return 'Minimum 8 characters';
                          return null;
                        },
                      ),
                      // Password strength meter
                      if (_passwordController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _passwordStrength,
                                  backgroundColor: AppColors.cardBorder,
                                  valueColor: AlwaysStoppedAnimation(_passwordStrengthColor),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _passwordStrengthLabel,
                              style: TextStyle(
                                color: _passwordStrengthColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: [
                            _requirement('8+ chars', _passwordController.text.length >= 8),
                            _requirement('Uppercase', _passwordController.text.contains(RegExp(r'[A-Z]'))),
                            _requirement('Number', _passwordController.text.contains(RegExp(r'[0-9]'))),
                            _requirement('Special', _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Confirm password
                      CustomTextField(
                        label: 'CONFIRM PASSWORD',
                        hint: 'Re-enter your password',
                        controller: _confirmPasswordController,
                        showPasswordToggle: true,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary, size: 20),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please confirm your password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Business name
                      CustomTextField(
                        label: 'BUSINESS NAME (OPTIONAL)',
                        hint: 'Your business or company name',
                        controller: _businessController,
                        prefixIcon: const Icon(Icons.business_outlined, color: AppColors.textTertiary, size: 20),
                      ),
                      const SizedBox(height: 16),
                      // Website URL
                      CustomTextField(
                        label: 'WEBSITE URL (OPTIONAL)',
                        hint: 'yourbusiness.com',
                        controller: _websiteController,
                        keyboardType: TextInputType.url,
                        prefixIcon: const Icon(Icons.language_rounded, color: AppColors.textTertiary, size: 20),
                      ),
                      const SizedBox(height: 20),
                      // Terms
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _acceptTerms ? AppColors.accentPurple : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _acceptTerms ? AppColors.accentPurple : AppColors.textTertiary,
                                  width: 2,
                                ),
                              ),
                              child: _acceptTerms
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'I agree to the Terms of Service and Privacy Policy',
                              style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Sign up button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSignUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.accentPurple.withValues(alpha: 0.4),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Already have account
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: AppTextStyles.bodyMedium,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: AppColors.accentPurple,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _requirement(String text, bool met) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.circle_outlined,
          size: 12,
          color: met ? AppColors.accentGreen : AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: met ? AppColors.accentGreen : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
