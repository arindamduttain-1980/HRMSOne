import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/leave_repository.dart';
import '../controllers/leave_controller.dart';

class LeaveBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaveRepository>(() => LeaveRepository(Get.find<ApiClient>()));
    Get.lazyPut<LeaveController>(
      () => LeaveController(leaveRepository: Get.find<LeaveRepository>()),
    );
  }
}

