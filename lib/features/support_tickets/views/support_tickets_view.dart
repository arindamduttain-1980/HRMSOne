import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/ticket_model.dart';
import '../controllers/ticket_controller.dart';

class SupportTicketsView extends GetView<TicketController> {
  const SupportTicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IT Support Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadTickets,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          controller.openCreateModal();
          _showCreateTicketSheet(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return ErrorStateView(
            error: controller.errorMessage.value,
            onRetry: controller.loadTickets,
          );
        }

        if (controller.tickets.isEmpty) {
          return EmptyStateView(
            icon: Icons.headset_mic_outlined,
            title: 'No Support Tickets',
            message: 'Need help with hardware, software, or network? Raise a ticket.',
            buttonText: 'Raise Ticket',
            onButtonPressed: () {
              controller.openCreateModal();
              _showCreateTicketSheet(context);
            },
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadTickets,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.tickets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final ticket = controller.tickets[i];
              return _buildTicketCard(context, ticket);
            },
          ),
        );
      }),
    );
  }

  Widget _buildTicketCard(BuildContext context, TicketModel ticket) {
    Color priorityColor;
    switch (ticket.priority.toLowerCase()) {
      case 'critical':
      case 'high':
        priorityColor = AppColors.danger;
        break;
      case 'medium':
        priorityColor = AppColors.warning;
        break;
      default:
        priorityColor = AppColors.primary;
    }

    return InkWell(
      onTap: () {
        controller.loadThread(ticket);
        Get.toNamed(AppRoutes.ticketThread);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.ticketNo,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    ticket.priority.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: priorityColor),
                  ),
                ),
                const Spacer(),
                StatusBadge(status: ticket.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ticket.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (ticket.description != null && ticket.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                ticket.description!,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (ticket.categoryName != null) ...[
                  const Icon(Icons.category_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    ticket.categoryName!,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
                const Spacer(),
                if (ticket.assignedToName != null)
                  Text(
                    'Assigned: ${ticket.assignedToName}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTicketSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Raise IT Ticket', style: AppTextStyles.h3),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  labelText: 'Subject / Title',
                  hintText: 'e.g. VPN connection drops',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Detailed Problem Description',
                  hintText: 'Describe what happened, any error messages...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<TicketCategoryModel>(
                          value: controller.selectedCategory.value,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: controller.categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat.name, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectedCategory.value = val;
                          },
                        )),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                          value: controller.selectedPriority.value,
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: controller.priorities.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text(p.toUpperCase(), style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectedPriority.value = val;
                          },
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: controller.createTicket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
