import '../../domain/entities/actuator_state.dart';
import '../dtos/actuator_state_dto.dart';

class ActuatorStateMapper {
  const ActuatorStateMapper();

  ActuatorState toEntity(ActuatorStateDto dto) {
    return ActuatorState(
      type: actuatorTypeFromWire(dto.type),
      runState: actuatorRunStateFromWire(dto.runState),
      mode: actuatorModeFromWire(dto.mode),
      lastChangedAt: dto.lastChangedAt,
    );
  }
}

ActuatorType actuatorTypeFromWire(String value) {
  return switch (value) {
    'Extractor' => ActuatorType.extractor,
    'Siren' => ActuatorType.siren,
    'Barrier' => ActuatorType.barrier,
    _ => throw FormatException('Unknown actuator type'),
  };
}

ActuatorRunState actuatorRunStateFromWire(String value) {
  return switch (value) {
    'Off' => ActuatorRunState.off,
    'On' => ActuatorRunState.on,
    'Deployed' => ActuatorRunState.deployed,
    'Retracted' => ActuatorRunState.retracted,
    'Failed' => ActuatorRunState.failed,
    _ => throw FormatException('Unknown actuator run state'),
  };
}

String actuatorTypeToWire(ActuatorType type) {
  return switch (type) {
    ActuatorType.extractor => 'Extractor',
    ActuatorType.siren => 'Siren',
    ActuatorType.barrier => 'Barrier',
  };
}

String actuatorRunStateToWire(ActuatorRunState state) {
  return switch (state) {
    ActuatorRunState.off => 'Off',
    ActuatorRunState.on => 'On',
    ActuatorRunState.deployed => 'Deployed',
    ActuatorRunState.retracted => 'Retracted',
    ActuatorRunState.failed => 'Failed',
  };
}

ActuatorMode actuatorModeFromWire(String value) {
  return switch (value) {
    'Auto' => ActuatorMode.auto,
    'Overridden' => ActuatorMode.overridden,
    _ => throw FormatException('Unknown actuator mode'),
  };
}
