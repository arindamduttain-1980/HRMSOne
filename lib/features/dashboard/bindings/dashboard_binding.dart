import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/location_service.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceRepository>(() => AttendanceRepository(Get.find<ApiClient>()));
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        attendanceRepository: Get.find<AttendanceRepository>(),
        authService: Get.find<AuthService>(),
        locationService: Get.find<LocationService>(),
      ),
    );
  }
}

