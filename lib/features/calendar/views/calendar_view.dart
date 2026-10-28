import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../data/models/calendar_event_model.dart';
import '../controllers/calendar_controller.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Web background var(--bg)
      appBar: AppBar(
        backgroundColor: AppColors.navyDark, // Web navy header
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Calendar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: controller.loadEvents,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          controller.openCreateModal();
          _showEventEditorSheet(context);
        },
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
      body: Obx(() {
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
            title: 'No Upcoming Events',
            message: 'No upcoming events. Tap + to add one.',
            buttonText: 'Add Event',
            onButtonPressed: () {
              controller.openCreateModal();
              _showEventEditorSheet(context);
            },
          );
        }

        final groups = controller.groupedEvents;

        return RefreshIndicator(
          onRefresh: controller.loadEvents,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 90),
            itemCount: groups.keys.length,
            itemBuilder: (ctx, i) {
              final dateKey = groups.keys.elementAt(i);
              final dayEvents = groups[dateKey]!;
              return _buildDayGroup(context, dateKey, dayEvents);
            },
          ),
        );
      }),
    );
  }

  /// Builds a grouped day section (e.g. WED, 28 OCT) matching web .cal-day-group
  Widget _buildDayGroup(BuildContext context, String dateKey, List<CalendarEventModel> dayEvents) {
    String label = dateKey;
    try {
      final dt = DateTime.parse(dateKey);
      label = DateFormat('EEE, d MMM').format(dt).toUpperCase();
    } catch (_) {
      label = dateKey.toUpperCase();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...dayEvents.map((event) => _buildEventItem(context, event)),
      ],
    );
  }

  /// Builds an individual event card matching web .event-item
  Widget _buildEventItem(BuildContext context, CalendarEventModel event) {
    Color barColor;
    try {
      final clean = event.color.replaceAll('#', '');
      barColor = Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      barColor = AppColors.primary;
    }

    String timeStr;
    if (event.allDay) {
      timeStr = 'All day';
    } else {
      final parts = [event.startTime, event.endTime]
          .where((t) => t != null && t.isNotEmpty)
          .map((t) => t!.substring(0, t.length >= 5 ? 5 : t.length))
          .toList();
      timeStr = parts.isNotEmpty ? parts.join(' - ') : 'Time not set';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            controller.openEditModal(event);
            _showEventEditorSheet(context);
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored Vertical Indicator Bar
                Container(
                  width: 5,
                  height: 52,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                // Event Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (event.description != null && event.description!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          event.description!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          event.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Displays the New / Edit Event bottom sheet matching the web modal in Image 3
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
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Modal Title & Circular Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        controller.editingEvent.value == null ? 'New Event' : 'Edit Event',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      )),
                  InkWell(
                    onTap: () => Navigator.pop(ctx),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 1. Event Title
              TextField(
                controller: controller.titleController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Event title',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Description (optional)
              TextField(
                controller: controller.descriptionController,
                maxLines: 2,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Date Picker Field (displays e.g. 28-10-2026 with calendar icon)
              Obx(() {
                String displayDate = controller.selectedDate.value;
                try {
                  final dt = DateTime.parse(controller.selectedDate.value);
                  displayDate = DateFormat('dd-MM-yyyy').format(dt);
                } catch (_) {}

                return InkWell(
                  onTap: () async {
                    DateTime init = DateTime.now();
                    try {
                      init = DateTime.parse(controller.selectedDate.value);
                    } catch (_) {}

                    final picked = await showDatePicker(
                      context: context,
                      initialDate: init,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      controller.selectedDate.value = DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayDate.isEmpty ? 'Select Date' : displayDate,
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        ),
                        const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),

              // 4. All-day event Checkbox
              Obx(() => Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: controller.allDay.value,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => controller.allDay.value = val ?? false,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => controller.allDay.value = !controller.allDay.value,
                        child: const Text(
                          'All-day event',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 12),

              // 5. Start Time & End Time Row
              // Hidden when allDay is checked; visible when allDay is unchecked
              Obx(() {
                if (controller.allDay.value) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // Start Time
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _parseTime(controller.startTime.value),
                            );
                            if (picked != null) {
                              final h = picked.hour.toString().padLeft(2, '0');
                              final m = picked.minute.toString().padLeft(2, '0');
                              controller.startTime.value = '$h:$m';
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  controller.startTime.value.isEmpty ? '--:--' : controller.startTime.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: controller.startTime.value.isEmpty
                                        ? AppColors.textMuted
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // End Time
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _parseTime(controller.endTime.value),
                            );
                            if (picked != null) {
                              final h = picked.hour.toString().padLeft(2, '0');
                              final m = picked.minute.toString().padLeft(2, '0');
                              controller.endTime.value = '$h:$m';
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  controller.endTime.value.isEmpty ? '--:--' : controller.endTime.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: controller.endTime.value.isEmpty
                                        ? AppColors.textMuted
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // 6. Event Type Dropdown (Personal, Meeting, Task, Reminder, Holiday, Deadline)
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedType.value,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                        items: CalendarController.eventTypeOptions.map((opt) {
                          return DropdownMenuItem<String>(
                            value: opt['value'],
                            child: Text(
                              opt['label']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.selectedType.value = val;
                        },
                      ),
                    ),
                  )),
              const SizedBox(height: 14),

              // 7. Color Swatches (7 pastel circles from web app)
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: CalendarController.eventColors.map((colorHex) {
                      Color c;
                      try {
                        final clean = colorHex.replaceAll('#', '');
                        c = Color(int.parse('FF$clean', radix: 16));
                      } catch (_) {
                        c = AppColors.primary;
                      }
                      final isSelected = controller.selectedColor.value.toLowerCase() == colorHex.toLowerCase();

                      return GestureDetector(
                        onTap: () => controller.selectedColor.value = colorHex,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: isSelected ? 2.5 : 1,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: isSelected
                              ? const Center(
                                  child: Icon(Icons.check, size: 16, color: AppColors.textPrimary),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  )),
              const SizedBox(height: 20),

              // 8. Action Buttons (Delete + Save)
              Row(
                children: [
                  Obx(() {
                    if (controller.editingEvent.value == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () {
                          final id = controller.editingEvent.value!.id;
                          Navigator.pop(ctx);
                          controller.deleteEvent(id);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline, color: AppColors.danger, size: 22),
                        ),
                      ),
                    );
                  }),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0891B2), // Web save button blue
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            'Save',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
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

  static TimeOfDay _parseTime(String time) {
    if (time.isEmpty) return const TimeOfDay(hour: 9, minute: 0);
    try {
      final parts = time.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return TimeOfDay(hour: h, minute: m);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }
}
