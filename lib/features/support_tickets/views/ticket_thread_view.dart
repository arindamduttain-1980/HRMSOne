import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/ticket_controller.dart';

class TicketThreadView extends GetView<TicketController> {
  const TicketThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.activeTicket.value?.ticketNo ?? 'Ticket Thread',
            )),
      ),
      body: Obx(() {
        final ticket = controller.activeTicket.value;
        if (ticket == null) {
          return const Center(child: Text('Ticket not found'));
        }

        return Column(
          children: [
            // Ticket Header Summary
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ticket.title,
                          style: AppTextStyles.h3,
                        ),
                      ),
                      StatusBadge(status: ticket.status),
                    ],
                  ),
                  if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      ticket.description!,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),

            // Discussion Thread
            Expanded(
              child: controller.isThreadLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.comments.isEmpty
                      ? const Center(
                          child: Text(
                            'No comments yet. Start the conversation below.',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.comments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (ctx, i) {
                            final comment = controller.comments[i];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        comment.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        DateFormatter.toDisplayDateTime(comment.createdAt),
                                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    comment.comment,
                                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),

            // Reply input bar
            Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: MediaQuery.of(context).padding.bottom + 8,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a reply...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        filled: true,
                        fillColor: AppColors.inputBg,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send_rounded, size: 20),
                    onPressed: controller.addComment,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

