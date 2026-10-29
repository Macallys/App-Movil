import 'iso_date_time.dart';

class ExposureDto {
  const ExposureDto({
    required this.exposureId,
    required this.areaId,
    required this.severity,
    required this.recordedAt,
  });

  factory ExposureDto.fromJson(Map<String, dynamic> json) {
    return ExposureDto(
      exposureId: _requiredString(json, 'exposureId'),
      areaId: _requiredString(json, 'areaId'),
      severity: _requiredString(json, 'severity'),
      recordedAt: parseIsoDateTime(json['recordedAt'], 'recordedAt'),
    );
  }

  final String exposureId;
  final String areaId;
  final String severity;
  final DateTime recordedAt;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}
