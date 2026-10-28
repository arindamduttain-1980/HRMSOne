import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<String> uploadPhoto(String filePath) async {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _apiClient.request(
      ApiConstants.actionProfilePhotoUpload,
      formData: formData,
      isMultipart: true,
    );

    return response['photo_url']?.toString() ?? '';
  }

  Future<String> removePhoto() async {
    final response = await _apiClient.request(ApiConstants.actionProfilePhotoRemove);
    return response['message']?.toString() ?? 'Profile photo removed.';
  }
}

