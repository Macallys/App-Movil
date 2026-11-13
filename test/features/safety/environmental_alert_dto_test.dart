import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/active_alerts_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/environmental_alert_dto.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/environmental_alert_mapper.dart';

void main() {
  test('parses a valid alert', () {
    final dto = ActiveAlertsResponseDto.fromJson({
      'items': [
        {
          'id': 'alert-1',
          'areaId': 'area-1',
          'raisedAt': '2026-05-20T15:35:00Z',
          'withdrawnAt': null,
        },
      ],
    });

    expect(dto.items.single.id, 'alert-1');
    expect(dto.items.single.areaId, 'area-1');
    expect(dto.items.single.raisedAt, DateTime.utc(2026, 5, 20, 15, 35));
    expect(dto.items.single.withdrawnAt, isNull);
  });

  test('a null identity is rejected', () {
    expect(
      () => EnvironmentalAlertDto.fromJson({
        'id': null,
        'areaId': 'area-1',
        'raisedAt': '2026-05-20T15:35:00Z',
      }),
      throwsFormatException,
    );
  });

  test('mapper keeps raised and withdrawn timestamps', () {
    final alert = const EnvironmentalAlertMapper().toEntity(
      EnvironmentalAlertDto(
        id: 'alert-1',
        areaId: 'area-1',
        raisedAt: DateTime.utc(2026, 5, 20, 15, 35),
        withdrawnAt: DateTime.utc(2026, 5, 20, 16),
      ),
    );

    expect(alert.id, 'alert-1');
    expect(alert.isOpen, isFalse);
    expect(alert.withdrawnAt, DateTime.utc(2026, 5, 20, 16));
  });
}
