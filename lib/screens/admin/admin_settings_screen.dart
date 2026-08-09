import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import 'admin_settings_details.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _isProfileExpanded = false;

  void _navigateToDetail(String title, Widget content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsDetailScreen(title: title, content: content),
      ),
    );
  }

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
              const Text('Settings', style: AppTextStyles.h1),
              const SizedBox(height: 24),
              // Admin profile card
              GestureDetector(
                onTap: () => setState(() => _isProfileExpanded = !_isProfileExpanded),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF004D40), Color(0xFF00695C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGreen.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.5), width: 2),
                            ),
                            child: Center(
                              child: Text(
                                user?.initials ?? 'A',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.displayName ?? 'Admin User',
                                  style: AppTextStyles.h4.copyWith(fontSize: 16),
                                ),
                                Text(
                                  user?.email ?? 'admin@syncspace.com',
                                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white60),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGreen.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      color: AppColors.accentGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _isProfileExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                      if (_isProfileExpanded) ...[
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 10),
                        _buildDetailRow('Account ID', user?.uid.substring(0, 8) ?? 'N/A'),
                        _buildDetailRow('Full Name', user?.displayName ?? 'N/A'),
                        _buildDetailRow('Email', user?.email ?? 'N/A'),
                        _buildDetailRow('Joined', 'August 2026'),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _navigateToDetail('Edit Profile', const Center(child: Text('Profile editing interface', style: AppTextStyles.bodyMedium))),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Edit Profile'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Settings items
              Text(
                'GENERAL',
                style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              _settingsItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Email & push notification preferences',
                onTap: () => _navigateToDetail('Notifications', const NotificationsInterface()),
              ),
              _settingsItem(
                icon: Icons.shield_outlined,
                title: 'Security',
                subtitle: 'Password & account protection',
                onTap: () => _navigateToDetail('Security', const SecurityInterface()),
              ),
              _settingsItem(
                icon: Icons.color_lens_outlined,
                title: 'Appearance',
                subtitle: 'Dark mode (always on)',
                onTap: () => _navigateToDetail('Appearance', const AppearanceInterface()),
              ),
              const SizedBox(height: 24),
              Text(
                'DATA',
                style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              _settingsItem(
                icon: Icons.cloud_outlined,
                title: 'Data Management',
                subtitle: 'Export or clear data',
                onTap: () => _navigateToDetail('Data Management', const DataManagementInterface()),
              ),
              _settingsItem(
                icon: Icons.info_outline_rounded,
                title: 'About SyncSpace',
                subtitle: 'Version 1.0.0',
                onTap: () => _navigateToDetail('About SyncSpace', const AboutInterface()),
              ),
              const SizedBox(height: 32),
              // Sign out
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () => auth.signOut(),
                  icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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
                color: AppColors.accentGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.accentGreen, size: 20),
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
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}
