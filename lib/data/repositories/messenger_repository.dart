import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/chat_model.dart';

class MessengerRepository {
  final ApiClient _apiClient;

  MessengerRepository(this._apiClient);

  Future<List<ChatGroupModel>> getGroups() async {
    final response = await _apiClient.request(ApiConstants.actionMessengerGroups);
    final list = <ChatGroupModel>[];
    if (response['groups'] is List) {
      for (final item in response['groups']) {
        if (item is Map<String, dynamic>) {
          list.add(ChatGroupModel.fromJson(item));
        }
      }
    }
    return list;
  }

  Future<List<ChatMessageModel>> getMessages(int groupId) async {
    final response = await _apiClient.request(
      ApiConstants.actionMessengerMessages,
      data: {'group_id': groupId},
    );
    final list = <ChatMessageModel>[];
    if (response['messages'] is List) {
      for (final item in response['messages']) {
        if (item is Map<String, dynamic>) {
          list.add(ChatMessageModel.fromJson(item));
        }
      }
    }
    return list;
  }

  Future<int> sendMessage(int groupId, String message) async {
    final response = await _apiClient.request(
      ApiConstants.actionMessengerSend,
      data: {
        'group_id': groupId,
        'message': message,
      },
    );
    return response['id'] is int ? response['id'] : int.tryParse(response['id']?.toString() ?? '0') ?? 0;
  }
}

