import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/calendar_repository.dart';
import '../controllers/calendar_controller.dart';

class CalendarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalendarRepository>(() => CalendarRepository(Get.find<ApiClient>()));
    Get.lazyPut<CalendarController>(
      () => CalendarController(calendarRepository: Get.find<CalendarRepository>()),
    );
  }
}

