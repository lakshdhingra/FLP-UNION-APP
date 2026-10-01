import '../../../shared/models/auth_user.dart';
import '../../../shared/models/user_role.dart';

abstract class AuthRepository {
  Future<UserRole> login({required String email, required String password});
  Future<void> registerManager({
    required String fullName,
    required String mobile,
    required String email,
    required String stateId,
    required String districtId,
    required String password,
  });
  Future<void> logout();
  Future<AuthUser?> getCurrentUser();
}
