import '../../../../core/error/result.dart';
import '../../domain/entities/area_setup.dart';
import '../../domain/repositories/plant_setup_repository.dart';

class GetAreaSetup {
  const GetAreaSetup(this._repository);

  final PlantSetupRepository _repository;

  Future<Result<AreaSetup>> call({required String areaId}) {
    return _repository.getAreaSetup(areaId: areaId);
  }
}
