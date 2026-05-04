import '../../models/auth_login_result.dart';
import '../../models/auth_user.dart';

abstract class AuthRemoteDataSource {
  Future<AuthLoginResult> login({
    required String email,
    required String password,
  });

  Future<AuthLoginResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<AuthUser> me();
}
