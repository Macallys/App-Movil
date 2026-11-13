import '../../domain/entities/exposure.dart';
import '../dtos/exposure_dto.dart';

class ExposureMapper {
  const ExposureMapper();

  Exposure toEntity(ExposureDto dto) {
    return Exposure(
      id: dto.id,
      areaId: dto.areaId,
      raisedAt: dto.raisedAt,
      withdrawnAt: dto.withdrawnAt,
    );
  }
}
