import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/manager_profile_dto.dart';
import 'manager_dashboard_provider.dart';

final managerProfileProvider = FutureProvider<ManagerProfileDto>((ref) async {
  final service = ref.watch(managerServiceProvider);
  return service.getProfile();
});

class ManagerProfileMutationsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ManagerProfileMutationsNotifier({required Ref ref})
      : _ref = ref,
        super(const AsyncValue.data(null));

  Future<void> updateProfile({String? fullName, String? profilePhotoUrl}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = _ref.read(managerServiceProvider);
      final payload = <String, dynamic>{};
      if (fullName != null) payload['fullName'] = fullName;
      if (profilePhotoUrl != null) payload['profilePhotoUrl'] = profilePhotoUrl;

      await service.updateProfile(payload);
      _ref.invalidate(managerProfileProvider);
      _ref.invalidate(managerDashboardProvider);
    });
  }
}

final managerProfileMutationsProvider =
    StateNotifierProvider<ManagerProfileMutationsNotifier, AsyncValue<void>>((ref) {
  return ManagerProfileMutationsNotifier(ref: ref);
});
