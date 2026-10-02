import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/district_entity.dart';
import '../../../shared/models/state_entity.dart';

class StatesService {
  final ApiClient _apiClient;

  StatesService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<StateEntity>> getAllStates() async {
    final response = await _apiClient.get(ApiConstants.states);
    final rawData = response.data;
    final List<dynamic> listData;
    if (rawData is List) {
      listData = rawData;
    } else if (rawData is Map && rawData['data'] is List) {
      listData = rawData['data'] as List;
    } else {
      listData = [];
    }
    return listData
        .map((json) => StateEntity.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  Future<List<DistrictEntity>> getDistricts(String stateId) async {
    final response = await _apiClient.get('${ApiConstants.states}/$stateId/districts');
    final rawData = response.data;
    final List<dynamic> listData;
    if (rawData is List) {
      listData = rawData;
    } else if (rawData is Map && rawData['data'] is List) {
      listData = rawData['data'] as List;
    } else {
      listData = [];
    }
    return listData
        .map((json) => DistrictEntity.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }
}
