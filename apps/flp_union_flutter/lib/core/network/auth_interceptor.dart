import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;
  final Function() _onUnauthorized;
  bool _isRefreshing = false;

  AuthInterceptor({
    required SecureStorageService storage,
    required Dio dio,
    required Function() onUnauthorized,
  })  : _storage = storage,
        _dio = dio,
        _onUnauthorized = onUnauthorized;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Content-Type'] = 'application/json';
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await _storage.clearTokens();
          _onUnauthorized();
          return handler.next(err);
        }

        // Call refresh endpoint
        final refreshResponse = await _dio.post(
          ApiConstants.refresh,
          data: {'refreshToken': refreshToken},
        );

        final newAccess = refreshResponse.data['accessToken'] as String?;
        final newRefresh = refreshResponse.data['refreshToken'] as String?;

        if (newAccess != null && newRefresh != null) {
          await _storage.setTokens(accessToken: newAccess, refreshToken: newRefresh);
          
          // Retry original request
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newAccess';
          final response = await _dio.fetch(options);
          return handler.resolve(response);
        }
      } catch (_) {
        await _storage.clearTokens();
        _onUnauthorized();
      } finally {
        _isRefreshing = false;
      }
    }
    return handler.next(err);
  }
}
