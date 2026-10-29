import 'iso_date_time.dart';

class RevokeDeviceResponseDto {
  const RevokeDeviceResponseDto({
    required this.deviceId,
    required this.revokedAt,
  });

  factory RevokeDeviceResponseDto.fromJson(Map<String, dynamic> json) {
    final deviceId = json['deviceId'];
    if (deviceId is! String || deviceId.isEmpty) {
      throw const FormatException('Unexpected deviceId');
    }
    return RevokeDeviceResponseDto(
      deviceId: deviceId,
      revokedAt: parseIsoDateTime(json['revokedAt'], 'revokedAt'),
    );
  }

  final String deviceId;
  final DateTime revokedAt;
}
