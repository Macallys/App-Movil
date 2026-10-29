import '../../../../core/auth/token_storage.dart';
import '../../domain/entities/session.dart';
import '../dtos/session_dto.dart';
import '../mappers/session_mapper.dart';

class SessionLocalDataSource {
  SessionLocalDataSource({required this.storage, required this.mapper});

  final TokenStorage storage;
  final SessionMapper mapper;

  Future<void> save(Session session) async {
    await storage.saveAccessToken(session.accessToken);
    await storage.saveRole(mapper.roleName(session.role));
    await storage.saveExpiresAt(session.expiresAt.toUtc().toIso8601String());
  }

  Future<Session?> read() async {
    final accessToken = await storage.readAccessToken();
    final role = await storage.readRole();
    final expiresAt = await storage.readExpiresAt();
    if (accessToken == null || role == null || expiresAt == null) {
      return null;
    }
    try {
      return mapper.toEntity(
        SessionDto.fromJson({
          'accessToken': accessToken,
          'role': role,
          'expiresAt': expiresAt,
        }),
      );
    } on FormatException {
      await storage.clearSession();
      return null;
    }
  }

  Future<void> delete() {
    return storage.clearSession();
  }
}
