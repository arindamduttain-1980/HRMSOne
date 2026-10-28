import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../data/repositories/notice_repository.dart';
import '../controllers/notice_controller.dart';

class NoticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NoticeRepository>(() => NoticeRepository(Get.find<ApiClient>()));
    Get.lazyPut<NoticeController>(
      () => NoticeController(noticeRepository: Get.find<NoticeRepository>()),
    );
  }
}

