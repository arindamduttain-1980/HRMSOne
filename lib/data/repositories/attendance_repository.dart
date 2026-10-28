import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/attendance_model.dart';
import '../models/user_model.dart';

class AttendanceStatusResult {
  final AttendanceRecord? today;
  final List<AttendanceRecord> history;
  final UserModel? user;

  AttendanceStatusResult({
    this.today,
    required this.history,
    this.user,
  });
}

class AttendanceRepository {
  final ApiClient _apiClient;

  AttendanceRepository(this._apiClient);

  Future<AttendanceStatusResult> getStatus() async {
    final response = await _apiClient.request(ApiConstants.actionAttendanceStatus);

    AttendanceRecord? today;
    if (response['today'] is Map<String, dynamic>) {
      today = AttendanceRecord.fromJson(response['today'] as Map<String, dynamic>);
    }

    final history = <AttendanceRecord>[];
    if (response['history'] is List) {
      for (final item in response['history']) {
        if (item is Map<String, dynamic>) {
          history.add(AttendanceRecord.fromJson(item));
        }
      }
    }

    UserModel? user;
    if (response['user'] is Map<String, dynamic>) {
      user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
    }

    return AttendanceStatusResult(today: today, history: history, user: user);
  }

  Future<Map<String, dynamic>> checkIn({
    String? note,
    double? lat,
    double? lng,
    String? address,
  }) async {
    final data = <String, dynamic>{};
    if (note != null && note.isNotEmpty) data['note'] = note;
    if (lat != null) data['lat'] = lat;
    if (lng != null) data['lng'] = lng;
    if (address != null && address.isNotEmpty) data['address'] = address;

    return await _apiClient.request(ApiConstants.actionCheckIn, data: data);
  }

  Future<Map<String, dynamic>> checkOut({
    double? lat,
    double? lng,
    String? address,
  }) async {
    final data = <String, dynamic>{};
    if (lat != null) data['lat'] = lat;
    if (lng != null) data['lng'] = lng;
    if (address != null && address.isNotEmpty) data['address'] = address;

    return await _apiClient.request(ApiConstants.actionCheckOut, data: data);
  }

  Future<Map<String, dynamic>> markStatus({
    required String status, // half_day or work_from_home
    String? note,
  }) async {
    final data = <String, dynamic>{'status': status};
    if (note != null && note.isNotEmpty) data['note'] = note;

    return await _apiClient.request(ApiConstants.actionMarkStatus, data: data);
  }

  Future<Map<String, dynamic>> earlyLeave({
    String? note,
    double? lat,
    double? lng,
    String? address,
  }) async {
    final data = <String, dynamic>{};
    if (note != null && note.isNotEmpty) data['note'] = note;
    if (lat != null) data['lat'] = lat;
    if (lng != null) data['lng'] = lng;
    if (address != null && address.isNotEmpty) data['address'] = address;

    return await _apiClient.request(ApiConstants.actionEarlyLeave, data: data);
  }
}

