import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_engineer_dto.dart';
import 'admin_summary_provider.dart';

final adminEngineersSearchProvider = StateProvider<String>((ref) => '');

final adminEngineersProvider = FutureProvider<AdminEngineersResponseDto>((ref) async {
  final search = ref.watch(adminEngineersSearchProvider);
  final service = ref.watch(adminServiceProvider);
  return service.getEngineers(search: search.isEmpty ? null : search);
});
