import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/override_actuator_request_dto.dart';

void main() {
  test('request contains only type and run state', () {
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
        type: type,
        runState: runState,
      ).toJson();
      expect(json.keys, ['type', 'runState']);
      expect(json, {'type': type, 'runState': runState});
      expect(json.containsKey('reason'), isFalse);
      expect(json.containsKey('duration'), isFalse);
      expect(json.containsKey('priority'), isFalse);
      expect(json.containsKey('requestedBy'), isFalse);
      expect(json.containsKey('overrideId'), isFalse);
    }
  });
}
