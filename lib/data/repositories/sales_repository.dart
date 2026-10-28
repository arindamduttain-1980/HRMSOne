import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/sales_invoice_model.dart';
import '../models/sales_target_model.dart';

class SalesRepository {
  final ApiClient _apiClient;

  SalesRepository(this._apiClient);

  Future<List<SalesInvoiceSummaryModel>> getInvoices({int? month, int? year}) async {
    final data = <String, dynamic>{};
    if (month != null) data['month'] = month;
    if (year != null) data['year'] = year;

    final response = await _apiClient.request(ApiConstants.actionSalesInvoicesList, data: data);
    final list = <SalesInvoiceSummaryModel>[];
    if (response['invoices'] is List) {
      for (final item in response['invoices']) {
        if (item is Map<String, dynamic>) {
          list.add(SalesInvoiceSummaryModel.fromJson(item));
        }
      }
    }
    return list;
  }

  Future<List<Map<String, int>>> getInvoiceMonths() async {
    final response = await _apiClient.request(ApiConstants.actionSalesInvoiceMonths);
    final list = <Map<String, int>>[];
    if (response['months'] is List) {
      for (final item in response['months']) {
        if (item is Map<String, dynamic>) {
          list.add({
            'year': int.tryParse(item['year']?.toString() ?? '2026') ?? 2026,
            'month': int.tryParse(item['month']?.toString() ?? '1') ?? 1,
          });
        }
      }
    }
    return list;
  }

  Future<SalesInvoiceDetailModel> getInvoiceDetail(int id) async {
    final response = await _apiClient.request(
      ApiConstants.actionSalesInvoiceGet,
      data: {'id': id},
    );
    final itemsList = response['items'] is List ? response['items'] as List : [];
    return SalesInvoiceDetailModel.fromJson(response, itemsList);
  }

  Future<SalesTargetModel> getSalesTarget({int? month, int? year}) async {
    final data = <String, dynamic>{};
    if (month != null) data['month'] = month;
    if (year != null) data['year'] = year;

    final response = await _apiClient.request(ApiConstants.actionSalesTargetGet, data: data);
    return SalesTargetModel.fromJson(response);
  }

  Future<List<SalesTargetModel>> getSalesTargetHistory() async {
    final response = await _apiClient.request(ApiConstants.actionSalesTargetHistory);
    final list = <SalesTargetModel>[];
    if (response['history'] is List) {
      for (final item in response['history']) {
        if (item is Map<String, dynamic>) {
          list.add(SalesTargetModel.fromJson(item));
        }
      }
    }
    return list;
  }
}

