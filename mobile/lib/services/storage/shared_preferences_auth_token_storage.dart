import 'package:shared_preferences/shared_preferences.dart';

import 'auth_token_storage.dart';

class SharedPreferencesAuthTokenStorage implements AuthTokenStorage {
  SharedPreferencesAuthTokenStorage(this._prefs);

  static const String _key = 'auth.access_token';
  static const String _userIdKey = 'auth.user_id';

  final SharedPreferences _prefs;

  @override
  Future<String?> readAccessToken() async {
    final value = _prefs.getString(_key);
    return value == null || value.isEmpty ? null : value;
  }

  @override
  Future<int?> readUserId() async {
    return _prefs.getInt(_userIdKey);
  }

  @override
  Future<void> persistAccessToken(String token) async {
    await _prefs.setString(_key, token);
  }

  @override
  Future<void> persistUserId(int userId) async {
    await _prefs.setInt(_userIdKey, userId);
  }

  @override
  Future<void> clearAccessToken() async {
    await _prefs.remove(_key);
  }

  @override
  Future<void> clearUserId() async {
    await _prefs.remove(_userIdKey);
  }
}
