enum UserRole { supervisor, plantManager }

final class Session {
  const Session({
    required this.accessToken,
    required this.role,
    required this.expiresAt,
  });

  final String accessToken;
  final UserRole role;
  final DateTime expiresAt;

  bool isExpired(DateTime referenceTime) {
    return !expiresAt.toUtc().isAfter(referenceTime.toUtc());
  }
}
