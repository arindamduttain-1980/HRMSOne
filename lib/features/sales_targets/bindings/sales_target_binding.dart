import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/sales_repository.dart';
import '../controllers/sales_target_controller.dart';

class SalesTargetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SalesRepository>(() => SalesRepository(Get.find<ApiClient>()));
    Get.lazyPut<SalesTargetController>(
      () => SalesTargetController(salesRepository: Get.find<SalesRepository>()),
    );
  }
}

