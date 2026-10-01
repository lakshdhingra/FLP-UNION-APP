class RegisterManagerDto {
  final String fullName;
  final String mobile;
  final String email;
  final String stateId;
  final String districtId;
  final String password;

  const RegisterManagerDto({
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.stateId,
    required this.districtId,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'mobile': mobile,
        'email': email,
        'stateId': stateId,
        'districtId': districtId,
        'password': password,
      };
}
