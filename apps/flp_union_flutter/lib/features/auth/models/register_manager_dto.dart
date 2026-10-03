class RegisterManagerDto {
  final String fullName;
  final String mobile;
  final String email;
  final String stateId;
  final String districtId;
  final String password;
  final String confirmPassword;

  const RegisterManagerDto({
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.stateId,
    required this.districtId,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'mobile': mobile,
        'email': email,
        'stateId': stateId,
        'districtId': districtId,
        'password': password,
        'confirmPassword': confirmPassword,
      };
}
