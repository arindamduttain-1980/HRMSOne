import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';
import '../models/attendance_model.dart';

class LoginResult {
  final String token;
  final UserModel user;
  final AttendanceRecord? attendance;
  final int face;

  LoginResult({
    required this.token,
    required this.user,
    this.attendance,
    this.face = 0,
  });
}

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<LoginResult> login({
    required String email,
    required String password,
    String device = 'Android',
  }) async {
    final response = await _apiClient.request(
      ApiConstants.actionLogin,
      data: {
        'email': email,
        'password': password,
        'device': device,
      },
    );

    final token = response['token']?.toString() ?? '';
    final userJson = response['user'] as Map<String, dynamic>? ?? {};
    final user = UserModel.fromJson(userJson);

    final rawFace = response['face'] ?? userJson['face'];
    final int face = rawFace is int ? rawFace : int.tryParse(rawFace?.toString() ?? '0') ?? user.face;

    AttendanceRecord? attendance;
    if (response['attendance'] is Map<String, dynamic>) {
      attendance = AttendanceRecord.fromJson(response['attendance'] as Map<String, dynamic>);
    }

    return LoginResult(
      token: token,
      user: user,
      attendance: attendance,
      face: face,
    );
  }

  Future<String> logout() async {
    final response = await _apiClient.request(ApiConstants.actionLogout);
    return response['message']?.toString() ?? 'Logged out.';
  }
}
