import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

class SettingsDetailScreen extends StatelessWidget {
  final String title;
  final Widget content;

  const SettingsDetailScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: content,
        ),
      ),
    );
  }
}

class NotificationsInterface extends StatelessWidget {
  const NotificationsInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToggleItem('Email Notifications', 'Receive updates via email', true),
        _buildToggleItem('Push Notifications', 'Real-time alerts on device', true),
        _buildToggleItem('System Updates', 'New features and maintenance', false),
      ],
    );
  }

  Widget _buildToggleItem(String title, String sub, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h4.copyWith(fontSize: 15)),
                Text(sub, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: AppColors.accentGreen,
          ),
        ],
      ),
    );
  }
}

class SecurityInterface extends StatelessWidget {
  const SecurityInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildActionItem(Icons.lock_reset_rounded, 'Change Password', 'Update your login credentials'),
        _buildActionItem(Icons.fingerprint_rounded, 'Biometric Login', 'Use face or fingerprint'),
        _buildActionItem(Icons.devices_rounded, 'Active Sessions', 'Manage your logged in devices'),
      ],
    );
  }

  Widget _buildActionItem(IconData icon, String title, String sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h4.copyWith(fontSize: 15)),
                Text(sub, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

class AppearanceInterface extends StatelessWidget {
  const AppearanceInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOptionItem('Theme Mode', 'Dark Mode', true),
        _buildOptionItem('Accent Color', 'Emerald Green', false),
        _buildOptionItem('Font Size', 'Medium', false),
      ],
    );
  }

  Widget _buildOptionItem(String title, String value, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.h4.copyWith(fontSize: 15)),
          Row(
            children: [
              Text(value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentGreen)),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
            ],
          ),
        ],
      ),
    );
  }
}

class DataManagementInterface extends StatelessWidget {
  const DataManagementInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDataItem(Icons.download_rounded, 'Export Requests', 'Download all data as CSV'),
        _buildDataItem(Icons.history_rounded, 'Backup History', 'View previous cloud backups'),
        _buildDataItem(Icons.delete_sweep_rounded, 'Clear Cache', 'Free up local storage space', isDestructive: true),
      ],
    );
  }

  Widget _buildDataItem(IconData icon, String title, String sub, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDestructive ? Colors.redAccent : AppColors.accentPurple, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h4.copyWith(fontSize: 15, color: isDestructive ? Colors.redAccent : Colors.white)),
                Text(sub, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

class AboutInterface extends StatelessWidget {
  const AboutInterface({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.sync_rounded, color: Colors.white, size: 50),
        ),
        const SizedBox(height: 24),
        const Text('SyncSpace', style: AppTextStyles.h1),
        const Text('Professional Service Management', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 40),
        _buildInfoTile('Version', '1.0.0 (Build 2026.08.09)'),
        _buildInfoTile('Developer', 'SitePulse Pro Studio'),
        _buildInfoTile('Website', 'www.sitepulsepro.com'),
        const SizedBox(height: 40),
        const Text('© 2026 SitePulse Pro Services. All rights reserved.', style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
