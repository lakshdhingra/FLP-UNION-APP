class AdminIssueDto {
  final String id;
  final String title;
  final String description;
  final String type;
  final String status;
  final DateTime createdAt;
  final String reporterName;

  const AdminIssueDto({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.reporterName,
  });

  factory AdminIssueDto.fromJson(Map<String, dynamic> json) {
    final reporterObj = json['reporter'];
    String repName = 'Unknown';
    if (reporterObj is Map) {
      final profileObj = reporterObj['managerProfile'];
      if (profileObj is Map && (profileObj['fullName'] as String?)?.isNotEmpty == true) {
        repName = profileObj['fullName'];
      } else if ((reporterObj['email'] as String?)?.isNotEmpty == true) {
        repName = reporterObj['email'];
      }
    }

    return AdminIssueDto(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'OTHER',
      status: json['status'] ?? 'OPEN',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      reporterName: repName,
    );
  }
}

class AdminIssuesResponseDto {
  final List<AdminIssueDto> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AdminIssuesResponseDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory AdminIssuesResponseDto.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<AdminIssueDto> list = rawData is List
        ? rawData.map((item) => AdminIssueDto.fromJson(item as Map<String, dynamic>)).toList()
        : [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return AdminIssuesResponseDto(
      data: list,
      total: (meta['total'] as num?)?.toInt() ?? list.length,
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? 20,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
