import '../../domain/entities/actuator_action.dart';
import '../dtos/actuator_action_dto.dart';
import 'actuator_state_mapper.dart';

class ActuatorActionMapper {
  const ActuatorActionMapper();

  ActuatorAction toEntity(ActuatorActionDto dto) {
    return ActuatorAction(
      actionId: dto.actionId,
      areaId: dto.areaId,
      type: actuatorTypeFromWire(dto.type),
      runState: actuatorRunStateFromWire(dto.runState),
      executedAt: dto.executedAt,
    );
  }
}
