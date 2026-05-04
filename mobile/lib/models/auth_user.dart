class AuthUser {
  const AuthUser({
    required this.id,
    required this.nome,
    required this.email,
  });

  final int id;
  final String nome;
  final String email;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      nome: json['nome'] as String,
      email: json['email'] as String,
    );
  }
}
