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

  final Rx<DateTime> selectedMonth = DateTime.now().obs;

  // Editor
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedDate = ''.obs;
  final RxString startTime = '09:00:00'.obs;
  final RxString endTime = '10:00:00'.obs;
  final RxString selectedType = 'personal'.obs;
  final RxString selectedColor = '#1a56db'.obs;
  final RxBool allDay = false.obs;
  final Rx<CalendarEventModel?> editingEvent = Rx<CalendarEventModel?>(null);

  final List<String> eventTypes = ['personal', 'meeting', 'task', 'holiday'];

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now());
    loadEvents();
  }

  String get currentMonthLabel => DateFormat('MMMM yyyy').format(selectedMonth.value);
  String get currentMonthParam => DateFormat('yyyy-MM').format(selectedMonth.value);

  void nextMonth() {
    selectedMonth.value = DateTime(selectedMonth.value.year, selectedMonth.value.month + 1);
    loadEvents();
  }

  void prevMonth() {
    selectedMonth.value = DateTime(selectedMonth.value.year, selectedMonth.value.month - 1);
    loadEvents();
  }

  Future<void> loadEvents() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _calendarRepository.getEvents(month: currentMonthParam);
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
    startTime.value = '09:00:00';
    endTime.value = '10:00:00';
    selectedType.value = 'personal';
    selectedColor.value = '#1a56db';
    allDay.value = false;
  }

  void openEditModal(CalendarEventModel event) {
    editingEvent.value = event;
    titleController.text = event.title;
    descriptionController.text = event.description ?? '';
    selectedDate.value = event.eventDate;
    startTime.value = event.startTime ?? '09:00:00';
    endTime.value = event.endTime ?? '10:00:00';
    selectedType.value = event.type;
    selectedColor.value = event.color;
    allDay.value = event.allDay;
  }

  Future<void> saveEvent() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar('Required', 'Event title cannot be empty', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      if (editingEvent.value == null) {
        await _calendarRepository.createEvent(
          title: title,
          description: descriptionController.text.trim(),
          eventDate: selectedDate.value,
          startTime: startTime.value,
          endTime: endTime.value,
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
          startTime: startTime.value,
          endTime: endTime.value,
          color: selectedColor.value,
          type: selectedType.value,
          allDay: allDay.value,
        );
      }

      Get.back(); // close modal
      await loadEvents();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await _calendarRepository.deleteEvent(id);
      await loadEvents();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}

