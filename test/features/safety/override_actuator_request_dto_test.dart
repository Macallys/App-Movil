import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/override_actuator_request_dto.dart';

void main() {
  test('request contains only actuatorType and run state', () {
    const cases = [
      ('Extractor', 'On'),
      ('Extractor', 'Off'),
      ('Siren', 'On'),
      ('Siren', 'Off'),
      ('Barrier', 'Deployed'),
      ('Barrier', 'Retracted'),
    ];

    for (final (type, runState) in cases) {
      final json = OverrideActuatorRequestDto(
        actuatorType: type,
        runState: runState,
      ).toJson();
      expect(json.keys, ['actuatorType', 'runState']);
      expect(json, {'actuatorType': type, 'runState': runState});
      expect(json.containsKey('type'), isFalse);
      expect(json.containsKey('reason'), isFalse);
      expect(json.containsKey('duration'), isFalse);
      expect(json.containsKey('priority'), isFalse);
      expect(json.containsKey('requestedBy'), isFalse);
      expect(json.containsKey('overrideId'), isFalse);
    }
  });
}
