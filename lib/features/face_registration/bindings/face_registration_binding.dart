import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/face_storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/face_repository.dart';
import '../controllers/face_registration_controller.dart';

class FaceRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FaceStorageService>()) {
      Get.lazyPut<FaceStorageService>(() => FaceStorageService());
    }
    if (!Get.isRegistered<FaceRepository>()) {
      Get.lazyPut<FaceRepository>(() => FaceRepository(Get.find<ApiClient>()));
    }
    Get.lazyPut<FaceRegistrationController>(
      () => FaceRegistrationController(
        authService: Get.find<AuthService>(),
        faceStorageService: Get.find<FaceStorageService>(),
        faceRepository: Get.find<FaceRepository>(),
      ),
    );
  }
}

