import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<void> saveAccessToken(String token);

  Future<String?> readAccessToken();

  Future<void> deleteAccessToken();

  Future<void> saveRole(String role);

  Future<String?> readRole();

  Future<void> saveExpiresAt(String expiresAt);

  Future<String?> readExpiresAt();

  Future<void> clearSession();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _roleKey = 'role';
  static const _expiresAtKey = 'expires_at';

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> deleteAccessToken() {
    return _storage.delete(key: _accessTokenKey);
  }

  @override
  Future<void> saveRole(String role) {
    return _storage.write(key: _roleKey, value: role);
  }

  @override
  Future<String?> readRole() {
    return _storage.read(key: _roleKey);
  }

  @override
  Future<void> saveExpiresAt(String expiresAt) {
    return _storage.write(key: _expiresAtKey, value: expiresAt);
  }

  @override
  Future<String?> readExpiresAt() {
    return _storage.read(key: _expiresAtKey);
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _expiresAtKey);
  }
}
