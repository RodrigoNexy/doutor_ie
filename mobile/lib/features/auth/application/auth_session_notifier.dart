import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/auth_session.dart';
import '../../../services/auth/auth_login_exception.dart';
import '../../../services/auth/auth_remote_data_source.dart';
import '../../../services/storage/auth_token_storage.dart';

class AuthSessionNotifier extends StateNotifier<AuthSession> {
  AuthSessionNotifier(this._storage, this._remote) : super(const AuthSession()) {
    _restore();
  }

  final AuthTokenStorage _storage;
  final AuthRemoteDataSource _remote;

  Future<void> _restore() async {
    final token = await _storage.readAccessToken();
    var userId = await _storage.readUserId();
    if (token != null && token.isNotEmpty && userId == null) {
      try {
        final me = await _remote.me();
        userId = me.id;
        await _storage.persistUserId(me.id);
      } on AuthLoginException catch (e) {
        if (_isUnauthorized(e.message)) {
          await _storage.clearAccessToken();
          await _storage.clearUserId();
          state = const AuthSession(bootstrapped: true);
          return;
        }
      } on Object {
        // Keep token for retry when network is back.
      }
    }

    state = AuthSession(
      accessToken: token,
      currentUserId: userId,
      bootstrapped: true,
    );
  }

  Future<void> signInWithToken(String token, {required int userId}) async {
    await _storage.persistAccessToken(token);
    await _storage.persistUserId(userId);
    state = AuthSession(
      accessToken: token,
      currentUserId: userId,
      bootstrapped: true,
    );
  }

  Future<void> signOut() async {
    await _storage.clearAccessToken();
    await _storage.clearUserId();
    state = const AuthSession(bootstrapped: true);
  }

  bool _isUnauthorized(String message) {
    final normalized = message.trim().toLowerCase();
    return normalized.contains('unauthenticated');
  }
}
