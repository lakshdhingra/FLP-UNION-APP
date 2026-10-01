import 'district_entity.dart';
import 'state_entity.dart';

class OtherManager {
  final String id;
  final String fullName;
  final String email;
  final String mobile;
  final StateEntity state;
  final DistrictEntity district;
  final int totalEngineers;

  const OtherManager({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.state,
    required this.district,
    required this.totalEngineers,
  });

  factory OtherManager.fromJson(Map<String, dynamic> json) {
    return OtherManager(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['user']?['email'] ?? '',
      email: json['email'] ?? json['user']?['email'] ?? '',
      mobile: json['mobile'] ?? json['user']?['mobile'] ?? '',
      state: StateEntity.fromJson(json['state'] ?? {}),
      district: DistrictEntity.fromJson(json['district'] ?? {}),
      totalEngineers: (json['totalEngineers'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'mobile': mobile,
        'state': state.toJson(),
        'district': district.toJson(),
        'totalEngineers': totalEngineers,
      };
}
