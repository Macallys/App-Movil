import 'iso_date_time.dart';

class NoiseReadingDto {
  const NoiseReadingDto({
    required this.deviceId,
    required this.db,
    required this.recordedAt,
  });

  factory NoiseReadingDto.fromJson(Map<String, dynamic> json) {
    final db = json['db'];
    if (db is! num || db != db.roundToDouble()) {
      throw const FormatException('Unexpected db');
    }
    return NoiseReadingDto(
      deviceId: _requiredString(json, 'deviceId'),
      db: db.toInt(),
      recordedAt: parseIsoDateTime(json['recordedAt'], 'recordedAt'),
    );
  }

  final String deviceId;
  final int db;
  final DateTime recordedAt;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}
