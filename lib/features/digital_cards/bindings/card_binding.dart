import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/card_repository.dart';
import '../controllers/card_controller.dart';

class CardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CardRepository>(() => CardRepository(Get.find<ApiClient>()));
    Get.lazyPut<CardController>(
      () => CardController(cardRepository: Get.find<CardRepository>()),
    );
  }
}

