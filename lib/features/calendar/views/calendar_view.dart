import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../data/models/calendar_event_model.dart';
import '../controllers/calendar_controller.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadEvents,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          controller.openCreateModal();
          _showEventEditorSheet(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Month Selector Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: controller.prevMonth,
                ),
                Obx(() => Text(
                      controller.currentMonthLabel,
                      style: AppTextStyles.h3,
                    )),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: controller.nextMonth,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Events List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return ErrorStateView(
                  error: controller.errorMessage.value,
                  onRetry: controller.loadEvents,
                );
              }

              if (controller.events.isEmpty) {
                return EmptyStateView(
                  icon: Icons.calendar_today_outlined,
                  title: 'No Events Scheduled',
                  message: 'No events or meetings found for this month.',
                  buttonText: 'Add Event',
                  onButtonPressed: () {
                    controller.openCreateModal();
                    _showEventEditorSheet(context);
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadEvents,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final event = controller.events[i];
                    return _buildEventCard(context, event);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, CalendarEventModel event) {
    Color cardColor;
    try {
      final clean = event.color.replaceAll('#', '');
      cardColor = Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      cardColor = AppColors.primary;
    }

    return InkWell(
      onTap: () {
        controller.openEditModal(event);
        _showEventEditorSheet(context);
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (event.description != null && event.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      event.description!,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.toDisplayDate(event.eventDate),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        event.allDay
                            ? 'All Day'
                            : '${DateFormatter.toDisplayTime(event.startTime)} - ${DateFormatter.toDisplayTime(event.endTime)}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventEditorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                  Obx(() => Text(
                        controller.editingEvent.value == null ? 'New Event' : 'Edit Event',
                        style: AppTextStyles.h3,
                      )),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  hintText: 'Event Title',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: AppColors.inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Date Picker
              Obx(() => InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.tryParse(controller.selectedDate.value) ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        controller.selectedDate.value = DateFormat('yyyy-MM-dd').format(picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            DateFormatter.toDisplayDate(controller.selectedDate.value),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 12),

              // All Day Toggle
              Obx(() => SwitchListTile(
                    title: const Text('All Day Event', style: TextStyle(fontSize: 14)),
                    value: controller.allDay.value,
                    onChanged: (val) => controller.allDay.value = val,
                    contentPadding: EdgeInsets.zero,
                  )),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Obx(() {
                    if (controller.editingEvent.value == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.dangerLight,
                          padding: const EdgeInsets.all(14),
                        ),
                        icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                        onPressed: () {
                          final id = controller.editingEvent.value!.id;
                          Navigator.pop(ctx);
                          controller.deleteEvent(id);
                        },
                      ),
                    );
                  }),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Event', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

