import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/company_model.dart';

class CompanyRepository {
  final Dio _dio;

  CompanyRepository({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 10),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  Future<List<CompanyModel>> getCompanyList() async {
    try {
      final response = await _dio.get(ApiConstants.companyListUrl);

      if (response.statusCode == 200 && response.data != null) {
        final dynamic data = response.data;
        List<dynamic>? companyJsonList;

        if (data is Map<String, dynamic> && data['companies'] is List) {
          companyJsonList = data['companies'] as List<dynamic>;
        } else if (data is List) {
          companyJsonList = data;
        }

        if (companyJsonList != null) {
          return companyJsonList
              .whereType<Map<String, dynamic>>()
              .map((item) => CompanyModel.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}

