import 'user_role.dart';

class AuthUser {
  final String userId;
  final UserRole role;
  final String? email;

  const AuthUser({
    required this.userId,
    required this.role,
    this.email,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] ?? json['sub'] ?? '',
      role: UserRole.fromString(json['role'] ?? 'MANAGER'),
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'role': role.toJson(),
        'email': email,
      };
}
