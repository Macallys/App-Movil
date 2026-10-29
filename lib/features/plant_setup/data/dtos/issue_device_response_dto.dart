class IssueDeviceResponseDto {
  const IssueDeviceResponseDto({
    required this.deviceId,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory IssueDeviceResponseDto.fromJson(Map<String, dynamic> json) {
    return IssueDeviceResponseDto(
      deviceId: _string(json, 'deviceId'),
      issuedAt: _dateTime(json, 'issuedAt'),
      expiresAt: _dateTime(json, 'expiresAt'),
    );
  }

  final String deviceId;
  final DateTime issuedAt;
  final DateTime expiresAt;
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}

DateTime _dateTime(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || !_iso8601.hasMatch(value)) {
    throw FormatException('Unexpected $key');
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Unexpected $key');
  }
  return parsed;
}

final RegExp _iso8601 = RegExp(
  r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$',
);
