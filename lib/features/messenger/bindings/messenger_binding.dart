import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/messenger_repository.dart';
import '../controllers/messenger_controller.dart';

class MessengerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessengerRepository>(() => MessengerRepository(Get.find<ApiClient>()));
    Get.lazyPut<MessengerController>(
      () => MessengerController(
        messengerRepository: Get.find<MessengerRepository>(),
        authService: Get.find<AuthService>(),
      ),
    );
  }
}

