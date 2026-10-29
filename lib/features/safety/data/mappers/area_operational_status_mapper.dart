import '../../domain/entities/area_operational_status.dart';
import '../dtos/area_operational_status_dto.dart';
import 'actuator_state_mapper.dart';

class AreaOperationalStatusMapper {
  const AreaOperationalStatusMapper({
    this.actuatorMapper = const ActuatorStateMapper(),
  });

  final ActuatorStateMapper actuatorMapper;

  AreaOperationalStatus toEntity(AreaOperationalStatusDto dto) {
    return AreaOperationalStatus(
      areaId: dto.areaId,
      name: dto.name,
      co2Ppm: dto.co2Ppm,
      noiseDb: dto.noiseDb,
      presenceState: presenceStateFromWire(dto.presenceState),
      severity: exposureSeverityFromWire(dto.severity),
      alertActive: dto.alertActive,
      highlighted: dto.highlighted,
      actuators: [
        for (final actuator in dto.actuators) actuatorMapper.toEntity(actuator),
      ],
    );
  }
}

PresenceState? presenceStateFromWire(String? value) {
  return switch (value) {
    null => null,
    'Detected' => PresenceState.detected,
    'Cleared' => PresenceState.cleared,
    _ => throw FormatException('Unknown presence state'),
  };
}

ExposureSeverity exposureSeverityFromWire(String value) {
  return switch (value) {
    'None' => ExposureSeverity.none,
    'Medium' => ExposureSeverity.medium,
    'High' => ExposureSeverity.high,
    _ => throw FormatException('Unknown severity'),
  };
}
