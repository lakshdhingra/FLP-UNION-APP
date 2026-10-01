import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/providers.dart';
import '../models/manager_dashboard_dto.dart';
import '../services/manager_service.dart';

final managerServiceProvider = Provider<ManagerService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ManagerService(apiClient: apiClient);
});

final managerDashboardProvider = FutureProvider<ManagerDashboardDto>((ref) async {
  final service = ref.watch(managerServiceProvider);
  return service.getDashboard();
});
