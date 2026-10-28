import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/meeting_repository.dart';
import '../controllers/meetings_controller.dart';

class MeetingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeetingRepository>(() => MeetingRepository(Get.find<ApiClient>()));
    Get.lazyPut<MeetingsController>(
      () => MeetingsController(meetingRepository: Get.find<MeetingRepository>()),
    );
  }
}

