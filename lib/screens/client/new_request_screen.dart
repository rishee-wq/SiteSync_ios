import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/custom_text_field.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  State<NewRequestScreen> createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'UI update';
  String _selectedPriority = 'Normal';
  bool _isSubmitting = false;

  late AnimationController _fadeController;

  final _categoryIcons = {
    'UI update': Icons.dashboard_customize_rounded,
    'Event setup': Icons.event_rounded,
    'Bug fix': Icons.build_rounded,
    'Content change': Icons.edit_rounded,
    'Other': Icons.more_horiz_rounded,
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final auth = context.read<AuthProvider>();
      final firestoreService = FirestoreService();

      await firestoreService.createRequest(
        userId: auth.userModel!.uid,
        userEmail: auth.userModel!.email,
        userName: auth.userModel!.displayName,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Request submitted successfully! 🎉'),
            backgroundColor: AppColors.accentGreen.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'NEW REQUEST',
          style: AppTextStyles.label.copyWith(
            color: AppColors.accentGreen,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tell us what\'s on\nyour mind.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The more context you share, the faster we can make the right fix.',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 28),
                // Category selection
                Text(
                  'WHAT DO YOU NEED?',
                  style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppConstants.categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: (MediaQuery.of(context).size.width - 50) / 2,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentPurple.withValues(alpha: 0.2)
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentPurple
                                : AppColors.cardBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _categoryIcons[cat] ?? Icons.help_outline,
                              color: isSelected
                                  ? AppColors.accentPurple
                                  : AppColors.textTertiary,
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.accentPurple
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                // Priority
                Text(
                  'PRIORITY',
                  style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                Row(
                  children: AppConstants.priorities.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedPriority = priority),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                            right: priority != 'Urgent' ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentPurple.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accentPurple
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.accentPurple
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.accentPurple
                                        : AppColors.textTertiary,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Center(
                                        child: CircleAvatar(
                                          radius: 3,
                                          backgroundColor: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                priority,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                // Title
                CustomTextField(
                  label: 'REQUEST TITLE',
                  hint: 'e.g. Update our booking page',
                  controller: _titleController,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 20),
                // Description
                CustomTextField(
                  label: 'DETAILS',
                  hint:
                      'What would you like changed? Include links, timing, or examples if helpful.',
                  controller: _descriptionController,
                  maxLines: 5,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please provide some details'
                      : null,
                ),
                const SizedBox(height: 32),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.accentPurple.withValues(alpha: 0.4),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Submit Request',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
