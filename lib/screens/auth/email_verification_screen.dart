import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _canResend = true;
  int _cooldown = 0;
  Timer? _cooldownTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start checking verification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().startVerificationCheck();
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _pulseController.dispose();
    context.read<AuthProvider>().stopVerificationCheck();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _canResend = false;
      _cooldown = 60;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _cooldown--;
        if (_cooldown <= 0) {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;
    try {
      await context.read<AuthProvider>().sendEmailVerification();
      _startCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Verification email sent! Check your inbox and spam.'),
            backgroundColor: AppColors.accentGreen.withValues(alpha: 0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('too-many-requests')) {
          errorMsg = 'Too many requests. Please wait a few minutes.';
        } else if (errorMsg.contains('firebase_auth/api-not-enabled')) {
          errorMsg = 'Email verification is not enabled in Firebase Console.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMsg'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated mail icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentPurple.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Check your email',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return Text(
                    'We\'ve sent a verification link to\n${auth.firebaseUser?.email ?? "your email"}',
                    style: AppTextStyles.bodyMedium.copyWith(fontSize: 15),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 40),
              // Resend button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canResend ? _resendEmail : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canResend
                        ? AppColors.accentPurple
                        : AppColors.cardDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _canResend
                        ? 'Resend Verification Email'
                        : 'Resend in ${_cooldown}s',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _canResend ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Auto-checking indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accentGreen.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Auto-checking verification status...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accentGreen.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Skip verification button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => context.read<AuthProvider>().skipVerification(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accentGreen, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Skip Verification for now',
                    style: TextStyle(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Sign out / back
              TextButton(
                onPressed: () => context.read<AuthProvider>().signOut(),
                child: const Text(
                  'Use a different email',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
