import '../../domain/entities/session.dart';
import '../dtos/session_dto.dart';

class SessionMapper {
  const SessionMapper();

  Session toEntity(SessionDto dto) {
    return Session(
      accessToken: dto.accessToken,
      role: _role(dto.role),
      expiresAt: dto.expiresAt,
    );
  }

  String roleName(UserRole role) {
    return switch (role) {
      UserRole.supervisor => 'Supervisor',
      UserRole.plantManager => 'PlantManager',
    };
  }

  UserRole _role(String role) {
    return switch (role) {
      'Supervisor' => UserRole.supervisor,
      'PlantManager' => UserRole.plantManager,
      _ => throw const FormatException('Unknown role'),
    };
  }
}
