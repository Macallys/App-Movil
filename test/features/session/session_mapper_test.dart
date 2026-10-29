import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/session/data/dtos/session_dto.dart';
import 'package:safeplant_mobile/features/session/data/mappers/session_mapper.dart';
import 'package:safeplant_mobile/features/session/domain/entities/session.dart';

void main() {
  const mapper = SessionMapper();

  test('SessionMapper maps Supervisor', () {
    final session = mapper.toEntity(
      SessionDto(
        accessToken: 'token-1',
        role: 'Supervisor',
        expiresAt: DateTime.utc(2026, 10, 23, 20),
      ),
    );

    expect(session.role, UserRole.supervisor);
    expect(session.accessToken, 'token-1');
  });

  test('SessionMapper maps PlantManager without inventing roles', () {
    final session = mapper.toEntity(
      SessionDto(
        accessToken: 'token-1',
        role: 'PlantManager',
        expiresAt: DateTime.utc(2026, 10, 23, 20),
      ),
    );

    expect(session.role, UserRole.plantManager);
  });

  test('SessionMapper rejects an unknown role', () {
    expect(
      () => mapper.toEntity(
        SessionDto(
          accessToken: 'token-1',
          role: 'Admin',
          expiresAt: DateTime.utc(2026, 10, 23, 20),
        ),
      ),
      throwsFormatException,
    );
  });
}
