class AdminEngineerDto {
  final String id;
  final String fullName;
  final String? designation;
  final bool isActive;
  final String? stateName;
  final String? districtName;
  final String? managerName;

  const AdminEngineerDto({
    required this.id,
    required this.fullName,
    this.designation,
    required this.isActive,
    this.stateName,
    this.districtName,
    this.managerName,
  });

  factory AdminEngineerDto.fromJson(Map<String, dynamic> json) {
    final stateObj = json['state'];
    final districtObj = json['district'];
    final managerObj = json['manager'];

    return AdminEngineerDto(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      designation: json['designation'],
      isActive: json['isActive'] ?? true,
      stateName: stateObj is Map ? stateObj['name'] : null,
      districtName: districtObj is Map ? districtObj['name'] : null,
      managerName: managerObj is Map ? managerObj['fullName'] : null,
    );
  }
}

class AdminEngineersResponseDto {
  final List<AdminEngineerDto> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AdminEngineersResponseDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory AdminEngineersResponseDto.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<AdminEngineerDto> list = rawData is List
        ? rawData.map((item) => AdminEngineerDto.fromJson(item as Map<String, dynamic>)).toList()
        : [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return AdminEngineersResponseDto(
      data: list,
      total: (meta['total'] as num?)?.toInt() ?? list.length,
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? 20,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
