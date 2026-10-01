import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

abstract class SecureStorageService {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> setTokens({required String accessToken, required String refreshToken});
  Future<void> clearTokens();
}

class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageServiceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: ApiConstants.tokenKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: ApiConstants.refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> setTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: ApiConstants.tokenKey, value: accessToken);
    await _storage.write(key: ApiConstants.refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: ApiConstants.tokenKey);
    await _storage.delete(key: ApiConstants.refreshTokenKey);
  }
}
