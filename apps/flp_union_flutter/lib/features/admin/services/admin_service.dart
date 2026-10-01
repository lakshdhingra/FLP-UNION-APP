import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/admin_audit_log_dto.dart';
import '../models/admin_engineer_dto.dart';
import '../models/admin_issue_dto.dart';
import '../models/admin_manager_dto.dart';
import '../models/admin_state_dto.dart';
import '../models/admin_summary_dto.dart';

class AdminService {
  final ApiClient _apiClient;

  AdminService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<AdminSummaryDto> getSummary() async {
    final response = await _apiClient.get(ApiConstants.adminAnalyticsSummary);
    return AdminSummaryDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<AdminStateDto>> getStates({bool includeInactive = true}) async {
    final response = await _apiClient.get(
      ApiConstants.adminStates,
      queryParameters: {'includeInactive': includeInactive},
    );
    final List<dynamic> listData = response.data is List ? response.data : (response.data['data'] ?? []);
    return listData.map((json) => AdminStateDto.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<AdminStateDto> updateState(String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch(
      '${ApiConstants.adminStates}/$id',
      data: data,
    );
    return AdminStateDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AdminManagersResponseDto> getManagers({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.adminManagers,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'limit': limit,
      },
    );
    return AdminManagersResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AdminEngineersResponseDto> getEngineers({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.adminEngineers,
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        'page': page,
        'limit': limit,
      },
    );
    return AdminEngineersResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AdminIssuesResponseDto> getIssues({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.adminIssues,
      queryParameters: {
        if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
        'page': page,
        'limit': limit,
      },
    );
    return AdminIssuesResponseDto.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> updateIssueStatus(String id, String status) async {
    await _apiClient.patch(
      '${ApiConstants.issues}/$id/status',
      data: {'status': status},
    );
  }

  Future<AdminAuditLogsResponseDto> getAuditLogs({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.adminAuditLogs,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    return AdminAuditLogsResponseDto.fromJson(response.data as Map<String, dynamic>);
  }
}
