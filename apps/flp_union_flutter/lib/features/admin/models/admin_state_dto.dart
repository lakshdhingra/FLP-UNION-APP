class AdminStateCount {
  final int districts;
  final int managerProfiles;

  const AdminStateCount({
    required this.districts,
    required this.managerProfiles,
  });

  factory AdminStateCount.fromJson(Map<String, dynamic> json) {
    return AdminStateCount(
      districts: (json['districts'] as num?)?.toInt() ?? 0,
      managerProfiles: (json['managerProfiles'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'districts': districts,
        'managerProfiles': managerProfiles,
      };
}

class AdminStateDto {
  final String id;
  final String name;
  final bool isActive;
  final AdminStateCount count;

  const AdminStateDto({
    required this.id,
    required this.name,
    required this.isActive,
    required this.count,
  });

  factory AdminStateDto.fromJson(Map<String, dynamic> json) {
    return AdminStateDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isActive: json['isActive'] ?? true,
      count: AdminStateCount.fromJson(json['_count'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isActive': isActive,
        '_count': count.toJson(),
      };
}
