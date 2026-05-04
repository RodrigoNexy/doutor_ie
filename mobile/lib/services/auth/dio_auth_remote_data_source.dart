import 'package:dio/dio.dart';

import '../../models/auth_login_result.dart';
import '../../models/auth_user.dart';
import 'auth_login_exception.dart';
import 'auth_remote_data_source.dart';

class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  DioAuthRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<AuthLoginResult> login({
    required String email,
    required String password,
  }) async {
    return _postAuth(
      '/login',
      <String, dynamic>{'email': email, 'password': password},
      fallbackError: 'Não foi possível iniciar sessão. Tente novamente.',
    );
  }

  @override
  Future<AuthLoginResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _postAuth(
      '/register',
      <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      fallbackError: 'Não foi possível criar a conta. Tente novamente.',
    );
  }

  @override
  Future<AuthUser> me() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/me');
      final data = response.data;
      if (data == null) {
        throw const AuthLoginException('Resposta vazia do servidor.');
      }
      return AuthUser.fromJson(data);
    } on DioException catch (e) {
      throw AuthLoginException(
        _messageFromDio(e, 'Não foi possível recuperar usuário atual.'),
      );
    } on FormatException catch (e) {
      throw AuthLoginException(e.message);
    }
  }

  Future<AuthLoginResult> _postAuth(
    String path,
    Map<String, dynamic> body, {
    required String fallbackError,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
      );
      final data = response.data;
      if (data == null) {
        throw const AuthLoginException('Resposta vazia do servidor.');
      }
      return AuthLoginResult.fromJson(data);
    } on DioException catch (e) {
      throw AuthLoginException(_messageFromDio(e, fallbackError));
    } on FormatException catch (e) {
      throw AuthLoginException(e.message);
    }
  }

  String _messageFromDio(DioException e, String fallbackMessage) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      final errors = data['errors'];
      if (errors is Map) {
        final parts = <String>[];
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            parts.add(value.first.toString());
          }
        }
        if (parts.isNotEmpty) {
          return parts.join(' ');
        }
      }
    }
    if (status == 401) {
      return 'Credenciais inválidas.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tempo esgotado. Verifique a rede e a API.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Sem ligação ao servidor. Confirme o URL da API.';
    }
    return fallbackMessage;
  }
}
