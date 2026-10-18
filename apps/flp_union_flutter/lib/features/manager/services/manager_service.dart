import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/manager_dashboard_dto.dart';
import '../models/manager_profile_dto.dart';

class ManagerService {
  final ApiClient _apiClient;

  ManagerService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ManagerDashboardDto> getDashboard() async {
    final response = await _apiClient.get(ApiConstants.managerDashboard);
    return ManagerDashboardDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ManagerProfileDto> getProfile() async {
    final response = await _apiClient.get(ApiConstants.managerProfile);
    return ManagerProfileDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ManagerProfileDto> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      ApiConstants.managerProfile,
      data: data,
    );
    return ManagerProfileDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getPresignedUploadUrl({
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.managerEngineers}/upload-url',
        data: {
          'fileName': fileName,
          'mimeType': mimeType,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final fallback = await _apiClient.post(
          '/manager/upload-url',
          data: {
            'fileName': fileName,
            'mimeType': mimeType,
          },
        );
        return Map<String, dynamic>.from(fallback.data as Map);
      }
      rethrow;
    }
  }

  Future<void> uploadFileToS3({
    required String signedUrl,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final s3Dio = Dio();
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    try {
      await s3Dio.put(
        signedUrl,
        data: data,
        options: Options(
          headers: {
            'Content-Type': mimeType,
          },
        ),
      );
    } on DioException catch (e) {
      if (kIsWeb) {
        throw Exception(
          'Upload to storage failed (${e.type.name}). If testing Flutter Web locally, please verify that AWS S3 CORS allows your current port (e.g. http://localhost:*).',
        );
      }
      throw Exception('Upload to storage failed: ${e.message ?? e.toString()}');
    }
  }

  /// Extracts the clean S3 object key from a full canonical or path-style S3 URL.
  /// If [keyOrUrl] is already a clean key or an external URL, returns appropriate key/URL.
  static String extractS3Key(String keyOrUrl) {
    if (keyOrUrl.isEmpty) return '';
    try {
      if (keyOrUrl.startsWith('http://') || keyOrUrl.startsWith('https://')) {
        final uri = Uri.parse(keyOrUrl);
        // If it is already a signed URL with active authentication parameters, return as-is
        if (uri.queryParameters.containsKey('X-Amz-Signature') ||
            uri.queryParameters.containsKey('Signature') ||
            uri.queryParameters.containsKey('sig')) {
          return keyOrUrl;
        }
        // If it points to an S3 bucket or amazonaws host, extract the clean object key
        if (uri.host.contains('amazonaws.com') ||
            uri.host.contains('taspu-membership-documents')) {
          var path = uri.path;
          if (path.startsWith('/')) path = path.substring(1);
          if (path.startsWith('taspu-membership-documents-prod/')) {
            path = path.substring('taspu-membership-documents-prod/'.length);
          }
          return Uri.decodeComponent(path);
        }
        // Other external HTTP URLs (not AWS S3)
        return keyOrUrl;
      }
    } catch (_) {
      // Fallback
    }
    return keyOrUrl;
  }

  Future<String> getDocumentUrl(String key) async {
    if (key.isEmpty) return '';

    // If it's already a signed download URL or an external non-S3 URL, return directly
    if (key.startsWith('http://') || key.startsWith('https://')) {
      final uri = Uri.tryParse(key);
      if (uri != null) {
        if (uri.queryParameters.containsKey('X-Amz-Signature') ||
            uri.queryParameters.containsKey('Signature') ||
            uri.queryParameters.containsKey('sig')) {
          return key;
        }
        // If it is NOT an AWS S3 URL, return as-is (e.g. third-party image/CDN)
        if (!uri.host.contains('amazonaws.com') &&
            !uri.host.contains('taspu-membership-documents')) {
          return key;
        }
      }
    }

    final cleanKey = extractS3Key(key);
    if (cleanKey.isEmpty) return '';

    try {
      final response = await _apiClient.get(
        '${ApiConstants.managerEngineers}/document-url',
        queryParameters: {'key': cleanKey},
      );
      if (response.data is Map) {
        final map = response.data as Map;
        final url = map['signedUrl'] ??
            map['url'] ??
            (map['data'] is Map ? map['data']['signedUrl'] : null);
        if (url is String && url.isNotEmpty) {
          return url;
        }
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final fallback = await _apiClient.get(
          '/manager/document-url',
          queryParameters: {'key': cleanKey},
        );
        if (fallback.data is Map) {
          final map = fallback.data as Map;
          final url = map['signedUrl'] ??
              map['url'] ??
              (map['data'] is Map ? map['data']['signedUrl'] : null);
          if (url is String && url.isNotEmpty) {
            return url;
          }
        }
      }
      rethrow;
    }
    return key;
  }
}
