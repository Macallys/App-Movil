import '../../../../core/error/result.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/plant_setup_repository.dart';

class ListDevices {
  const ListDevices(this._repository);

  final PlantSetupRepository _repository;

  Future<Result<List<Device>>> call() {
    return _repository.listDevices();
  }
}
