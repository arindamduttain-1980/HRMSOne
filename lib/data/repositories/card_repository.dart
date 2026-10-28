import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/card_data_model.dart';

class CardRepository {
  final ApiClient _apiClient;

  CardRepository(this._apiClient);

  Future<DigitalCardDataModel> getCardData() async {
    final response = await _apiClient.request(ApiConstants.actionCardData);
    return DigitalCardDataModel.fromJson(response);
  }

  Future<String> updateTagline(String tagline) async {
    final response = await _apiClient.request(
      ApiConstants.actionCardUpdateTagline,
      data: {'tagline': tagline},
    );
    return response['message']?.toString() ?? 'Visiting card updated.';
  }

  Future<String> updateSafetyDetails({
    String? bloodGroup,
    String? emergencyName,
    String? emergencyContact,
  }) async {
    final data = <String, dynamic>{};
    if (bloodGroup != null) data['blood_group'] = bloodGroup;
    if (emergencyName != null) data['emergency_name'] = emergencyName;
    if (emergencyContact != null) data['emergency_contact'] = emergencyContact;

    final response = await _apiClient.request(
      ApiConstants.actionCardUpdateSafety,
      data: data,
    );
    return response['message']?.toString() ?? 'ID card updated.';
  }
}

