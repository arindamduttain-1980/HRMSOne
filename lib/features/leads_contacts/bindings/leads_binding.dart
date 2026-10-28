import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/crm_repository.dart';
import '../controllers/leads_controller.dart';

class LeadsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CrmRepository>(() => CrmRepository(Get.find<ApiClient>()));
    Get.lazyPut<LeadsController>(
      () => LeadsController(crmRepository: Get.find<CrmRepository>()),
    );
  }
}

