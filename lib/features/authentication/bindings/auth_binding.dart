import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/face_storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/company_repository.dart';
import '../../../data/repositories/face_repository.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CompanyRepository>()) {
      Get.lazyPut<CompanyRepository>(() => CompanyRepository());
    }
    if (!Get.isRegistered<FaceStorageService>()) {
      Get.lazyPut<FaceStorageService>(() => FaceStorageService());
    }
    if (!Get.isRegistered<FaceRepository>()) {
      Get.lazyPut<FaceRepository>(() => FaceRepository(Get.find<ApiClient>()));
    }
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<ApiClient>()));
    Get.lazyPut<AuthController>(
      () => AuthController(
        authRepository: Get.find<AuthRepository>(),
        authService: Get.find<AuthService>(),
        storageService: Get.find<StorageService>(),
        companyRepository: Get.find<CompanyRepository>(),
        faceStorageService: Get.find<FaceStorageService>(),
        faceRepository: Get.find<FaceRepository>(),
      ),
    );
  }
}
