abstract interface class AuthTokenStore {
  Future<String?> readAccessToken();

  Future<void> writeAccessToken(String token);

  Future<void> clearAccessToken();
}
