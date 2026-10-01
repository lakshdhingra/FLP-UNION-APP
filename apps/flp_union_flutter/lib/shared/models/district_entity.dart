class DistrictEntity {
  final String id;
  final String name;
  final String? stateId;

  const DistrictEntity({
    required this.id,
    required this.name,
    this.stateId,
  });

  factory DistrictEntity.fromJson(Map<String, dynamic> json) {
    return DistrictEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      stateId: json['stateId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'stateId': stateId,
      };
}
