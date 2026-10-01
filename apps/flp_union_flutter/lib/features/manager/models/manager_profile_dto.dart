import '../../../shared/models/district_entity.dart';
import '../../../shared/models/state_entity.dart';

class ManagerProfileDto {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String mobile;
  final String? profilePhotoUrl;
  final StateEntity state;
  final DistrictEntity district;
  final int totalEngineers;

  const ManagerProfileDto({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.mobile,
    this.profilePhotoUrl,
    required this.state,
    required this.district,
    required this.totalEngineers,
  });

  factory ManagerProfileDto.fromJson(Map<String, dynamic> json) {
    return ManagerProfileDto(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? json['user']?['email'] ?? '',
      email: json['email'] ?? json['user']?['email'] ?? '',
      mobile: json['mobile'] ?? json['user']?['mobile'] ?? '',
      profilePhotoUrl: json['profilePhotoUrl'],
      state: StateEntity.fromJson(json['state'] ?? {}),
      district: DistrictEntity.fromJson(json['district'] ?? {}),
      totalEngineers: (json['totalEngineers'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'fullName': fullName,
        'email': email,
        'mobile': mobile,
        'profilePhotoUrl': profilePhotoUrl,
        'state': state.toJson(),
        'district': district.toJson(),
        'totalEngineers': totalEngineers,
      };
}
