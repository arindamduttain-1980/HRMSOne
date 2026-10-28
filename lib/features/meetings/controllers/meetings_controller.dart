import 'package:get/get.dart';
import '../../../data/models/meeting_model.dart';
import '../../../data/repositories/meeting_repository.dart';

class MeetingsController extends GetxController {
  final MeetingRepository _meetingRepository;

  MeetingsController({required MeetingRepository meetingRepository})
      : _meetingRepository = meetingRepository;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<MeetingModel> meetings = <MeetingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMeetings();
  }

  Future<void> loadMeetings() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final list = await _meetingRepository.getMeetings();
      list.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
      meetings.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

