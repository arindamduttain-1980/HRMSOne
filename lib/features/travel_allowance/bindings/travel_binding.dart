import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/travel_repository.dart';
import '../controllers/travel_controller.dart';

class TravelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TravelRepository>(() => TravelRepository(Get.find<ApiClient>()));
    Get.lazyPut<TravelController>(
      () => TravelController(travelRepository: Get.find<TravelRepository>()),
    );
  }
}

