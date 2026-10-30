import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/face_storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../controllers/face_verification_controller.dart';

class FaceVerificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FaceStorageService>()) {
      Get.lazyPut<FaceStorageService>(() => FaceStorageService());
    }
    if (!Get.isRegistered<AttendanceRepository>()) {
      Get.lazyPut<AttendanceRepository>(() => AttendanceRepository(Get.find<ApiClient>()));
    }
    Get.lazyPut<FaceVerificationController>(
      () => FaceVerificationController(
        authService: Get.find<AuthService>(),
        faceStorageService: Get.find<FaceStorageService>(),
        attendanceRepository: Get.find<AttendanceRepository>(),
      ),
    );
  }
}

