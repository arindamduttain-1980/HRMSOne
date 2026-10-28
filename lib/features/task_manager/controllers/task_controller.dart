import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/task_model.dart';
import '../../../data/repositories/task_repository.dart';

class TaskController extends GetxController {
  final TaskRepository _taskRepository;

  TaskController({required TaskRepository taskRepository})
      : _taskRepository = taskRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<TaskModel> allTasks = <TaskModel>[].obs;
  final RxString selectedFilter = 'all'.obs;

  // Editor
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final categoryController = TextEditingController();
  final RxString selectedPriority = 'medium'.obs;
  final RxString selectedDueDate = ''.obs;
  final RxString selectedStatus = 'todo'.obs;
  final Rx<TaskModel?> editingTask = Rx<TaskModel?>(null);

  final List<String> priorities = ['low', 'medium', 'high', 'urgent'];
  final List<String> statuses = ['todo', 'in_progress', 'review', 'done', 'cancelled'];

  @override
  void onInit() {
    super.onInit();
    selectedDueDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 3)));
    loadTasks();
  }

  List<TaskModel> get filteredTasks {
    if (selectedFilter.value == 'all') return allTasks;
    return allTasks.where((t) => t.status.toLowerCase() == selectedFilter.value).toList();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  Future<void> loadTasks() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _taskRepository.getTasks();
      allTasks.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void openCreateModal() {
    editingTask.value = null;
    titleController.clear();
    descriptionController.clear();
    categoryController.clear();
    selectedPriority.value = 'medium';
    selectedStatus.value = 'todo';
    selectedDueDate.value = DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 3)));
  }

  void openEditModal(TaskModel task) {
    editingTask.value = task;
    titleController.text = task.title;
    descriptionController.text = task.description ?? '';
    categoryController.text = task.category ?? '';
    selectedPriority.value = task.priority;
    selectedStatus.value = task.status;
    selectedDueDate.value = task.dueDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> saveTask() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar('Required', 'Task title cannot be empty', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      if (editingTask.value == null) {
        await _taskRepository.createTask(
          title: title,
          description: descriptionController.text.trim(),
          priority: selectedPriority.value,
          category: categoryController.text.trim().isNotEmpty ? categoryController.text.trim() : null,
          dueDate: selectedDueDate.value,
        );
      } else {
        await _taskRepository.updateTask(
          id: editingTask.value!.id,
          title: title,
          description: descriptionController.text.trim(),
          priority: selectedPriority.value,
          category: categoryController.text.trim().isNotEmpty ? categoryController.text.trim() : null,
          dueDate: selectedDueDate.value,
          status: selectedStatus.value,
        );
      }

      Get.back();
      await loadTasks();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateStatus(TaskModel task, String newStatus) async {
    try {
      await _taskRepository.updateTaskStatus(id: task.id, status: newStatus);
      await loadTasks();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await _taskRepository.deleteTask(id);
      await loadTasks();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    super.onClose();
  }
}

