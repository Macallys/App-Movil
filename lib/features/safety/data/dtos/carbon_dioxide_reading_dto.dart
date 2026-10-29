import 'iso_date_time.dart';

class CarbonDioxideReadingDto {
  const CarbonDioxideReadingDto({
    required this.deviceId,
    required this.ppm,
    required this.recordedAt,
  });

  factory CarbonDioxideReadingDto.fromJson(Map<String, dynamic> json) {
    final ppm = json['ppm'];
    if (ppm is! num) {
      throw const FormatException('Unexpected ppm');
    }
    return CarbonDioxideReadingDto(
      deviceId: _deviceId(json),
      ppm: ppm,
      recordedAt: parseIsoDateTime(json['recordedAt'], 'recordedAt'),
    );
  }

  final String deviceId;
  final num ppm;
  final DateTime recordedAt;
}

String _deviceId(Map<String, dynamic> json) {
  final value = json['deviceId'];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw const FormatException('Unexpected deviceId');
}
