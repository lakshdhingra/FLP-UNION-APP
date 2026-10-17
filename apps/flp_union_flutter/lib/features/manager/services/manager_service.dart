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
    final response = await _apiClient.post(
      '/manager/upload-url',
      data: {
        'fileName': fileName,
        'mimeType': mimeType,
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
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

  Future<String> getDocumentUrl(String key) async {
    if (key.startsWith('http://') || key.startsWith('https://')) {
      return key;
    }
    final response = await _apiClient.get(
      '/manager/document-url',
      queryParameters: {'key': key},
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
    return key;
  }
}
