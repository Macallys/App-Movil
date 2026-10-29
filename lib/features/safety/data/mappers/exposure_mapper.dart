import '../../domain/entities/exposure.dart';
import '../dtos/exposure_dto.dart';
import 'area_operational_status_mapper.dart';

class ExposureMapper {
  const ExposureMapper();

  Exposure toEntity(ExposureDto dto) {
    return Exposure(
      exposureId: dto.exposureId,
      areaId: dto.areaId,
      severity: exposureSeverityFromWire(dto.severity),
      recordedAt: dto.recordedAt,
    );
  }
}
