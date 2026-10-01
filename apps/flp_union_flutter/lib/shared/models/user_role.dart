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
