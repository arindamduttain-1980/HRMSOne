import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/task_model.dart';

class TaskRepository {
  final ApiClient _apiClient;

  TaskRepository(this._apiClient);

  Future<List<TaskModel>> getTasks() async {
    final response = await _apiClient.request(ApiConstants.actionTasksList);
    final tasks = <TaskModel>[];
    if (response['tasks'] is List) {
      for (final item in response['tasks']) {
        if (item is Map<String, dynamic>) {
          tasks.add(TaskModel.fromJson(item));
        }
      }
    }
    return tasks;
  }

  Future<Map<String, dynamic>> createTask({
    required String title,
    String? description,
    String priority = 'medium',
    String? category,
    String? dueDate,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'priority': priority,
    };
    if (description != null) data['description'] = description;
    if (category != null) data['category'] = category;
    if (dueDate != null) data['due_date'] = dueDate;

    return await _apiClient.request(ApiConstants.actionTasksCreate, data: data);
  }

  Future<String> updateTask({
    required int id,
    required String title,
    String? description,
    String? priority,
    String? category,
    String? dueDate,
    String? status,
  }) async {
    final data = <String, dynamic>{
      'id': id,
      'title': title,
    };
    if (description != null) data['description'] = description;
    if (priority != null) data['priority'] = priority;
    if (category != null) data['category'] = category;
    if (dueDate != null) data['due_date'] = dueDate;
    if (status != null) data['status'] = status;

    final response = await _apiClient.request(ApiConstants.actionTasksUpdate, data: data);
    return response['message']?.toString() ?? 'Task updated.';
  }

  Future<String> updateTaskStatus({
    required int id,
    required String status,
  }) async {
    final response = await _apiClient.request(
      ApiConstants.actionTasksUpdateStatus,
      data: {'id': id, 'status': status},
    );
    return response['message']?.toString() ?? 'Task updated.';
  }

  Future<String> deleteTask(int id) async {
    final response = await _apiClient.request(
      ApiConstants.actionTasksDelete,
      data: {'id': id},
    );
    return response['message']?.toString() ?? 'Task deleted.';
  }
}

