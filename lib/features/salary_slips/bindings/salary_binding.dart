import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/salary_repository.dart';
import '../controllers/salary_controller.dart';

class SalaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalaryRepository>(() => SalaryRepository(Get.find<ApiClient>()));
    Get.lazyPut<SalaryController>(
      () => SalaryController(salaryRepository: Get.find<SalaryRepository>()),
    );
  }
}

