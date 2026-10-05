import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
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
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (designation != null && designation.isNotEmpty) queryParams['designation'] = designation;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

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

    return (listData as List).map((json) => Engineer.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Engineer> getEngineer(String id) async {
    final response = await _apiClient.get('${ApiConstants.managerEngineers}/$id');
    return Engineer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Engineer> createEngineer(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      ApiConstants.managerEngineers,
      data: data,
    );
    return Engineer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Engineer> updateEngineer(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      '${ApiConstants.managerEngineers}/$id',
      data: data,
    );
    return Engineer.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteEngineer(String id) async {
    await _apiClient.delete('${ApiConstants.managerEngineers}/$id');
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
    await s3Dio.put(
      signedUrl,
      data: Stream.fromIterable([bytes]),
      options: Options(
        headers: {
          'Content-Type': mimeType,
          'Content-Length': bytes.length,
        },
      ),
    );
  }

  Future<String> getDocumentUrl(String key) async {
    if (key.startsWith('http://') || key.startsWith('https://')) {
      return key;
    }
    final response = await _apiClient.get(
      '${ApiConstants.managerEngineers}/document-url',
      queryParameters: {'key': key},
    );
    final data = response.data as Map;
    return data['signedUrl'] as String;
  }
}
