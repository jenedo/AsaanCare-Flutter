abstract interface class AuthTokenStore {
  Future<String?> readAccessToken();

  Future<void> writeAccessToken(String token);

  Future<void> clearAccessToken();

  Future<String?> readRefreshToken();

  Future<void> writeRefreshToken(String token);

  Future<void> clearRefreshToken();
}
