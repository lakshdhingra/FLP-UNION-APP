import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/engineer.dart';

class EngineerService {
  final ApiClient _apiClient;

  EngineerService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Engineer>> getEngineers({
    String? search,
    String? designation,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (designation != null && designation.isNotEmpty) {
      queryParams['designation'] = designation;
    }
    if (page != null) {
      queryParams['page'] = page;
    }
    if (limit != null) {
      queryParams['limit'] = limit;
    }

    try {
      final response = await _apiClient.get(
        ApiConstants.managerEngineers,
        queryParameters: queryParams,
      );

      dynamic listData;
      if (response.data is Map && response.data['data'] is List) {
        listData = response.data['data'];
      } else if (response.data is List) {
        listData = response.data;
      } else {
        listData = [];
      }

      return (listData as List)
          .map((json) => Engineer.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Engineer> getEngineer(String id) async {
    try {
      final response =
          await _apiClient.get('${ApiConstants.managerEngineers}/$id');
      return Engineer.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Engineer> createEngineer(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.managerEngineers,
        data: data,
      );
      return Engineer.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Engineer> updateEngineer(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        '${ApiConstants.managerEngineers}/$id',
        data: data,
      );
      return Engineer.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteEngineer(String id) async {
    try {
      await _apiClient.delete('${ApiConstants.managerEngineers}/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> getPresignedUploadUrl({
    required String fileName,
    required String mimeType,
  }) async {
    final response = await _apiClient.post(
      '${ApiConstants.managerEngineers}/upload-url',
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
      '${ApiConstants.managerEngineers}/document-url',
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
