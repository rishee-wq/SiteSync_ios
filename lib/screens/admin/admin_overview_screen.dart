import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/request_card.dart';
import '../../widgets/animated_background.dart';
import '../../models/user_model.dart';

class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.greenGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primaryDark, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADMIN DASHBOARD',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.accentGreen,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'Welcome, ${auth.userModel?.displayName.split(' ').first ?? "Admin"}',
                          style: AppTextStyles.h3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Admin banner
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 120,
                  child: Stack(
                    children: [
                      AnimatedBackground(
                        colors: const [
                          Color(0xFF004D40),
                          Color(0xFF1A237E),
                          Color(0xFF006064),
                        ],
                        child: const SizedBox.expand(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Command Center',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage all client requests from here.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Stats
              StreamBuilder<List<RequestModel>>(
                stream: firestoreService.getAllRequests(),
                builder: (context, snapshot) {
                  final requests = snapshot.data ?? [];
                  final total = requests.length;
                  final newCount = requests.where((r) => r.status == 'new').length;
                  final inProgress = requests.where((r) => r.status == 'in_progress').length;
                  final waiting = requests.where((r) => r.status == 'waiting_on_client').length;
                  final resolved = requests.where((r) => r.status == 'resolved').length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatCard(
                            label: 'Total',
                            value: total,
                            icon: Icons.inbox_rounded,
                            color: AppColors.accentPurple,
                          ),
                          const SizedBox(width: 8),
                          StatCard(
                            label: 'New',
                            value: newCount,
                            icon: Icons.fiber_new_rounded,
                            color: AppColors.statusNew,
                          ),
                          const SizedBox(width: 8),
                          StatCard(
                            label: 'In Progress',
                            value: inProgress,
                            icon: Icons.autorenew_rounded,
                            color: AppColors.statusInProgress,
                          ),
                          const SizedBox(width: 8),
                          StatCard(
                            label: 'Resolved',
                            value: resolved,
                            icon: Icons.check_circle_outline,
                            color: AppColors.statusResolved,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      StreamBuilder<List<UserModel>>(
                        stream: firestoreService.getAllClients(),
                        builder: (context, clientSnapshot) {
                          final clients = clientSnapshot.data ?? [];
                          final verifiedWebsites = clients.where((c) => c.isWebsiteVerified).length;
                          return Row(
                            children: [
                              StatCard(
                                label: 'Verified Sites',
                                value: verifiedWebsites,
                                icon: Icons.verified_rounded,
                                color: AppColors.accentGreen,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: const SizedBox()), // filler
                              const SizedBox(width: 8),
                              Expanded(child: const SizedBox()), // filler
                              const SizedBox(width: 8),
                              Expanded(child: const SizedBox()), // filler
                            ],
                          );
                        }
                      ),
                      const SizedBox(height: 28),
                      // Recent requests
                      Text(
                        'RECENT REQUESTS',
                        style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 12),
                      if (requests.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.inbox_rounded, size: 40, color: AppColors.textTertiary),
                              const SizedBox(height: 8),
                              const Text('No requests yet', style: AppTextStyles.h4),
                              Text('Requests from clients will appear here.', style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        )
                      else
                        ...requests.take(5).map(
                              (request) => RequestCard(
                                request: request,
                                showUserName: true,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/admin-request-detail',
                                    arguments: request,
                                  );
                                },
                              ),
                            ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
