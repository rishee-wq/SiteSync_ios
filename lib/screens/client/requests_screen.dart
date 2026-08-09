import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/request_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/request_card.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _selectedFilter = 'All';
  final _filters = ['All', 'New', 'In progress', 'Waiting on you', 'Resolved'];

  String _filterToStatus(String filter) {
    switch (filter) {
      case 'New':
        return 'new';
      case 'In progress':
        return 'in_progress';
      case 'Waiting on you':
        return 'waiting_on_client';
      case 'Resolved':
        return 'resolved';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
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
              // Header
              StreamBuilder<List<RequestModel>>(
                stream: firestoreService.getUserRequests(auth.userModel?.uid ?? ''),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return Row(
                    children: [
                      const Text('Requests', style: AppTextStyles.h1),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                'Everything we\'re working on together.',
                style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 16),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentPurple
                                : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentPurple
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // New request button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/new-request'),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'New request',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 6,
                    shadowColor: AppColors.accentPurple.withValues(alpha: 0.4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Request list
              Expanded(
                child: StreamBuilder<List<RequestModel>>(
                  stream: firestoreService
                      .getUserRequests(auth.userModel?.uid ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentPurple,
                        ),
                      );
                    }

                    var requests = snapshot.data ?? [];

                    // Apply filter
                    if (_selectedFilter != 'All') {
                      final status = _filterToStatus(_selectedFilter);
                      requests = requests
                          .where((r) => r.status == status)
                          .toList();
                    }

                    if (requests.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 48,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No requests found',
                              style: AppTextStyles.h4.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return RequestCard(
                          request: requests[index],
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/request-detail',
                              arguments: requests[index],
                            );
                          },
                        );
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
