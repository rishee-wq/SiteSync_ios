import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;
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
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sync_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CLIENT PORTAL',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textTertiary,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '${_getGreeting()}, ${user?.displayName.split(' ').first ?? "there"}',
                          style: AppTextStyles.h3,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Animated Banner
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 160,
                  child: Stack(
                    children: [
                      AnimatedBackground(
                        colors: const [
                          Color(0xFF1A237E),
                          Color(0xFF00897B),
                          Color(0xFF6C63FF),
                        ],
                        child: const SizedBox.expand(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'YOUR WEBSITE, IN MOTION',
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.accentGreen,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'What can we make\nbetter today?',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Send a request and we\'ll take it from there.',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/new-request'),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentGreen.withValues(alpha: 0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_outward_rounded,
                                  color: AppColors.primaryDark,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Active Requests
              StreamBuilder<List<RequestModel>>(
                stream: firestoreService.getUserRequests(user?.uid ?? ''),
                builder: (context, snapshot) {
                  final requests = snapshot.data ?? [];
                  final activeRequests = requests
                      .where((r) => r.status != 'resolved')
                      .toList();

                  final totalRequests = requests.length;
                  final resolved =
                      requests.where((r) => r.status == 'resolved').length;
                  final waitingOnClient = requests
                      .where((r) => r.status == 'waiting_on_client')
                      .length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ACTIVE REQUESTS',
                            style: AppTextStyles.label.copyWith(
                              letterSpacing: 1.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navigate to requests tab - handled by parent
                            },
                            child: const Text(
                              'View all',
                              style: TextStyle(
                                color: AppColors.accentPurple,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Active request cards
                      if (activeRequests.isEmpty)
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
                              Icon(
                                Icons.check_circle_outline_rounded,
                                color: AppColors.accentGreen,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'All caught up!',
                                style: AppTextStyles.h4,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No active requests right now.',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      else
                        ...activeRequests.take(3).map(
                              (request) => _ActiveRequestCard(
                                request: request,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/request-detail',
                                    arguments: request,
                                  );
                                },
                              ),
                            ),
                      const SizedBox(height: 24),
                      // Stats row
                      Row(
                        children: [
                          StatCard(
                            label: 'Total requests',
                            value: totalRequests,
                            icon: Icons.trending_up_rounded,
                            color: AppColors.accentPurple,
                          ),
                          const SizedBox(width: 10),
                          StatCard(
                            label: 'Resolved',
                            value: resolved,
                            icon: Icons.check_circle_outline_rounded,
                            color: AppColors.accentGreen,
                          ),
                          const SizedBox(width: 10),
                          StatCard(
                            label: 'Your Input',
                            value: waitingOnClient,
                            icon: Icons.access_time_rounded,
                            color: AppColors.statusWaiting,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Your Site
                      Text(
                        'YOUR SITE',
                        style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.accentPurple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.language_rounded,
                                color: AppColors.accentPurple,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.businessName.isNotEmpty == true
                                        ? user!.businessName
                                        : 'Your Website',
                                    style: AppTextStyles.h4,
                                  ),
                                  Text(
                                    user?.websiteUrl.isNotEmpty == true
                                        ? user!.websiteUrl
                                        : 'Not set',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        user?.isWebsiteVerified == true ? Icons.verified_rounded : Icons.pending_rounded,
                                        size: 14,
                                        color: user?.isWebsiteVerified == true ? AppColors.accentGreen : AppColors.statusWaiting,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        user?.isWebsiteVerified == true ? 'Verified' : 'Verification Pending',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: user?.isWebsiteVerified == true ? AppColors.accentGreen : AppColors.statusWaiting,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new_rounded,
                              color: AppColors.textTertiary,
                              size: 18,
                            ),
                          ],
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

class _ActiveRequestCard extends StatelessWidget {
  final RequestModel request;
  final VoidCallback? onTap;

  const _ActiveRequestCard({required this.request, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentPurple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.accentPurple,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.title,
                    style: AppTextStyles.h4.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatusBadge(status: request.status),
                      const SizedBox(width: 8),
                      Text(
                        request.priority == 'Urgent'
                            ? 'Urgent'
                            : request.priority == 'High'
                                ? 'Tomorrow'
                                : 'This week',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
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
}
