import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/auth/auth_login_exception.dart';
import '../../../services/auth/auth_remote_data_source.dart';
import 'auth_session_notifier.dart';

class RegisterActionState {
  const RegisterActionState({this.isLoading = false, this.errorMessage});

  final bool isLoading;
  final String? errorMessage;
}

class RegisterActionNotifier extends StateNotifier<RegisterActionState> {
  RegisterActionNotifier(this._remote, this._sessionNotifier)
    : super(const RegisterActionState());

  final AuthRemoteDataSource _remote;
  final AuthSessionNotifier _sessionNotifier;

  Future<void> submit({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const RegisterActionState(isLoading: true);
    try {
      final result = await _remote.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      await _sessionNotifier.signInWithToken(
        result.token,
        userId: result.user.id,
      );
      state = const RegisterActionState();
    } on AuthLoginException catch (e) {
      state = RegisterActionState(errorMessage: e.message);
    } on Object {
      state = const RegisterActionState(
        errorMessage: 'Erro inesperado. Tente novamente.',
      );
    }
  }
}
