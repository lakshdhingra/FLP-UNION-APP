import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_audit_log_dto.dart';
import 'admin_summary_provider.dart';

final adminAuditLogsProvider = FutureProvider<AdminAuditLogsResponseDto>((ref) async {
  final service = ref.watch(adminServiceProvider);
  return service.getAuditLogs();
});
