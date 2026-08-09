import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/request_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/request_card.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _filters = ['All', 'New', 'In progress', 'Waiting', 'Resolved'];

  String _filterToStatus(String filter) {
    switch (filter) {
      case 'New':
        return 'new';
      case 'In progress':
        return 'in_progress';
      case 'Waiting':
        return 'waiting_on_client';
      case 'Resolved':
        return 'resolved';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              const Text('All Requests', style: AppTextStyles.h1),
              const SizedBox(height: 4),
              Text(
                'Manage requests from all clients',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              // Search
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search requests...',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: AppColors.textTertiary, size: 20),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accentGreen : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.accentGreen : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              // Request list
              Expanded(
                child: StreamBuilder<List<RequestModel>>(
                  stream: firestoreService.getAllRequests(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.accentGreen),
                      );
                    }

                    var requests = snapshot.data ?? [];

                    // Apply filter
                    if (_selectedFilter != 'All') {
                      final status = _filterToStatus(_selectedFilter);
                      requests = requests.where((r) => r.status == status).toList();
                    }

                    // Apply search
                    if (_searchQuery.isNotEmpty) {
                      requests = requests.where((r) {
                        return r.title.toLowerCase().contains(_searchQuery) ||
                            r.userName.toLowerCase().contains(_searchQuery) ||
                            r.requestNumber.toLowerCase().contains(_searchQuery);
                      }).toList();
                    }

                    if (requests.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text('No requests found', style: AppTextStyles.h4.copyWith(color: AppColors.textTertiary)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return RequestCard(
                          request: requests[index],
                          showUserName: true,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/admin-request-detail',
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
