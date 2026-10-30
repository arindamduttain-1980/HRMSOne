import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/storage/storage_service.dart';
import '../../../data/repositories/company_repository.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CompanyRepository>()) {
      Get.lazyPut<CompanyRepository>(() => CompanyRepository());
    }
    Get.lazyPut<SplashController>(
      () => SplashController(
        companyRepository: Get.find<CompanyRepository>(),
        storageService: Get.find<StorageService>(),
        authService: Get.find<AuthService>(),
      ),
    );
  }
}

