import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/providers.dart';
import '../../../shared/models/engineer.dart';
import '../../../shared/models/other_manager.dart';
import '../services/manager_directory_service.dart';

final managerDirectoryServiceProvider = Provider<ManagerDirectoryService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ManagerDirectoryService(apiClient: apiClient);
});

final sameStateManagersProvider = FutureProvider.family<List<OtherManager>, String>((ref, search) async {
  final service = ref.watch(managerDirectoryServiceProvider);
  return service.getManagers(search: search.isNotEmpty ? search : null);
});

final managerProfileByIdProvider = FutureProvider.family<OtherManager, String>((ref, id) async {
  final service = ref.watch(managerDirectoryServiceProvider);
  return service.getManager(id);
});

final otherManagerEngineersProvider = FutureProvider.family<List<Engineer>, String>((ref, managerId) async {
  final service = ref.watch(managerDirectoryServiceProvider);
  return service.getManagerEngineers(managerId);
});
