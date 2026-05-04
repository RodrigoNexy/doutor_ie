import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auth/auth_login_exception.dart';
import '../../../services/auth/auth_remote_data_source.dart';
import 'auth_session_notifier.dart';

class LoginActionState {
  const LoginActionState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;
}

class LoginActionNotifier extends StateNotifier<LoginActionState> {
  LoginActionNotifier(this._remote, this._sessionNotifier)
    : super(const LoginActionState());

  final AuthRemoteDataSource _remote;
  final AuthSessionNotifier _sessionNotifier;

  Future<void> submit({required String email, required String password}) async {
    state = const LoginActionState(isLoading: true);
    try {
      final result = await _remote.login(email: email, password: password);
      await _sessionNotifier.signInWithToken(
        result.token,
        userId: result.user.id,
      );
      state = const LoginActionState();
    } on AuthLoginException catch (e) {
      state = LoginActionState(errorMessage: e.message);
    } on Object {
      state = const LoginActionState(
        errorMessage: 'Erro inesperado. Tente novamente.',
      );
    }
  }
}
