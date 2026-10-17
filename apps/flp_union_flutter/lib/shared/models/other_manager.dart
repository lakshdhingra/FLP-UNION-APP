import 'district_entity.dart';
import 'state_entity.dart';

class OtherManager {
  final String id;
  final String fullName;
  final String email;
  final String mobile;
  final String? profilePhotoUrl;
  final List<String> brandsWorkedWith;
  final StateEntity state;
  final DistrictEntity district;
  final int totalEngineers;

  const OtherManager({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    this.profilePhotoUrl,
    this.brandsWorkedWith = const [],
    required this.state,
    required this.district,
    required this.totalEngineers,
  });

  factory OtherManager.fromJson(Map<String, dynamic> json) {
    List<String> parsedBrands = [];
    if (json['brandsWorkedWith'] is List) {
      parsedBrands = (json['brandsWorkedWith'] as List)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (json['brandsWorkedWith'] is String) {
      parsedBrands = (json['brandsWorkedWith'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return OtherManager(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['user']?['email'] ?? '',
      email: json['email'] ?? json['user']?['email'] ?? '',
      mobile: json['mobile'] ?? json['user']?['mobile'] ?? '',
      profilePhotoUrl: json['profilePhotoUrl'],
      brandsWorkedWith: parsedBrands,
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
        'profilePhotoUrl': profilePhotoUrl,
        'brandsWorkedWith': brandsWorkedWith,
        'state': state.toJson(),
        'district': district.toJson(),
        'totalEngineers': totalEngineers,
      };
}
