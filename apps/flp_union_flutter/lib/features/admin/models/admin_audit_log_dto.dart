class AdminAuditLogDto {
  final String id;
  final String actorId;
  final String actorName;
  final String action;
  final String targetType;
  final String? targetId;
  final DateTime createdAt;

  const AdminAuditLogDto({
    required this.id,
    required this.actorId,
    required this.actorName,
    required this.action,
    required this.targetType,
    this.targetId,
    required this.createdAt,
  });

  factory AdminAuditLogDto.fromJson(Map<String, dynamic> json) {
    final actorObj = json['actor'];
    String name = 'System';
    if (actorObj is Map) {
      final profileObj = actorObj['managerProfile'];
      if (profileObj is Map && (profileObj['fullName'] as String?)?.isNotEmpty == true) {
        name = profileObj['fullName'];
      } else if ((actorObj['email'] as String?)?.isNotEmpty == true) {
        name = actorObj['email'];
      }
    }

    return AdminAuditLogDto(
      id: json['id'] ?? '',
      actorId: json['actorId'] ?? '',
      actorName: name,
      action: json['action'] ?? 'ACTIVITY',
      targetType: json['targetType'] ?? 'SYSTEM',
      targetId: json['targetId'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AdminAuditLogsResponseDto {
  final List<AdminAuditLogDto> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AdminAuditLogsResponseDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory AdminAuditLogsResponseDto.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<AdminAuditLogDto> list = rawData is List
        ? rawData.map((item) => AdminAuditLogDto.fromJson(item as Map<String, dynamic>)).toList()
        : [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return AdminAuditLogsResponseDto(
      data: list,
      total: (meta['total'] as num?)?.toInt() ?? list.length,
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? 50,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
