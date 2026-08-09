import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Profile', style: AppTextStyles.h1),
                  GestureDetector(
                    onTap: () => _showEditProfile(context),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.accentPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Profile card with glassmorphism
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.profileGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPurple.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            user?.initials ?? 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.displayName ?? 'User',
                        style: AppTextStyles.h3.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      if (user?.websiteUrl.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.language_rounded,
                              color: Colors.white54,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user!.websiteUrl,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Account section
              Text(
                'ACCOUNT',
                style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              _settingsItem(
                icon: Icons.store_rounded,
                title: 'Business website',
                subtitle: user?.websiteUrl.isNotEmpty == true
                    ? user!.websiteUrl
                    : 'Not set',
                onTap: () => _showEditProfile(context),
              ),
              _settingsItem(
                icon: Icons.email_outlined,
                title: 'Contact email',
                subtitle: user?.email ?? '',
                onTap: () => _showEditProfile(context),
              ),
              if (auth.firebaseUser != null && !auth.firebaseUser!.emailVerified)
                _settingsItem(
                  icon: Icons.mark_email_unread_outlined,
                  title: 'Verify Email',
                  subtitle: 'Tap to send verification email',
                  onTap: () async {
                    try {
                      await auth.sendEmailVerification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Verification email sent!')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                ),
              _settingsItem(
                icon: Icons.shield_outlined,
                title: 'Account security',
                subtitle: 'Protected',
                onTap: () => _showEditProfile(context),
              ),
              const SizedBox(height: 24),
              // Notifications section
              Text(
                'NOTIFICATIONS',
                style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              _notificationToggle(
                context: context,
                icon: Icons.notifications_outlined,
                title: 'Request updates',
                subtitle: 'Status changes and replies',
                value: user?.requestUpdates ?? true,
                onChanged: (val) {
                  auth.updateProfile(requestUpdates: val);
                },
              ),
              _notificationToggle(
                context: context,
                icon: Icons.campaign_outlined,
                title: 'Studio updates',
                subtitle: 'Occasional tips for your website',
                value: user?.studioUpdates ?? true,
                onChanged: (val) {
                  auth.updateProfile(studioUpdates: val);
                },
              ),
              const SizedBox(height: 32),
              // Sign out
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => auth.signOut(),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.accentPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h4.copyWith(fontSize: 14)),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationToggle({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accentPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h4.copyWith(fontSize: 14)),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final nameController = TextEditingController(text: auth.userModel?.displayName);
    final businessController = TextEditingController(text: auth.userModel?.businessName);
    final websiteController = TextEditingController(text: auth.userModel?.websiteUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Edit Profile', style: AppTextStyles.h3),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: businessController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Business Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: websiteController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Website URL'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  auth.updateProfile(
                    displayName: nameController.text.trim(),
                    businessName: businessController.text.trim(),
                    websiteUrl: websiteController.text.trim(),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
