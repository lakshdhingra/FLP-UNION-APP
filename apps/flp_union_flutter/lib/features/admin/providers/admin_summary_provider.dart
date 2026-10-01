import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/providers.dart';
import '../models/admin_summary_dto.dart';
import '../services/admin_service.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminService(apiClient: apiClient);
});

final adminSummaryProvider = FutureProvider<AdminSummaryDto>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return service.getSummary();
});
