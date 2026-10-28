import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/calendar_event_model.dart';
import '../../../data/repositories/calendar_repository.dart';

class CalendarController extends GetxController {
  final CalendarRepository _calendarRepository;

  CalendarController({required CalendarRepository calendarRepository})
      : _calendarRepository = calendarRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<CalendarEventModel> events = <CalendarEventModel>[].obs;

  // Editor controllers & reactive states
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedDate = ''.obs;
  final RxString startTime = ''.obs;
  final RxString endTime = ''.obs;
  final RxString selectedType = 'personal'.obs;
  final RxString selectedColor = '#fef08a'.obs;
  final RxBool allDay = false.obs;
  final Rx<CalendarEventModel?> editingEvent = Rx<CalendarEventModel?>(null);

  // Dropdown options matching web application
  static const List<Map<String, String>> eventTypeOptions = [
    {'value': 'personal', 'label': 'Personal'},
    {'value': 'meeting', 'label': 'Meeting'},
    {'value': 'task', 'label': 'Task'},
    {'value': 'reminder', 'label': 'Reminder'},
    {'value': 'holiday', 'label': 'Holiday'},
    {'value': 'deadline', 'label': 'Deadline'},
  ];

  // Palette matching web application NOTE_COLORS swatches
  static const List<String> eventColors = [
    '#fef08a', // light yellow
    '#bbf7d0', // light green
    '#bfdbfe', // light blue
    '#fecaca', // light pink/red
    '#fde68a', // pastel amber
    '#e9d5ff', // pastel lavender
    '#fbcfe8', // pastel pink
  ];

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    loadEvents();
  }

  /// Groups events by date, ordered chronologically
  Map<String, List<CalendarEventModel>> get groupedEvents {
    final groups = <String, List<CalendarEventModel>>{};
    final sorted = List<CalendarEventModel>.from(events)
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    for (final e in sorted) {
      if (e.eventDate.isEmpty) continue;
      groups.putIfAbsent(e.eventDate, () => []).add(e);
    }
    return groups;
  }

  /// Fetches events from server without month query parameter to match web behavior
  /// and avoid backend collation mismatch
  Future<void> loadEvents() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _calendarRepository.getEvents();
      list.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      events.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void openCreateModal() {
    editingEvent.value = null;
    titleController.clear();
    descriptionController.clear();
    selectedDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    startTime.value = '';
    endTime.value = '';
    selectedType.value = 'personal';
    selectedColor.value = eventColors[0];
    allDay.value = false;
  }

  void openEditModal(CalendarEventModel event) {
    editingEvent.value = event;
    titleController.text = event.title;
    descriptionController.text = event.description ?? '';
    selectedDate.value = event.eventDate.isNotEmpty
        ? event.eventDate
        : DateFormat('yyyy-MM-dd').format(DateTime.now());
    startTime.value = (event.startTime != null && event.startTime!.length >= 5)
        ? event.startTime!.substring(0, 5)
        : (event.startTime ?? '');
    endTime.value = (event.endTime != null && event.endTime!.length >= 5)
        ? event.endTime!.substring(0, 5)
        : (event.endTime ?? '');
    final typeLower = event.type.toLowerCase();
    selectedType.value = eventTypeOptions.any((opt) => opt['value'] == typeLower)
        ? typeLower
        : 'personal';
    selectedColor.value = event.color.isNotEmpty ? event.color : eventColors[0];
    allDay.value = event.allDay;
  }

  Future<void> saveEvent() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Required',
        'Enter an event title.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (selectedDate.value.isEmpty) {
      Get.snackbar(
        'Required',
        'Pick a date for the event.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      if (editingEvent.value == null) {
        await _calendarRepository.createEvent(
          title: title,
          description: descriptionController.text.trim(),
          eventDate: selectedDate.value,
          startTime: allDay.value ? null : startTime.value,
          endTime: allDay.value ? null : endTime.value,
          color: selectedColor.value,
          type: selectedType.value,
          allDay: allDay.value,
        );
      } else {
        await _calendarRepository.updateEvent(
          id: editingEvent.value!.id,
          title: title,
          description: descriptionController.text.trim(),
          eventDate: selectedDate.value,
          startTime: allDay.value ? null : startTime.value,
          endTime: allDay.value ? null : endTime.value,
          color: selectedColor.value,
          type: selectedType.value,
          allDay: allDay.value,
        );
      }

      Get.back(); // close modal
      await loadEvents();
      Get.snackbar(
        'Success',
        editingEvent.value == null ? 'Event saved.' : 'Event updated.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await _calendarRepository.deleteEvent(id);
      await loadEvents();
      Get.snackbar(
        'Success',
        'Event deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
