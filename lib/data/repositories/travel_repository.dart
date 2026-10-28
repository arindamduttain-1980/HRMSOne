import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/travel_claim_model.dart';

class TravelRepository {
  final ApiClient _apiClient;

  TravelRepository(this._apiClient);

  Future<List<TravelClaimModel>> getClaims() async {
    final response = await _apiClient.request(ApiConstants.actionTravelList);
    final list = <TravelClaimModel>[];
    if (response['claims'] is List) {
      for (final item in response['claims']) {
        if (item is Map<String, dynamic>) {
          list.add(TravelClaimModel.fromJson(item));
        }
      }
    }
    return list;
  }

  Future<Map<String, dynamic>> applyClaim({
    required String travelDate,
    required String fromPlace,
    required String toPlace,
    required String purpose,
    String travelType = 'local',
    String mode = 'own_vehicle',
    double? distanceKm,
    double? ticketAmount,
    double? otherExpense,
    bool isReturn = false,
    String? returnDate,
    int? outstationDays,
    double? dailyAllowance,
    double? hotelExpense,
    double? foodExpense,
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'travel_date': travelDate,
      'from_place': fromPlace,
      'to_place': toPlace,
      'purpose': purpose,
      'travel_type': travelType,
      'mode': mode,
      'is_return': isReturn ? 1 : 0,
    };
    if (distanceKm != null) data['distance_km'] = distanceKm;
    if (ticketAmount != null) data['ticket_amount'] = ticketAmount;
    if (otherExpense != null) data['other_expense'] = otherExpense;
    if (returnDate != null) data['return_date'] = returnDate;
    if (outstationDays != null) data['outstation_days'] = outstationDays;
    if (dailyAllowance != null) data['daily_allowance'] = dailyAllowance;
    if (hotelExpense != null) data['hotel_expense'] = hotelExpense;
    if (foodExpense != null) data['food_expense'] = foodExpense;
    if (notes != null) data['notes'] = notes;

    return await _apiClient.request(ApiConstants.actionTravelApply, data: data);
  }

  Future<String> cancelClaim(int id) async {
    final response = await _apiClient.request(
      ApiConstants.actionTravelCancel,
      data: {'id': id},
    );
    return response['message']?.toString() ?? 'Travel allowance claim cancelled.';
  }
}

