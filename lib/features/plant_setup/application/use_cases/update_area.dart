import '../../../../core/error/result.dart';
import '../../domain/entities/industrial_area.dart';
import '../../domain/repositories/plant_setup_repository.dart';

class UpdateArea {
  const UpdateArea(this._repository);

  final PlantSetupRepository _repository;

  Future<Result<IndustrialArea>> call({
    required String areaId,
    required String name,
    required String location,
  }) {
    return _repository.updateArea(
      areaId: areaId,
      name: name,
      location: location,
    );
  }
}
