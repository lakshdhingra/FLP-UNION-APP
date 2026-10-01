import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/providers.dart';
import '../../../shared/models/engineer.dart';
import '../services/engineer_service.dart';
import 'manager_dashboard_provider.dart';

final engineerServiceProvider = Provider<EngineerService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EngineerService(apiClient: apiClient);
});

final myEngineersProvider = FutureProvider.family<List<Engineer>, String>((ref, search) async {
  final service = ref.watch(engineerServiceProvider);
  return service.getEngineers(search: search.isNotEmpty ? search : null);
});

final engineerDetailProvider = FutureProvider.family<Engineer, String>((ref, id) async {
  final service = ref.watch(engineerServiceProvider);
  return service.getEngineer(id);
});

class EngineerMutationsNotifier extends StateNotifier<AsyncValue<void>> {
  final EngineerService _service;
  final Ref _ref;

  EngineerMutationsNotifier({
    required EngineerService service,
    required Ref ref,
  })  : _service = service,
        _ref = ref,
        super(const AsyncValue.data(null));

  Future<void> createEngineer(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.createEngineer(data);
      _ref.invalidate(myEngineersProvider);
      _ref.invalidate(managerDashboardProvider);
    });
  }

  Future<void> updateEngineer(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateEngineer(id, data);
      _ref.invalidate(myEngineersProvider);
      _ref.invalidate(engineerDetailProvider(id));
    });
  }

  Future<void> deleteEngineer(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.deleteEngineer(id);
      _ref.invalidate(myEngineersProvider);
      _ref.invalidate(managerDashboardProvider);
    });
  }
}

final engineerMutationsProvider =
    StateNotifierProvider<EngineerMutationsNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(engineerServiceProvider);
  return EngineerMutationsNotifier(service: service, ref: ref);
});
