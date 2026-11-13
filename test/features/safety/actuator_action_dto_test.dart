import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/actuator_action_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/actuator_actions_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/actuator_action_mapper.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';

void main() {
  const mapper = ActuatorActionMapper();

  test('parses extractor, siren and barrier with succeeded flag', () {
    final dto = ActuatorActionsResponseDto.fromJson({
      'items': [
        _json('action-1', 'Extractor', true),
        _json('action-2', 'Siren', true),
        _json('action-3', 'Barrier', true),
        _json('action-4', 'Barrier', false),
        _json('action-5', 'Extractor', false),
      ],
    });

    expect(dto.items.map((item) => item.type), [
      'Extractor',
      'Siren',
      'Barrier',
      'Barrier',
      'Extractor',
    ]);
    expect(dto.items.map((item) => item.succeeded), [
      true,
      true,
      true,
      false,
      false,
    ]);
    expect(
      dto.items.map((item) => item.recordedAt),
      everyElement(DateTime.utc(2026, 5, 20, 15, 45)),
    );
  });

  test('empty items stay an empty list', () {
    final dto = ActuatorActionsResponseDto.fromJson(const {'items': []});

    expect(dto.items, isEmpty);
  });

  test('mapper keeps the documented values', () {
    final action = mapper.toEntity(
      ActuatorActionDto(
        id: 'action-3',
        areaId: 'area-1',
        type: 'Barrier',
        succeeded: true,
        recordedAt: DateTime.utc(2026, 5, 20, 15, 45),
      ),
    );

    expect(action.id, 'action-3');
    expect(action.areaId, 'area-1');
    expect(action.type, ActuatorType.barrier);
    expect(action.succeeded, isTrue);
    expect(action.recordedAt, DateTime.utc(2026, 5, 20, 15, 45));
  });

  test('an unknown actuator type fails instead of using a default', () {
    expect(
      () => mapper.toEntity(
        ActuatorActionDto(
          id: 'action-1',
          areaId: 'area-1',
          type: 'Fan',
          succeeded: true,
          recordedAt: DateTime.utc(2026, 5, 20, 15, 45),
        ),
      ),
      throwsFormatException,
    );
  });

  test('a missing timestamp is rejected', () {
    expect(
      () => ActuatorActionDto.fromJson({
        'id': 'action-1',
        'areaId': 'area-1',
        'type': 'Extractor',
        'succeeded': true,
      }),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> _json(String actionId, String type, bool succeeded) {
  return {
    'id': actionId,
    'areaId': 'area-1',
    'type': type,
    'succeeded': succeeded,
    'recordedAt': '2026-05-20T15:45:00Z',
  };
}
