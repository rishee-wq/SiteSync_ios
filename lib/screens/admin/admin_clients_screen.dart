import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class AdminClientsScreen extends StatelessWidget {
  const AdminClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Clients', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(
                'All registered clients',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<List<UserModel>>(
                  stream: firestoreService.getAllClients(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.accentGreen),
                      );
                    }

                    final clients = snapshot.data ?? [];

                    if (clients.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              'No clients yet',
                              style: AppTextStyles.h4.copyWith(color: AppColors.textTertiary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Clients will appear here after they sign up.',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: clients.length,
                      itemBuilder: (context, index) {
                        final client = clients[index];
                        return _ClientCard(client: client);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final UserModel client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Client details for ${client.displayName} (Interface coming soon)'),
            backgroundColor: AppColors.accentGreen.withValues(alpha: 0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.profileGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  client.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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
                    client.displayName,
                    style: AppTextStyles.h4.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.email,
                    style: AppTextStyles.bodySmall,
                  ),
                  if (client.websiteUrl.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.language_rounded, size: 12, color: AppColors.accentCyan),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            client.websiteUrl,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accentCyan,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Switch(
                  value: client.isWebsiteVerified,
                  onChanged: (val) {
                    FirestoreService().updateWebsiteVerification(client.uid, val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? 'Website marked as verified' : 'Website marked as unverified'),
                        backgroundColor: AppColors.accentGreen.withValues(alpha: 0.8),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  activeColor: AppColors.accentGreen,
                ),
                FutureBuilder<Map<String, int>>(
              future: FirestoreService().getUserRequestStats(client.uid),
              builder: (context, snapshot) {
                final stats = snapshot.data;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${stats?['total'] ?? 0} requests',
                    style: const TextStyle(
                      color: AppColors.accentPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
