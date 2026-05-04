import 'auth_user.dart';

class AuthLoginResult {
  const AuthLoginResult({
    required this.token,
    required this.user,
  });

  final String token;
  final AuthUser user;

  factory AuthLoginResult.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const FormatException('Resposta de login inválida: user em falta.');
    }
    final token = json['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const FormatException('Resposta de login inválida: token em falta.');
    }
    return AuthLoginResult(
      token: token,
      user: AuthUser.fromJson(userJson),
    );
  }
}
