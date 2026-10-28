import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/leads_controller.dart';

class LeadThreadView extends GetView<LeadsController> {
  const LeadThreadView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.activeLead.value?.leadNo ?? 'Lead Details',
            )),
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final lead = controller.activeLead.value;
        if (lead == null) {
          return const Center(child: Text('Lead details not found.'));
        }

        return Column(
          children: [
            // Lead Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lead.name, style: AppTextStyles.h2),
                          if (lead.company != null) ...[
                            const SizedBox(height: 2),
                            Text(lead.company!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ],
                      ),
                      Text(
                        CurrencyFormatter.format(lead.dealValue),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Pipeline Status: ', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: lead.status,
                        underline: const SizedBox.shrink(),
                        items: controller.statuses.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: StatusBadge(status: s),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.updateStatus(val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Timeline Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: const [
                  Icon(Icons.timeline, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'ACTIVITY TIMELINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            // History Timeline List
            Expanded(
              child: controller.leadHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'No history logged yet. Add a timeline note below.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.leadHistory.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) {
                        final item = controller.leadHistory[i];
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
                                    item.doneByName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary),
                                  ),
                                  Text(
                                    DateFormatter.toDisplayDateTime(item.doneAt),
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              if (item.action.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.action.replaceAll('_', ' ').toUpperCase(),
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                                ),
                              ],
                              if (item.note != null && item.note!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(item.note!, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Bottom Note Composer
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
                      controller: controller.timelineNoteController,
                      decoration: InputDecoration(
                        hintText: 'Log activity or call note...',
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
                    onPressed: controller.addTimelineNote,
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

