import '../../../../core/error/result.dart';
import '../../domain/entities/device_revocation.dart';
import '../../domain/repositories/plant_setup_repository.dart';

class RevokeDevice {
  const RevokeDevice(this._repository);

  final PlantSetupRepository _repository;

  Future<Result<DeviceRevocation>> call({required String deviceId}) {
    return _repository.revokeDevice(deviceId: deviceId);
  }
}
