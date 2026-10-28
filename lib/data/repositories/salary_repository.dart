import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/salary_slip_model.dart';

class SalaryRepository {
  final ApiClient _apiClient;

  SalaryRepository(this._apiClient);

  Future<List<SalarySlipSummaryModel>> getSalarySlips() async {
    final response = await _apiClient.request(ApiConstants.actionSalarySlipsList);
    final list = <SalarySlipSummaryModel>[];
    if (response['slips'] is List) {
      for (final item in response['slips']) {
        if (item is Map<String, dynamic>) {
          list.add(SalarySlipSummaryModel.fromJson(item));
        }
      }
    }
    return list;
  }

  Future<SalarySlipDetailModel> getSalarySlipDetail(int id) async {
    final response = await _apiClient.request(
      ApiConstants.actionSalarySlipDetail,
      data: {'id': id},
    );
    final slipMap = response['slip'] as Map<String, dynamic>? ?? {};
    return SalarySlipDetailModel.fromJson(slipMap);
  }
}

