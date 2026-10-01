class AdminManagerDto {
  final String id;
  final String fullName;
  final String email;
  final String? mobile;
  final String stateName;
  final String districtName;
  final int totalEngineers;

  const AdminManagerDto({
    required this.id,
    required this.fullName,
    required this.email,
    this.mobile,
    required this.stateName,
    required this.districtName,
    required this.totalEngineers,
  });

  factory AdminManagerDto.fromJson(Map<String, dynamic> json) {
    final stateObj = json['state'];
    final districtObj = json['district'];
    final userObj = json['user'];
    final countObj = json['_count'];

    return AdminManagerDto(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? userObj?['email'] ?? '',
      mobile: json['mobile'] ?? userObj?['mobile'],
      stateName: stateObj is Map ? (stateObj['name'] ?? '') : '',
      districtName: districtObj is Map ? (districtObj['name'] ?? '') : '',
      totalEngineers: (json['totalEngineers'] as num?)?.toInt() ??
          (countObj is Map ? (countObj['engineers'] as num?)?.toInt() ?? 0 : 0),
    );
  }
}

class AdminManagersResponseDto {
  final List<AdminManagerDto> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AdminManagersResponseDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory AdminManagersResponseDto.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final List<AdminManagerDto> list = rawData is List
        ? rawData.map((item) => AdminManagerDto.fromJson(item as Map<String, dynamic>)).toList()
        : [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return AdminManagersResponseDto(
      data: list,
      total: (meta['total'] as num?)?.toInt() ?? list.length,
      page: (meta['page'] as num?)?.toInt() ?? 1,
      limit: (meta['limit'] as num?)?.toInt() ?? 20,
      totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
