import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../data/models/chat_model.dart';
import '../controllers/messenger_controller.dart';

class MessengerView extends GetView<MessengerController> {
  const MessengerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Internal Messenger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadGroups,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return ErrorStateView(
            error: controller.errorMessage.value,
            onRetry: controller.loadGroups,
          );
        }

        if (controller.groups.isEmpty) {
          return const EmptyStateView(
            icon: Icons.chat_bubble_outline,
            title: 'No Conversations',
            message: 'You have no active direct messages or chat groups.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadGroups,
          child: ListView.separated(
            itemCount: controller.groups.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (ctx, i) {
              final group = controller.groups[i];
              return _buildConversationTile(context, group);
            },
          ),
        );
      }),
    );
  }

  Widget _buildConversationTile(BuildContext context, ChatGroupModel group) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: group.isGroup ? AppColors.secondary.withOpacity(0.15) : AppColors.primary.withOpacity(0.12),
        child: Icon(
          group.isGroup ? Icons.groups_rounded : Icons.person_rounded,
          color: group.isGroup ? AppColors.secondary : AppColors.primary,
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              group.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (group.lastMessageAt != null)
            Text(
              DateFormatter.toDisplayTime(group.lastMessageAt),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              group.lastMessage ?? 'No messages yet',
              style: TextStyle(
                fontSize: 13,
                color: group.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: group.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (group.unreadCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${group.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        controller.openGroup(group);
        Get.toNamed(AppRoutes.chatThread);
      },
    );
  }
}
