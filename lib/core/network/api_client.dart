import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/storage_service.dart';
import 'api_exceptions.dart';
import 'api_interceptors.dart';

class ApiClient {
  final StorageService _storageService;
  late Dio _dio;

  ApiClient(this._storageService) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.add(ApiInterceptors(_storageService));
  }

  String get _baseUrl {
    String server = _storageService.serverUrl.trim();
    if (!server.startsWith('http://') && !server.startsWith('https://')) {
      server = 'https://$server';
    }
    if (server.endsWith('/')) {
      server = server.substring(0, server.length - 1);
    }
    if (!server.endsWith('/mobile')) {
      server = '$server/mobile';
    }
    return '$server/api.php';
  }

  /// Centralized API request handling all 56 actions
  Future<Map<String, dynamic>> request(
    String action, {
    Map<String, dynamic>? data,
    FormData? formData,
    bool isMultipart = false,
  }) async {
    try {
      final url = _baseUrl;
      final queryParams = {'action': action};

      dynamic requestBody;

      if (isMultipart && formData != null) {
        requestBody = formData;
        // Include token in formData if available
        final token = _storageService.token;
        if (token != null && token.isNotEmpty) {
          formData.fields.add(MapEntry('token', token));
        }
      } else {
        final bodyMap = Map<String, dynamic>.from(data ?? {});
        final token = _storageService.token;
        if (token != null && token.isNotEmpty && !bodyMap.containsKey('token')) {
          bodyMap['token'] = token;
        }
        // In the PHP backend, parameters can be passed as form-data or urlencoded
        requestBody = FormData.fromMap(bodyMap);
      }

      final response = await _dio.post(
        url,
        queryParameters: queryParams,
        data: requestBody,
        options: Options(
          responseType: ResponseType.json,
        ),
      );

      if (response.data is Map<String, dynamic>) {
        final resMap = response.data as Map<String, dynamic>;
        if (resMap['success'] == true) {
          return resMap;
        } else {
          final errorMsg = resMap['error']?.toString() ?? 'Operation failed';
          throw ApiException(message: errorMsg);
        }
      } else if (response.data is String) {
        throw ApiException(message: 'Invalid server response: ${response.data}');
      }

      return {'success': true};
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw ApiException(message: e.message ?? 'Network error occurred');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }

  Dio get rawDio => _dio;
}

