import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/manager_profile_dto.dart';
import 'manager_dashboard_provider.dart';

final managerProfileProvider = FutureProvider<ManagerProfileDto>((ref) async {
  final service = ref.watch(managerServiceProvider);
  return service.getProfile();
});

final managerDocumentUrlProvider =
    FutureProvider.family<String, String>((ref, key) async {
  if (key.isEmpty) return '';
  final service = ref.watch(managerServiceProvider);
  return service.getDocumentUrl(key);
});

class ManagerProfileMutationsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  ManagerProfileMutationsNotifier({required Ref ref})
      : _ref = ref,
        super(const AsyncValue.data(null));

  Future<void> updateProfile({
    String? fullName,
    String? profilePhotoUrl,
    List<String>? brandsWorkedWith,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = _ref.read(managerServiceProvider);
      final payload = <String, dynamic>{};
      if (fullName != null) payload['fullName'] = fullName;
      if (profilePhotoUrl != null) payload['profilePhotoUrl'] = profilePhotoUrl;
      if (brandsWorkedWith != null) {
        payload['brandsWorkedWith'] = brandsWorkedWith;
      }

      await service.updateProfile(payload);
      _ref.invalidate(managerProfileProvider);
      _ref.invalidate(managerDashboardProvider);
    });
    if (state.hasError) throw state.error!;
  }

  Future<String> uploadProfilePhotoToS3({
    required String fileName,
    required String mimeType,
    required List<int> bytes,
  }) async {
    final service = _ref.read(managerServiceProvider);
    final presignedData = await service.getPresignedUploadUrl(
      fileName: fileName,
      mimeType: mimeType,
    );
    final key = presignedData['key'] as String;
    final signedUrl = presignedData['signedUrl'] as String;
    await service.uploadFileToS3(
      signedUrl: signedUrl,
      bytes: bytes,
      mimeType: mimeType,
    );
    return key;
  }
}

final managerProfileMutationsProvider =
    StateNotifierProvider<ManagerProfileMutationsNotifier, AsyncValue<void>>(
        (ref) {
  return ManagerProfileMutationsNotifier(ref: ref);
});
