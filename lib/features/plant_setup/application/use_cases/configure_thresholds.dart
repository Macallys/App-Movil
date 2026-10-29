import '../../../../core/error/result.dart';
import '../../domain/entities/area_thresholds.dart';
import '../../domain/repositories/plant_setup_repository.dart';

class ConfigureThresholds {
  const ConfigureThresholds(this._repository);

  final PlantSetupRepository _repository;

  Future<Result<AreaThresholds>> call({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) {
    return _repository.configureEnvironmentalThresholds(
      areaId: areaId,
      co2LimitPpm: co2LimitPpm,
      noiseLimitDb: noiseLimitDb,
    );
  }
}
