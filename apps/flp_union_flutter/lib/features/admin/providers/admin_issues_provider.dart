import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_issue_dto.dart';
import 'admin_summary_provider.dart';

final adminIssuesFilterProvider = StateProvider<String>((ref) => '');

final adminIssuesProvider = FutureProvider<AdminIssuesResponseDto>((ref) async {
  final filter = ref.watch(adminIssuesFilterProvider);
  final service = ref.watch(adminServiceProvider);
  return service.getIssues(status: filter.isEmpty ? null : filter);
});

class AdminIssueStatusNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AdminIssueStatusNotifier({required Ref ref})
      : _ref = ref,
        super(const AsyncValue.data(null));

  Future<void> updateIssueStatus(String id, String status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = _ref.read(adminServiceProvider);
      await service.updateIssueStatus(id, status);
      _ref.invalidate(adminIssuesProvider);
      _ref.invalidate(adminSummaryProvider);
    });
  }
}

final adminIssueStatusProvider =
    StateNotifierProvider<AdminIssueStatusNotifier, AsyncValue<void>>((ref) {
  return AdminIssueStatusNotifier(ref: ref);
});
