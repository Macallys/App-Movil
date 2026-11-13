import 'iso_date_time.dart';

class ExposureDto {
  const ExposureDto({
    required this.id,
    required this.areaId,
    required this.raisedAt,
    this.withdrawnAt,
  });

  factory ExposureDto.fromJson(Map<String, dynamic> json) {
    return ExposureDto(
      id: _requiredString(json, 'id'),
      areaId: _requiredString(json, 'areaId'),
      raisedAt: parseIsoDateTime(json['raisedAt'], 'raisedAt'),
      withdrawnAt: parseOptionalIsoDateTime(json, 'withdrawnAt'),
    );
  }

  final String id;
  final String areaId;
  final DateTime raisedAt;
  final DateTime? withdrawnAt;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}
