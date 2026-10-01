import '../../../shared/models/district_entity.dart';
import '../../../shared/models/state_entity.dart';

class ManagerProfileData {
  final String id;
  final String fullName;
  final String email;
  final String mobile;
  final StateEntity state;
  final DistrictEntity district;

  const ManagerProfileData({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.state,
    required this.district,
  });

  factory ManagerProfileData.fromJson(Map<String, dynamic> json) {
    return ManagerProfileData(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['user']?['email'] ?? 'Manager',
      email: json['email'] ?? json['user']?['email'] ?? '',
      mobile: json['mobile'] ?? json['user']?['mobile'] ?? '',
      state: StateEntity.fromJson(json['state'] ?? {}),
      district: DistrictEntity.fromJson(json['district'] ?? {}),
    );
  }
}

class DashboardStats {
  final int totalEngineers;
  final int activeEngineers;
  final int inactiveEngineers;
  final Map<String, int> experienceDistribution;
  final Map<String, int> designationDistribution;

  const DashboardStats({
    required this.totalEngineers,
    required this.activeEngineers,
    required this.inactiveEngineers,
    required this.experienceDistribution,
    required this.designationDistribution,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final expMap = <String, int>{};
    if (json['experienceDistribution'] is Map) {
      (json['experienceDistribution'] as Map).forEach((key, value) {
        expMap[key.toString()] = (value as num).toInt();
      });
    }

    final desigMap = <String, int>{};
    if (json['designationDistribution'] is Map) {
      (json['designationDistribution'] as Map).forEach((key, value) {
        desigMap[key.toString()] = (value as num).toInt();
      });
    }

    return DashboardStats(
      totalEngineers: (json['totalEngineers'] as num?)?.toInt() ?? 0,
      activeEngineers: (json['activeEngineers'] as num?)?.toInt() ?? 0,
      inactiveEngineers: (json['inactiveEngineers'] as num?)?.toInt() ?? 0,
      experienceDistribution: expMap,
      designationDistribution: desigMap,
    );
  }
}

class ManagerDashboardDto {
  final ManagerProfileData manager;
  final DashboardStats stats;

  const ManagerDashboardDto({
    required this.manager,
    required this.stats,
  });

  factory ManagerDashboardDto.fromJson(Map<String, dynamic> json) {
    return ManagerDashboardDto(
      manager: ManagerProfileData.fromJson(json['manager'] ?? {}),
      stats: DashboardStats.fromJson(json['stats'] ?? {}),
    );
  }
}
