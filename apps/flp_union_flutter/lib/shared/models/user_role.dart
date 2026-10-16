// ignore_for_file: constant_identifier_names
enum UserRole {
  ADMIN,
  MANAGER;

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.ADMIN;
      case 'MANAGER':
      default:
        return UserRole.MANAGER;
    }
  }

  String toJson() => name;
}
