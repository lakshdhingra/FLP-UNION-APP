class StateEntity {
  final String id;
  final String name;
  final bool isActive;

  const StateEntity({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  factory StateEntity.fromJson(Map<String, dynamic> json) {
    return StateEntity(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isActive': isActive,
      };
}
