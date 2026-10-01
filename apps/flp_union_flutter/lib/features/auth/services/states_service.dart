import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/district_entity.dart';
import '../../../shared/models/state_entity.dart';

class StatesService {
  final ApiClient _apiClient;

  StatesService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<StateEntity>> getAllStates() async {
    final response = await _apiClient.get(ApiConstants.states);
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => StateEntity.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<DistrictEntity>> getDistricts(String stateId) async {
    final response = await _apiClient.get('${ApiConstants.states}/$stateId/districts');
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => DistrictEntity.fromJson(json as Map<String, dynamic>)).toList();
  }
}
