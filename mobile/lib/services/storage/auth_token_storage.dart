abstract class AuthTokenStorage {
  Future<String?> readAccessToken();

  Future<int?> readUserId();

  Future<void> persistAccessToken(String token);

  Future<void> persistUserId(int userId);

  Future<void> clearAccessToken();

  Future<void> clearUserId();
}
