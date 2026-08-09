import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';
import '../../models/request_model.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/status_badge.dart';

class RequestDetailScreen extends StatefulWidget {
  final RequestModel request;

  const RequestDetailScreen({super.key, required this.request});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _firestoreService = FirestoreService();

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
      senderRole: auth.userModel!.role,
      content: content,
    );

    // Scroll to bottom
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
                color: AppColors.accentPurple,
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
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () {},
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
                  // Status and date
                  Row(
                    children: [
                      StatusBadge(status: widget.request.status),
                      const SizedBox(width: 12),
                      Text(
                        'Updated ${DateFormat('MMM d').format(widget.request.updatedAt)}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Title
                  Text(widget.request.title, style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    widget.request.description,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Tags
                  _tag('◇ ${widget.request.category}'),
                  const SizedBox(height: 8),
                  _tag('◆ ${widget.request.priority} priority'),
                  const SizedBox(height: 8),
                  _tag('◷ ${_getTimeEstimate()}'),
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
                            child: Text(
                              'No messages yet. Start the conversation!',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: messages.map((msg) {
                          final isAdmin = msg.senderRole == 'admin';
                          return _MessageBubble(
                            message: msg,
                            isAdmin: isAdmin,
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
          // Reply input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              border: Border(
                top: BorderSide(
                  color: AppColors.cardBorder.withValues(alpha: 0.5),
                ),
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
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Write a reply...',
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
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentPurple.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
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

  Widget _tag(String text) {
    return Row(
      children: [
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
        ),
      ],
    );
  }

  String _getTimeEstimate() {
    switch (widget.request.priority) {
      case 'Urgent':
        return 'Today';
      case 'High':
        return 'Tomorrow';
      default:
        return 'This week';
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isAdmin;

  const _MessageBubble({required this.message, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAdmin
            ? AppColors.accentPurple.withValues(alpha: 0.15)
            : AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAdmin
              ? AppColors.accentPurple.withValues(alpha: 0.3)
              : AppColors.cardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                message.senderName,
                style: TextStyle(
                  color: isAdmin ? AppColors.accentPurple : AppColors.accentGreen,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                DateFormat('MMM d').format(message.createdAt),
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message.content,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
