import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/leave_model.dart';

class LeaveRepository {
  final ApiClient _apiClient;

  LeaveRepository(this._apiClient);

  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    final response = await _apiClient.request(ApiConstants.actionLeaveTypesList);
    final list = <LeaveTypeModel>[];
    if (response['leave_types'] is List) {
      for (final item in response['leave_types']) {
        if (item is Map<String, dynamic>) {
          list.add(LeaveTypeModel.fromJson(item));
        }
      }
    }
    return list;
  }

  Future<List<LeaveApplicationModel>> getLeaves() async {
    final response = await _apiClient.request(ApiConstants.actionLeavesList);
    final list = <LeaveApplicationModel>[];
    if (response['leaves'] is List) {
      for (final item in response['leaves']) {
        if (item is Map<String, dynamic>) {
          list.add(LeaveApplicationModel.fromJson(item));
        }
      }
    }
    return list;
  }

  Future<Map<String, dynamic>> applyLeave({
    required int leaveTypeId,
    required String fromDate,
    required String toDate,
    required String reason,
  }) async {
    final data = {
      'leave_type_id': leaveTypeId,
      'from_date': fromDate,
      'to_date': toDate,
      'reason': reason,
    };
    return await _apiClient.request(ApiConstants.actionLeavesApply, data: data);
  }

  Future<String> cancelLeave(int id) async {
    final response = await _apiClient.request(
      ApiConstants.actionLeavesCancel,
      data: {'id': id},
    );
    return response['message']?.toString() ?? 'Leave application cancelled.';
  }
}

