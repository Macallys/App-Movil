import '../../domain/entities/area_thresholds.dart';
import '../dtos/area_thresholds_dto.dart';

class AreaThresholdsMapper {
  const AreaThresholdsMapper();

  AreaThresholds toEntity(AreaThresholdsDto dto) {
    return AreaThresholds(
      areaId: dto.areaId,
      co2LimitPpm: dto.co2LimitPpm,
      noiseLimitDb: dto.noiseLimitDb,
    );
  }
}
