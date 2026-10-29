import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/actuator_state.dart';
import '../../domain/repositories/safety_repository.dart';

class OverrideActuator {
  const OverrideActuator(this._repository);

  final SafetyRepository _repository;

  Future<Result<ActuatorState>> call({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    if (!_allowed(type, targetState)) {
      return Future.value(const FailureResult(ValidationFailure()));
    }
    return _repository.overrideActuator(
      areaId: areaId,
      type: type,
      targetState: targetState,
    );
  }
}

bool _allowed(ActuatorType type, ActuatorRunState targetState) {
  return switch (type) {
    ActuatorType.extractor || ActuatorType.siren =>
      targetState == ActuatorRunState.off || targetState == ActuatorRunState.on,
    ActuatorType.barrier =>
      targetState == ActuatorRunState.deployed ||
          targetState == ActuatorRunState.retracted,
  };
}
