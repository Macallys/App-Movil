import 'actuator_state.dart';

enum PresenceState { detected, cleared }

enum ExposureSeverity { none, medium, high }

final class AreaOperationalStatus {
  const AreaOperationalStatus({
    required this.areaId,
    required this.name,
    required this.co2Ppm,
    required this.noiseDb,
    required this.presenceState,
    required this.severity,
    required this.alertActive,
    required this.highlighted,
    required this.actuators,
  });

  final String areaId;
  final String name;
  final num? co2Ppm;
  final num? noiseDb;
  final PresenceState? presenceState;
  final ExposureSeverity severity;
  final bool alertActive;
  final bool highlighted;
  final List<ActuatorState> actuators;
}
