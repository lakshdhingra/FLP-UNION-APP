import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_manager_dto.dart';
import 'admin_summary_provider.dart';

final adminManagersSearchProvider = StateProvider<String>((ref) => '');

final adminManagersProvider = FutureProvider<AdminManagersResponseDto>((ref) async {
  final search = ref.watch(adminManagersSearchProvider);
  final service = ref.watch(adminServiceProvider);
  return service.getManagers(search: search.isEmpty ? null : search);
});
