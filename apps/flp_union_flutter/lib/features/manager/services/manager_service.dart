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
}
