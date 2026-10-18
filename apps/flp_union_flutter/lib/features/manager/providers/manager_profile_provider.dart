import 'package:dio/dio.dart';
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
    bool clearPhoto = false,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = _ref.read(managerServiceProvider);
      final payload = <String, dynamic>{};
      if (fullName != null) payload['fullName'] = fullName;
      if (clearPhoto) {
        payload['profilePhotoUrl'] = null;
      } else if (profilePhotoUrl != null) {
        if (profilePhotoUrl.isEmpty) {
          payload['profilePhotoUrl'] = null;
        } else {
          final formattedUrl = profilePhotoUrl.startsWith('http')
              ? profilePhotoUrl
              : 'https://taspu-membership-documents-prod.s3.ap-south-1.amazonaws.com/$profilePhotoUrl';
          payload['profilePhotoUrl'] = formattedUrl;
        }
      }
      if (brandsWorkedWith != null) {
        payload['brandsWorkedWith'] = brandsWorkedWith;
      }

      try {
        await service.updateProfile(payload);
      } on DioException catch (dioErr) {
        // Fallback: if server rejected the canonical URL format (400), try sending the raw key
        if (dioErr.response?.statusCode == 400 &&
            payload.containsKey('profilePhotoUrl') &&
            payload['profilePhotoUrl'] != null &&
            profilePhotoUrl != null &&
            profilePhotoUrl.isNotEmpty &&
            !profilePhotoUrl.startsWith('http')) {
          payload['profilePhotoUrl'] = profilePhotoUrl;
          await service.updateProfile(payload);
        } else {
          rethrow;
        }
      }

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
