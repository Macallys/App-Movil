import 'iso_date_time.dart';

class EnvironmentalAlertDto {
  const EnvironmentalAlertDto({
    required this.alertId,
    required this.areaId,
    required this.severity,
    required this.recordedAt,
  });

  factory EnvironmentalAlertDto.fromJson(Map<String, dynamic> json) {
    return EnvironmentalAlertDto(
      alertId: _requiredString(json, 'alertId'),
      areaId: _requiredString(json, 'areaId'),
      severity: _requiredString(json, 'severity'),
      recordedAt: parseIsoDateTime(json['recordedAt'], 'recordedAt'),
    );
  }

  final String alertId;
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
