class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? error;
  final T? data;
  final Map<String, dynamic> raw;

  ApiResponse({
    required this.success,
    this.message,
    this.error,
    this.data,
    required this.raw,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, [T Function(dynamic)? transform]) {
    final success = json['success'] == true;
    final message = json['message']?.toString();
    final error = json['error']?.toString();

    T? data;
    if (transform != null) {
      data = transform(json);
    }

    return ApiResponse<T>(
      success: success,
      message: message,
      error: error,
      data: data,
      raw: json,
    );
  }
}

