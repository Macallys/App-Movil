import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/area_setup.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_association.dart';
import '../../domain/repositories/plant_setup_repository.dart';

enum RegisterDevicePhase { issuing, associating }

sealed class RegisterDeviceResult {
  const RegisterDeviceResult();
}

final class RegisterDeviceSuccess extends RegisterDeviceResult {
  const RegisterDeviceSuccess({
    required this.device,
    required this.association,
  });

  final Device device;
  final DeviceAssociation association;
}

final class RegisterDeviceIssueFailed extends RegisterDeviceResult {
  const RegisterDeviceIssueFailed(this.failure);

  final Failure failure;
}

final class RegisterDeviceAssociationFailed extends RegisterDeviceResult {
  const RegisterDeviceAssociationFailed({
    required this.device,
    required this.failure,
  });

  final Device device;
  final Failure failure;
}

class RegisterDevice {
  const RegisterDevice(this._repository);

  final PlantSetupRepository _repository;

  Future<RegisterDeviceResult> call({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
    void Function(RegisterDevicePhase phase)? onPhase,
  }) async {
    onPhase?.call(RegisterDevicePhase.issuing);
    final issued = await _repository.issueDevice(
      deviceId: deviceId,
      areaId: areaId,
      kind: kind,
    );
    if (issued case FailureResult(:final failure)) {
      return RegisterDeviceIssueFailed(failure);
    }
    final device = (issued as Success<Device>).value;
    onPhase?.call(RegisterDevicePhase.associating);
    final associated = await associate(
      areaId: areaId,
      deviceId: deviceId,
      kind: kind,
    );
    return switch (associated) {
      Success(:final value) => RegisterDeviceSuccess(
        device: device,
        association: value,
      ),
      FailureResult(:final failure) => RegisterDeviceAssociationFailed(
        device: device,
        failure: failure,
      ),
    };
  }

  Future<Result<DeviceAssociation>> associate({
    required String areaId,
    required String deviceId,
    required DeviceKind kind,
  }) {
    return _repository.associateDeviceToArea(
      areaId: areaId,
      deviceId: deviceId,
      kind: kind,
    );
  }
}
