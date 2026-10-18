import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiException.fromDioException(DioException e) {
    String errorMsg = e.message ?? 'An unexpected network error occurred';
    final responseData = e.response?.data;
    if (responseData is Map) {
      final msg = responseData['message'];
      if (msg is List) {
        errorMsg = msg.map((m) => m.toString()).join('\n');
      } else if (msg != null && msg.toString().isNotEmpty) {
        errorMsg = msg.toString();
      } else if (responseData['error'] != null) {
        errorMsg = responseData['error'].toString();
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      errorMsg = responseData;
    }
    return ApiException(
      message: errorMsg,
      statusCode: e.response?.statusCode,
      details: responseData,
    );
  }

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'Unauthorized session expired'})
      : super(statusCode: 401);
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'Network connection failure'});
}
