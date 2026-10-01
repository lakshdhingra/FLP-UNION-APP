import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/issue.dart';

class IssueService {
  final ApiClient _apiClient;

  IssueService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<Issue> createIssue({
    required String type,
    required String title,
    required String description,
    String? attachmentUrl,
  }) async {
    final payload = <String, dynamic>{
      'type': type,
      'title': title,
      'description': description,
    };
    if (attachmentUrl != null && attachmentUrl.isNotEmpty) {
      payload['attachmentUrl'] = attachmentUrl;
    }

    final response = await _apiClient.post(
      ApiConstants.issues,
      data: payload,
    );
    return Issue.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Issue>> getMyIssues() async {
    final response = await _apiClient.get(ApiConstants.issuesMine);
    final List<dynamic> listData = response.data is List ? response.data : (response.data['data'] ?? []);
    return listData.map((json) => Issue.fromJson(json as Map<String, dynamic>)).toList();
  }
}
