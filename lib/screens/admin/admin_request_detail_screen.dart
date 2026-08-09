import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../config/constants.dart';
import '../../models/request_model.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/status_badge.dart';

class AdminRequestDetailScreen extends StatefulWidget {
  final RequestModel request;

  const AdminRequestDetailScreen({super.key, required this.request});

  @override
  State<AdminRequestDetailScreen> createState() =>
      _AdminRequestDetailScreenState();
}

class _AdminRequestDetailScreenState extends State<AdminRequestDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _firestoreService = FirestoreService();
  late String _currentStatus;
  late String _currentPriority;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.request.status;
    _currentPriority = widget.request.priority;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final auth = context.read<AuthProvider>();
    _messageController.clear();

    await _firestoreService.sendMessage(
      requestId: widget.request.id,
      senderId: auth.userModel!.uid,
      senderName: auth.userModel!.displayName,
      senderRole: 'admin',
      content: content,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _updateStatus(String status) async {
    await _firestoreService.updateRequestStatus(widget.request.id, status);
    setState(() => _currentStatus = status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${AppConstants.statusLabel(status)}'),
          backgroundColor: AppColors.accentGreen.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _updatePriority(String priority) async {
    await _firestoreService.updateRequestPriority(widget.request.id, priority);
    setState(() => _currentPriority = priority);
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.request.requestNumber,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.request.title,
              style: AppTextStyles.h4.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            color: AppColors.cardDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    SizedBox(width: 8),
                    Text('Delete Request', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, color: AppColors.accentCyan, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Client: ${widget.request.userName}',
                          style: const TextStyle(color: AppColors.accentCyan, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          widget.request.userEmail,
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Status management
                  Text(
                    'STATUS',
                    style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: AppConstants.statuses.map((status) {
                        final isSelected = _currentStatus == status;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => _updateStatus(status),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _statusColor(status).withValues(alpha: 0.2)
                                    : AppColors.cardDark,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? _statusColor(status) : AppColors.cardBorder,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                AppConstants.statusLabel(status),
                                style: TextStyle(
                                  color: isSelected ? _statusColor(status) : AppColors.textSecondary,
                                  fontSize: 12,
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
                  // Priority management
                  Text(
                    'PRIORITY',
                    style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: AppConstants.priorities.map((priority) {
                      final isSelected = _currentPriority == priority;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _updatePriority(priority),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accentPurple.withValues(alpha: 0.2)
                                  : AppColors.cardDark,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppColors.accentPurple : AppColors.cardBorder,
                              ),
                            ),
                            child: Text(
                              priority,
                              style: TextStyle(
                                color: isSelected ? AppColors.accentPurple : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Title & Description
                  Text(widget.request.title, style: AppTextStyles.h2),
                  const SizedBox(height: 10),
                  Text(
                    widget.request.description,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _infoTag('◇ ${widget.request.category}'),
                      const SizedBox(width: 8),
                      _infoTag('Created ${DateFormat('MMM d').format(widget.request.createdAt)}'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Conversation
                  Text(
                    'CONVERSATION',
                    style: AppTextStyles.label.copyWith(letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<MessageModel>>(
                    stream: _firestoreService.getMessages(widget.request.id),
                    builder: (context, snapshot) {
                      final messages = snapshot.data ?? [];
                      if (messages.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Center(
                            child: Text('No messages yet.', style: AppTextStyles.bodyMedium),
                          ),
                        );
                      }
                      return Column(
                        children: messages.map((msg) {
                          final isAdmin = msg.senderRole == 'admin';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isAdmin
                                  ? AppColors.accentGreen.withValues(alpha: 0.08)
                                  : AppColors.cardDark,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isAdmin
                                    ? AppColors.accentGreen.withValues(alpha: 0.2)
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          msg.senderName,
                                          style: TextStyle(
                                            color: isAdmin ? AppColors.accentGreen : AppColors.accentPurple,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (isAdmin) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.accentGreen.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'ADMIN',
                                              style: TextStyle(color: AppColors.accentGreen, fontSize: 9, fontWeight: FontWeight.w700),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      DateFormat('MMM d').format(msg.createdAt),
                                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  msg.content,
                                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 14, height: 1.5),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Admin reply input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              border: Border(
                top: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Reply as admin...',
                        hintStyle: TextStyle(color: AppColors.textTertiary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.greenGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGreen.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primaryDark,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(text, style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new': return AppColors.statusNew;
      case 'in_progress': return AppColors.statusInProgress;
      case 'waiting_on_client': return AppColors.statusWaiting;
      case 'resolved': return AppColors.statusResolved;
      default: return AppColors.textSecondary;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Request?', style: AppTextStyles.h3),
        content: const Text(
          'This action cannot be undone. The request and all its messages will be permanently deleted.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _firestoreService.deleteRequest(widget.request.id);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
