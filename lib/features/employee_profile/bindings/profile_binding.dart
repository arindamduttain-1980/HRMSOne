import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/profile_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(() => ProfileRepository(Get.find<ApiClient>()));
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        profileRepository: Get.find<ProfileRepository>(),
        authService: Get.find<AuthService>(),
        storageService: Get.find<StorageService>(),
      ),
    );
  }
}

