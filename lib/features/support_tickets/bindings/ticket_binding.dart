import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/ticket_repository.dart';
import '../controllers/ticket_controller.dart';

class TicketBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TicketRepository>(() => TicketRepository(Get.find<ApiClient>()));
    Get.lazyPut<TicketController>(
      () => TicketController(ticketRepository: Get.find<TicketRepository>()),
    );
  }
}

