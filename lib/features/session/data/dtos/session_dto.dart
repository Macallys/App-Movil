class SessionDto {
  const SessionDto({
    required this.accessToken,
    required this.role,
    required this.expiresAt,
  });

  final String accessToken;
  final String role;
  final DateTime expiresAt;

  factory SessionDto.fromJson(Map<String, dynamic> json) {
    final accessToken = json['accessToken'];
    final role = json['role'];
    final expiresAtRaw = json['expiresAt'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const FormatException('accessToken is required');
    }
    if (role is! String || role.isEmpty) {
      throw const FormatException('role is required');
    }
    if (expiresAtRaw is! String || !_iso8601.hasMatch(expiresAtRaw)) {
      throw const FormatException('expiresAt must be ISO-8601');
    }
    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) {
      throw const FormatException('expiresAt must be ISO-8601');
    }
    return SessionDto(
      accessToken: accessToken,
      role: role,
      expiresAt: expiresAt,
    );
  }

  static final RegExp _iso8601 = RegExp(
    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$',
  );
}
