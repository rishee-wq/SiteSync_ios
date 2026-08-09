import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_text_styles.dart';
import '../models/request_model.dart';
import 'status_badge.dart';

class RequestCard extends StatelessWidget {
  final RequestModel request;
  final VoidCallback? onTap;
  final bool showUserName;

  const RequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.showUserName = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request.requestNumber,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accentPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      DateFormat('MMM d').format(request.createdAt),
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              request.title,
              style: AppTextStyles.h4,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showUserName) ...[
              const SizedBox(height: 4),
              Text(
                request.userName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accentCyan,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              request.description,
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                StatusBadge(status: request.status),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '◇ ',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        request.category,
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
