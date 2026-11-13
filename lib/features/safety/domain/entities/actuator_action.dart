import 'actuator_state.dart';

final class ActuatorAction {
  const ActuatorAction({
    required this.id,
    required this.areaId,
    required this.type,
    required this.succeeded,
    required this.recordedAt,
  });

  final String id;
  final String areaId;
  final ActuatorType type;
  final bool succeeded;
  final DateTime recordedAt;
}
