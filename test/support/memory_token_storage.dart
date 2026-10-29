import 'package:safeplant_mobile/core/auth/token_storage.dart';

class MemoryTokenStorage implements TokenStorage {
  String? accessToken;
  String? role;
  String? expiresAt;
  var saves = 0;
  var clears = 0;

  @override
  Future<void> clearSession() async {
    clears += 1;
    accessToken = null;
    role = null;
    expiresAt = null;
  }

  @override
  Future<void> deleteAccessToken() async {
    accessToken = null;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readExpiresAt() async => expiresAt;

  @override
  Future<String?> readRole() async => role;

  @override
  Future<void> saveAccessToken(String token) async {
    saves += 1;
    accessToken = token;
  }

  @override
  Future<void> saveExpiresAt(String value) async {
    expiresAt = value;
  }

  @override
  Future<void> saveRole(String value) async {
    role = value;
  }
}
