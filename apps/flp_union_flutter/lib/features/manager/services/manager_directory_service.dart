import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/engineer.dart';
import '../../../shared/models/other_manager.dart';

class ManagerDirectoryService {
  final ApiClient _apiClient;

  ManagerDirectoryService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<OtherManager>> getManagers({
    String? search,
    String? districtId,
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (districtId != null && districtId.isNotEmpty) queryParams['districtId'] = districtId;
    if (page != null) queryParams['page'] = page;
    if (limit != null) queryParams['limit'] = limit;

    final response = await _apiClient.get(
      ApiConstants.managerManagers,
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

    return (listData as List).map((json) => OtherManager.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<OtherManager> getManager(String id) async {
    final response = await _apiClient.get('${ApiConstants.managerManagers}/$id');
    return OtherManager.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Engineer>> getManagerEngineers(String id) async {
    final response = await _apiClient.get('${ApiConstants.managerManagers}/$id/engineers');
    final List<dynamic> listData = response.data is List ? response.data : (response.data['data'] ?? []);
    return listData.map((json) => Engineer.fromJson(json as Map<String, dynamic>)).toList();
  }
}
