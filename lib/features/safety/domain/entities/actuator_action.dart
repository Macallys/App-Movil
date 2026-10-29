import 'actuator_state.dart';

final class ActuatorAction {
  const ActuatorAction({
    required this.actionId,
    required this.areaId,
    required this.type,
    required this.runState,
    required this.executedAt,
  });

  final String actionId;
  final String areaId;
  final ActuatorType type;
  final ActuatorRunState runState;
  final DateTime executedAt;
}
