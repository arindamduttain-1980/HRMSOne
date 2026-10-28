import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/notice_model.dart';

class NoticeRepository {
  final ApiClient _apiClient;

  NoticeRepository(this._apiClient);

  Future<List<NoticeModel>> getNotices() async {
    final response = await _apiClient.request(ApiConstants.actionNoticesList);
    final notices = <NoticeModel>[];
    if (response['notices'] is List) {
      for (final item in response['notices']) {
        if (item is Map<String, dynamic>) {
          notices.add(NoticeModel.fromJson(item));
        }
      }
    }
    return notices;
  }

  Future<String> markNoticeRead(int noticeId) async {
    final response = await _apiClient.request(
      ApiConstants.actionNoticeMarkRead,
      data: {'notice_id': noticeId},
    );
    return response['message']?.toString() ?? 'Marked as read.';
  }
}

