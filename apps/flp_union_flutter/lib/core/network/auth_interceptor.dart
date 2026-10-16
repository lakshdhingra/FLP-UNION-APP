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
    if (options.headers['Content-Type'] == null && options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path;
    final isAuthEndpoint = path.contains(ApiConstants.login) ||
        path.contains(ApiConstants.refresh);

    if (err.response?.statusCode == 401 && !_isRefreshing && !isAuthEndpoint) {
      _isRefreshing = true;
      String? newAccess;

      try {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await _storage.clearTokens();
          _onUnauthorized();
          return handler.next(err);
        }

        // Call refresh endpoint directly
        final refreshResponse = await _dio.post(
          ApiConstants.refresh,
          data: {'refreshToken': refreshToken},
        );

        final access = refreshResponse.data['accessToken'] as String?;
        final refresh = refreshResponse.data['refreshToken'] as String?;

        if (access != null && refresh != null) {
          await _storage.setTokens(
            accessToken: access,
            refreshToken: refresh,
          );
          newAccess = access;
        } else {
          await _storage.clearTokens();
          _onUnauthorized();
          return handler.next(err);
        }
      } catch (refreshErr) {
        if (refreshErr is DioException &&
            (refreshErr.response?.statusCode == 401 ||
                refreshErr.response?.statusCode == 400)) {
          await _storage.clearTokens();
          _onUnauthorized();
        }
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }

      // Retry original request outside of refresh error handling
      try {
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newAccess';
        final response = await _dio.fetch(options);
        return handler.resolve(response);
      } on DioException catch (retryErr) {
        return handler.next(retryErr);
      } catch (retryErr) {
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}
