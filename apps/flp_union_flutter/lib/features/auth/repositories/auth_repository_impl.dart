import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../shared/models/auth_user.dart';
import '../../../shared/models/user_role.dart';
import '../models/register_manager_dto.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storage;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required SecureStorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  @override
  Future<UserRole> login({required String email, required String password}) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['accessToken'] as String;
      final refreshToken = response.data['refreshToken'] as String;

      await _storage.setTokens(accessToken: accessToken, refreshToken: refreshToken);

      final payload = _decodeJwt(accessToken);
      return UserRole.fromString(payload['role'] ?? 'MANAGER');
    } on DioException catch (e) {
      final message = e.response?.data?['message'];
      final errorMsg = message is List ? message.join('\n') : (message ?? 'Invalid email or password.');
      throw ApiException(message: errorMsg.toString(), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> registerManager({
    required String fullName,
    required String mobile,
    required String email,
    required String stateId,
    required String districtId,
    required String password,
  }) async {
    try {
      final dto = RegisterManagerDto(
        fullName: fullName,
        mobile: mobile,
        email: email,
        stateId: stateId,
        districtId: districtId,
        password: password,
      );
      await _apiClient.post(
        ApiConstants.registerManager,
        data: dto.toJson(),
      );
    } on DioException catch (e) {
      final message = e.response?.data?['message'];
      final errorMsg = message is List ? message.join('\n') : (message ?? 'Registration failed.');
      throw ApiException(message: errorMsg.toString(), statusCode: e.response?.statusCode);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.post(
          ApiConstants.logout,
          data: {'refreshToken': refreshToken},
        );
      }
    } catch (_) {
      // Best effort logout
    } finally {
      await _storage.clearTokens();
    }
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.isEmpty) return null;

      final payload = _decodeJwt(token);
      final exp = (payload['exp'] as num?)?.toInt() ?? 0;
      final nowInSeconds = (DateTime.now().millisecondsSinceEpoch / 1000);

      if (nowInSeconds > exp) {
        // Attempt refresh
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await _storage.clearTokens();
          return null;
        }

        final refreshRes = await _apiClient.post(
          ApiConstants.refresh,
          data: {'refreshToken': refreshToken},
        );

        final newAccess = refreshRes.data['accessToken'] as String;
        final newRefresh = refreshRes.data['refreshToken'] as String;
        await _storage.setTokens(accessToken: newAccess, refreshToken: newRefresh);

        final newPayload = _decodeJwt(newAccess);
        return AuthUser(
          userId: newPayload['sub'] ?? newPayload['userId'] ?? '',
          role: UserRole.fromString(newPayload['role'] ?? 'MANAGER'),
          email: newPayload['email'],
        );
      }

      return AuthUser(
        userId: payload['sub'] ?? payload['userId'] ?? '',
        role: UserRole.fromString(payload['role'] ?? 'MANAGER'),
        email: payload['email'],
      );
    } catch (_) {
      await _storage.clearTokens();
      return null;
    }
  }

  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(resp);
    } catch (_) {
      return {};
    }
  }
}
