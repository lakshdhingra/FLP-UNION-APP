import 'district_entity.dart';
import 'state_entity.dart';

class Engineer {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? profilePhotoUrl;
  final String? address;
  final StateEntity? state;
  final DistrictEntity? district;
  final List<String> skills;
  final double? experienceYears;
  final String? designation;
  final String? govIdType;
  final String? govIdNumber;
  final double? salary;
  final String? privateNotes;
  final bool? isOwned;
  final bool isActive;

  const Engineer({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.profilePhotoUrl,
    this.address,
    this.state,
    this.district,
    this.skills = const [],
    this.experienceYears,
    this.designation,
    this.govIdType,
    this.govIdNumber,
    this.salary,
    this.privateNotes,
    this.isOwned,
    this.isActive = true,
  });

  factory Engineer.fromJson(Map<String, dynamic> json) {
    List<String> parsedSkills = [];
    if (json['skills'] is List) {
      parsedSkills = (json['skills'] as List).map((e) => e.toString()).toList();
    }

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return Engineer(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      profilePhotoUrl: json['profilePhotoUrl'],
      address: json['address'],
      state: json['state'] != null ? StateEntity.fromJson(json['state']) : null,
      district: json['district'] != null ? DistrictEntity.fromJson(json['district']) : null,
      skills: parsedSkills,
      experienceYears: parseDouble(json['experienceYears']),
      designation: json['designation'],
      govIdType: json['govIdType'],
      govIdNumber: json['govIdNumber'],
      salary: parseDouble(json['salary']),
      privateNotes: json['privateNotes'],
      isOwned: json['isOwned'] as bool?,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'phone': phone,
        'email': email,
        'profilePhotoUrl': profilePhotoUrl,
        'address': address,
        'state': state?.toJson(),
        'district': district?.toJson(),
        'skills': skills,
        'experienceYears': experienceYears,
        'designation': designation,
        'govIdType': govIdType,
        'govIdNumber': govIdNumber,
        'salary': salary,
        'privateNotes': privateNotes,
        'isOwned': isOwned,
        'isActive': isActive,
      };
}
