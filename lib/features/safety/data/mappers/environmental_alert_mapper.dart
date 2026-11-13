import '../../domain/entities/environmental_alert.dart';
import '../dtos/environmental_alert_dto.dart';

class EnvironmentalAlertMapper {
  const EnvironmentalAlertMapper();

  EnvironmentalAlert toEntity(EnvironmentalAlertDto dto) {
    return EnvironmentalAlert(
      id: dto.id,
      areaId: dto.areaId,
      raisedAt: dto.raisedAt,
      withdrawnAt: dto.withdrawnAt,
    );
  }
}
