import '../../../../core/error/result.dart';
import '../../domain/entities/industrial_area.dart';
import '../../domain/repositories/plant_setup_repository.dart';

class CreateArea {
  const CreateArea(this._repository);

  final PlantSetupRepository _repository;

  Future<Result<IndustrialArea>> call({
    required String name,
    required String location,
  }) {
    return _repository.createArea(name: name, location: location);
  }
}
