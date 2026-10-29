import 'iso_date_time.dart';

class NoiseReadingDto {
  const NoiseReadingDto({
    required this.deviceId,
    required this.decibels,
    required this.recordedAt,
  });

  factory NoiseReadingDto.fromJson(Map<String, dynamic> json) {
    final decibels = json['decibels'];
    if (decibels is! num) {
      throw const FormatException('Unexpected decibels');
    }
    final deviceId = json['deviceId'];
    if (deviceId is! String || deviceId.isEmpty) {
      throw const FormatException('Unexpected deviceId');
    }
    return NoiseReadingDto(
      deviceId: deviceId,
      decibels: decibels,
      recordedAt: parseIsoDateTime(json['recordedAt'], 'recordedAt'),
    );
  }

  final String deviceId;
  final num decibels;
  final DateTime recordedAt;
}
