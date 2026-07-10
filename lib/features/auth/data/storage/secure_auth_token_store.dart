import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_token_store.dart';

class SecureAuthTokenStore implements AuthTokenStore {
  SecureAuthTokenStore(this._storage);

  static const String _accessTokenKey = 'asaancare.auth.access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readAccessToken() async {
    final token = await _storage.read(key: _accessTokenKey);
    final cleanToken = token?.trim();

    if (cleanToken == null || cleanToken.isEmpty) {
      return null;
    }

    return cleanToken;
  }

  @override
  Future<void> writeAccessToken(String token) async {
    final cleanToken = token.trim();

    if (cleanToken.isEmpty) {
      throw const FormatException('Access token cannot be empty.');
    }

    await _storage.write(key: _accessTokenKey, value: cleanToken);
  }

  @override
  Future<void> clearAccessToken() {
    return _storage.delete(key: _accessTokenKey);
  }
}
