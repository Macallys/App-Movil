import '../../domain/entities/environmental_alert.dart';
import '../dtos/environmental_alert_dto.dart';
import 'area_operational_status_mapper.dart';

class EnvironmentalAlertMapper {
  const EnvironmentalAlertMapper();

  EnvironmentalAlert toEntity(EnvironmentalAlertDto dto) {
    return EnvironmentalAlert(
      alertId: dto.alertId,
      areaId: dto.areaId,
      severity: exposureSeverityFromWire(dto.severity),
      recordedAt: dto.recordedAt,
    );
  }
}
