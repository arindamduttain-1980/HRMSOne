import 'package:get/get.dart';
import '../../../data/models/notice_model.dart';
import '../../../data/repositories/notice_repository.dart';

class NoticeController extends GetxController {
  final NoticeRepository _noticeRepository;

  NoticeController({required NoticeRepository noticeRepository})
      : _noticeRepository = noticeRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<NoticeModel> notices = <NoticeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadNotices();
  }

  Future<void> loadNotices() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _noticeRepository.getNotices();
      // Pinned notices on top
      list.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
      notices.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(NoticeModel notice) async {
    if (notice.isRead) return;

    try {
      await _noticeRepository.markNoticeRead(notice.id);
      final idx = notices.indexWhere((n) => n.id == notice.id);
      if (idx != -1) {
        notices[idx] = notice.copyWith(isRead: true);
      }
    } catch (_) {
      // Non-critical, ignore
    }
  }
}
