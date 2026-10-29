import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/active_alerts_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/environmental_alert_dto.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/environmental_alert_mapper.dart';

void main() {
  test('parses a valid alert', () {
    final dto = ActiveAlertsResponseDto.fromJson({
      'items': [
        {
          'alertId': 'alert-1',
          'areaId': 'area-1',
          'severity': 'High',
          'recordedAt': '2026-05-20T15:35:00Z',
        },
      ],
    });

    expect(dto.items.single.alertId, 'alert-1');
    expect(dto.items.single.areaId, 'area-1');
    expect(dto.items.single.severity, 'High');
    expect(dto.items.single.recordedAt, DateTime.utc(2026, 5, 20, 15, 35));
  });

  test('a null identity is rejected', () {
    expect(
      () => EnvironmentalAlertDto.fromJson({
        'alertId': null,
        'areaId': 'area-1',
        'severity': 'Medium',
        'recordedAt': '2026-05-20T15:35:00Z',
      }),
      throwsFormatException,
    );
  });

  test('an unknown severity fails instead of becoming a valid value', () {
    final dto = EnvironmentalAlertDto(
      alertId: 'alert-1',
      areaId: 'area-1',
      severity: 'Critical',
      recordedAt: DateTime.utc(2026, 5, 20, 15, 35),
    );

    expect(
      () => const EnvironmentalAlertMapper().toEntity(dto),
      throwsFormatException,
    );
  });
}
