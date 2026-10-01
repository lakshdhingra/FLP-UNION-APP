import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_state_dto.dart';
import 'admin_summary_provider.dart';

final adminStatesProvider = FutureProvider<List<AdminStateDto>>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return service.getStates(includeInactive: true);
});

class AdminStatesMutationsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AdminStatesMutationsNotifier({required Ref ref})
      : _ref = ref,
        super(const AsyncValue.data(null));

  Future<void> toggleStateStatus(String id, bool newIsActive) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = _ref.read(adminServiceProvider);
      await service.updateState(id, {'isActive': newIsActive});
      _ref.invalidate(adminStatesProvider);
      _ref.invalidate(adminSummaryProvider);
    });
  }
}

final adminStatesMutationsProvider =
    StateNotifierProvider<AdminStatesMutationsNotifier, AsyncValue<void>>((ref) {
  return AdminStatesMutationsNotifier(ref: ref);
});
