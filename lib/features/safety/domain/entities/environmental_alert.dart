import 'area_operational_status.dart';

final class EnvironmentalAlert {
  const EnvironmentalAlert({
    required this.alertId,
    required this.areaId,
    required this.severity,
    required this.recordedAt,
  });

  final String alertId;
  final String areaId;
  final ExposureSeverity severity;
  final DateTime recordedAt;
}
