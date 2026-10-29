import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/actuator_action_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/actuator_actions_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/actuator_action_mapper.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';

void main() {
  const mapper = ActuatorActionMapper();

  test('parses extractor, siren and barrier with every run state', () {
    final dto = ActuatorActionsResponseDto.fromJson({
      'items': [
        _json('action-1', 'Extractor', 'Off'),
        _json('action-2', 'Siren', 'On'),
        _json('action-3', 'Barrier', 'Deployed'),
        _json('action-4', 'Barrier', 'Retracted'),
        _json('action-5', 'Extractor', 'Failed'),
      ],
    });

    expect(dto.items.map((item) => item.type), [
      'Extractor',
      'Siren',
      'Barrier',
      'Barrier',
      'Extractor',
    ]);
    expect(dto.items.map((item) => item.runState), [
      'Off',
      'On',
      'Deployed',
      'Retracted',
      'Failed',
    ]);
    expect(
      dto.items.map((item) => item.executedAt),
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
        actionId: 'action-3',
        areaId: 'area-1',
        type: 'Barrier',
        runState: 'Deployed',
        executedAt: DateTime.utc(2026, 5, 20, 15, 45),
      ),
    );

    expect(action.actionId, 'action-3');
    expect(action.areaId, 'area-1');
    expect(action.type, ActuatorType.barrier);
    expect(action.runState, ActuatorRunState.deployed);
    expect(action.executedAt, DateTime.utc(2026, 5, 20, 15, 45));
  });

  test('every documented run state maps without collapsing to a boolean', () {
    const states = {
      'Off': ActuatorRunState.off,
      'On': ActuatorRunState.on,
      'Deployed': ActuatorRunState.deployed,
      'Retracted': ActuatorRunState.retracted,
      'Failed': ActuatorRunState.failed,
    };

    for (final entry in states.entries) {
      final action = mapper.toEntity(
        ActuatorActionDto(
          actionId: entry.key,
          areaId: 'area-1',
          type: 'Siren',
          runState: entry.key,
          executedAt: DateTime.utc(2026, 5, 20, 15, 45),
        ),
      );
      expect(action.runState, entry.value);
    }
  });

  test('an unknown actuator type fails instead of using a default', () {
    expect(
      () => mapper.toEntity(
        ActuatorActionDto(
          actionId: 'action-1',
          areaId: 'area-1',
          type: 'Fan',
          runState: 'On',
          executedAt: DateTime.utc(2026, 5, 20, 15, 45),
        ),
      ),
      throwsFormatException,
    );
  });

  test('an unknown run state fails instead of using a default', () {
    expect(
      () => mapper.toEntity(
        ActuatorActionDto(
          actionId: 'action-1',
          areaId: 'area-1',
          type: 'Barrier',
          runState: 'Open',
          executedAt: DateTime.utc(2026, 5, 20, 15, 45),
        ),
      ),
      throwsFormatException,
    );
  });

  test('a missing timestamp is rejected', () {
    expect(
      () => ActuatorActionDto.fromJson({
        'actionId': 'action-1',
        'areaId': 'area-1',
        'type': 'Extractor',
        'runState': 'Off',
      }),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> _json(String actionId, String type, String runState) {
  return {
    'actionId': actionId,
    'areaId': 'area-1',
    'type': type,
    'runState': runState,
    'executedAt': '2026-05-20T15:45:00Z',
  };
}
