import 'iso_date_time.dart';

class DeviceDto {
  const DeviceDto({
    required this.deviceId,
    required this.areaId,
    required this.kind,
    required this.issuedAt,
    required this.expiresAt,
    required this.revokedAt,
  });

  factory DeviceDto.fromJson(Map<String, dynamic> json) {
    return DeviceDto(
      deviceId: _string(json, 'deviceId'),
      areaId: _string(json, 'areaId'),
      kind: _string(json, 'kind'),
      issuedAt: parseIsoDateTime(json['issuedAt'], 'issuedAt'),
      expiresAt: parseIsoDateTime(json['expiresAt'], 'expiresAt'),
      revokedAt: parseOptionalIsoDateTime(json, 'revokedAt'),
    );
  }

  final String deviceId;
  final String areaId;
  final String kind;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final DateTime? revokedAt;
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}
