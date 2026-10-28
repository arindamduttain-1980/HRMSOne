import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/meeting_model.dart';

class MeetingRepository {
  final ApiClient _apiClient;

  MeetingRepository(this._apiClient);

  Future<List<MeetingModel>> getMeetings() async {
    final response = await _apiClient.request(ApiConstants.actionMeetingsList);
    final list = <MeetingModel>[];
    if (response['meetings'] is List) {
      for (final item in response['meetings']) {
        if (item is Map<String, dynamic>) {
          list.add(MeetingModel.fromJson(item));
        }
      }
    }
    return list;
  }
}

