import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/task_repository.dart';
import '../controllers/task_controller.dart';

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskRepository>(() => TaskRepository(Get.find<ApiClient>()));
    Get.lazyPut<TaskController>(
      () => TaskController(taskRepository: Get.find<TaskRepository>()),
    );
  }
}

