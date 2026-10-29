import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/actuator_state_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/area_operational_status_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/operational_status_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/actuator_state_mapper.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/area_operational_status_mapper.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';

void main() {
  test('metrics and presence accept values and null', () {
    final withValues = AreaOperationalStatusDto.fromJson(_areaJson());
    final withoutValues = AreaOperationalStatusDto.fromJson(
      _areaJson(
        co2Ppm: null,
        noiseDb: null,
        presenceState: null,
        actuators: [],
      ),
    );

    expect(withValues.co2Ppm, 800);
    expect(withValues.noiseDb, 85.5);
    expect(withValues.presenceState, 'Detected');
    expect(withoutValues.co2Ppm, isNull);
    expect(withoutValues.noiseDb, isNull);
    expect(withoutValues.presenceState, isNull);
    expect(withoutValues.actuators, isEmpty);
  });

  test('presence, severity and actuators map known literals', () {
    expect(presenceStateFromWire('Detected'), PresenceState.detected);
    expect(presenceStateFromWire('Cleared'), PresenceState.cleared);
    expect(presenceStateFromWire(null), isNull);
    expect(exposureSeverityFromWire('None'), ExposureSeverity.none);
    expect(exposureSeverityFromWire('Medium'), ExposureSeverity.medium);
    expect(exposureSeverityFromWire('High'), ExposureSeverity.high);
    expect(actuatorTypeFromWire('Extractor'), ActuatorType.extractor);
    expect(actuatorTypeFromWire('Siren'), ActuatorType.siren);
    expect(actuatorTypeFromWire('Barrier'), ActuatorType.barrier);
    expect(actuatorRunStateFromWire('Off'), ActuatorRunState.off);
    expect(actuatorRunStateFromWire('On'), ActuatorRunState.on);
    expect(actuatorRunStateFromWire('Deployed'), ActuatorRunState.deployed);
    expect(actuatorRunStateFromWire('Retracted'), ActuatorRunState.retracted);
    expect(actuatorRunStateFromWire('Failed'), ActuatorRunState.failed);
    expect(actuatorModeFromWire('Auto'), ActuatorMode.auto);
    expect(actuatorModeFromWire('Overridden'), ActuatorMode.overridden);

    final status = const AreaOperationalStatusMapper().toEntity(
      AreaOperationalStatusDto.fromJson(_areaJson(presenceState: 'Cleared')),
    );
    expect(status.presenceState, PresenceState.cleared);
    expect(status.severity, ExposureSeverity.high);
    expect(status.alertActive, isTrue);
    expect(status.highlighted, isTrue);
    expect(status.actuators.single.type, ActuatorType.barrier);
    expect(status.actuators.single.runState, ActuatorRunState.deployed);
    expect(status.actuators.single.mode, ActuatorMode.overridden);
    expect(status.actuators.single.lastChangedAt, DateTime.utc(2026, 3, 1));
  });

  test('unknown literals fail instead of using a default', () {
    expect(() => presenceStateFromWire('Unknown'), throwsFormatException);
    expect(() => exposureSeverityFromWire('Critical'), throwsFormatException);
    expect(() => actuatorTypeFromWire('Fan'), throwsFormatException);
    expect(() => actuatorRunStateFromWire('Stopped'), throwsFormatException);
    expect(() => actuatorModeFromWire('Manual'), throwsFormatException);
  });

  test('a response envelope parses items', () {
    final response = OperationalStatusResponseDto.fromJson({
      'items': [_areaJson()],
    });

    expect(response.items.single.name, 'Horno');
  });

  test('actuator dates reject a value that is not ISO-8601', () {
    expect(
      () => ActuatorStateDto.fromJson({
        'type': 'Siren',
        'runState': 'Off',
        'mode': 'Auto',
        'lastChangedAt': 'yesterday',
      }),
      throwsFormatException,
    );
  });
}

Map<String, Object?> _areaJson({
  Object? co2Ppm = 800,
  Object? noiseDb = 85.5,
  Object? presenceState = 'Detected',
  List<Map<String, Object?>>? actuators,
}) {
  return {
    'areaId': 'area-1',
    'name': 'Horno',
    'co2Ppm': co2Ppm,
    'noiseDb': noiseDb,
    'presenceState': presenceState,
    'severity': 'High',
    'alertActive': true,
    'highlighted': true,
    'actuators':
        actuators ??
        [
          {
            'type': 'Barrier',
            'runState': 'Deployed',
            'mode': 'Overridden',
            'lastChangedAt': '2026-03-01T00:00:00Z',
          },
        ],
  };
}
