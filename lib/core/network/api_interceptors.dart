import 'package:dio/dio.dart';
import 'package:get/get.dart' as gx;
import '../storage/storage_service.dart';
import '../routes/app_routes.dart';
import 'api_exceptions.dart';

class ApiInterceptors extends Interceptor {
  final StorageService _storageService;

  ApiInterceptors(this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storageService.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map['success'] == false) {
        final error = map['error']?.toString() ?? 'An error occurred';
        if (error.toLowerCase().contains('unauthorized') ||
            error.toLowerCase().contains('expired') ||
            error.toLowerCase().contains('invalid token')) {
          _handleUnauthorized();
        }
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    ApiException apiException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        apiException = NetworkException('Cannot connect to server. Check your network connection and server URL.');
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;
        String errorMessage = 'Server error occurred ($statusCode)';

        if (responseData is Map<String, dynamic> && responseData.containsKey('error')) {
          errorMessage = responseData['error'].toString();
        }

        if (statusCode == 401) {
          _handleUnauthorized();
          apiException = UnauthorizedException(errorMessage);
        } else if (statusCode == 403) {
          apiException = ForbiddenException(errorMessage);
        } else if (statusCode == 400) {
          apiException = ValidationException(errorMessage);
        } else {
          apiException = ServerException(errorMessage);
        }
        break;
      case DioExceptionType.cancel:
        apiException = ApiException(message: 'Request was cancelled');
        break;
      default:
        apiException = ApiException(message: err.message ?? 'Unexpected network error');
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: apiException,
        response: err.response,
        type: err.type,
      ),
    );
  }

  void _handleUnauthorized() {
    _storageService.clearSession();
    if (gx.Get.currentRoute != AppRoutes.login) {
      gx.Get.offAllNamed(AppRoutes.login);
    }
  }
}

