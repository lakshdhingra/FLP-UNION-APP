class Issue {
  final String id;
  final String type;
  final String title;
  final String description;
  final String status;
  final String? attachmentUrl;
  final DateTime createdAt;

  const Issue({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'] ?? '',
      type: json['type'] ?? 'ISSUE',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'OPEN',
      attachmentUrl: json['attachmentUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'description': description,
        'status': status,
        'attachmentUrl': attachmentUrl,
        'createdAt': createdAt.toIso8601String(),
      };
}
