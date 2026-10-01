import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/providers.dart';
import '../../../shared/models/issue.dart';
import '../services/issue_service.dart';

final issueServiceProvider = Provider<IssueService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return IssueService(apiClient: apiClient);
});

final myIssuesProvider = FutureProvider<List<Issue>>((ref) async {
  final service = ref.watch(issueServiceProvider);
  return service.getMyIssues();
});

class IssueMutationsNotifier extends StateNotifier<AsyncValue<void>> {
  final IssueService _service;
  final Ref _ref;

  IssueMutationsNotifier({
    required IssueService service,
    required Ref ref,
  })  : _service = service,
        _ref = ref,
        super(const AsyncValue.data(null));

  Future<void> createIssue({
    required String type,
    required String title,
    required String description,
    String? attachmentUrl,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.createIssue(
        type: type,
        title: title,
        description: description,
        attachmentUrl: attachmentUrl,
      );
      _ref.invalidate(myIssuesProvider);
    });
  }
}

final issueMutationsProvider =
    StateNotifierProvider<IssueMutationsNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(issueServiceProvider);
  return IssueMutationsNotifier(service: service, ref: ref);
});
