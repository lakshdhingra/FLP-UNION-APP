import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({
    required SecureStorageService storage,
    required Function() onUnauthorized,
    String? baseUrlOverride,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrlOverride ?? ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(
        storage: storage,
        dio: dio,
        onUnauthorized: onUnauthorized,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('[ApiClient] REQUEST[${options.method}] => URL: ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('[ApiClient] RESPONSE[${response.statusCode}] <= URL: ${response.requestOptions.uri}');
          return handler.next(response);
        },
        onError: (DioException err, handler) {
          final statusCode = err.response?.statusCode ?? 'N/A';
          final uri = err.requestOptions.uri;
          final errorType = err.type;
          final errorMessage = err.message ?? err.error ?? 'Unknown Dio error';
          final responseData = err.response?.data;
          
          debugPrint('[ApiClient] HTTP FAILURE:');
          debugPrint('  -> Requested URL: $uri');
          debugPrint('  -> Status Code: $statusCode');
          debugPrint('  -> Error Type: $errorType');
          debugPrint('  -> Message: $errorMessage');
          if (responseData != null) {
            debugPrint('  -> Response Data: $responseData');
          }
          return handler.next(err);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
}
