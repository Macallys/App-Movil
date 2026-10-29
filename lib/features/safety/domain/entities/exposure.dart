import 'area_operational_status.dart';

final class Exposure {
  const Exposure({
    required this.exposureId,
    required this.areaId,
    required this.severity,
    required this.recordedAt,
  });

  final String exposureId;
  final String areaId;
  final ExposureSeverity severity;
  final DateTime recordedAt;
}
