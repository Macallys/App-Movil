import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/exposure_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/short_exposure_history_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/exposure_mapper.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';

void main() {
  test('parses a complete exposure', () {
    final dto = ShortExposureHistoryResponseDto.fromJson({
      'items': [
        {
          'exposureId': 'exposure-1',
          'areaId': 'area-1',
          'severity': 'High',
          'recordedAt': '2026-05-20T15:40:00Z',
        },
      ],
    });

    expect(dto.items.single.exposureId, 'exposure-1');
    expect(dto.items.single.areaId, 'area-1');
    expect(dto.items.single.severity, 'High');
    expect(dto.items.single.recordedAt, DateTime.utc(2026, 5, 20, 15, 40));
  });

  test('empty items stay an empty list', () {
    final dto = ShortExposureHistoryResponseDto.fromJson(const {'items': []});

    expect(dto.items, isEmpty);
  });

  test('a null timestamp is rejected', () {
    expect(
      () => ExposureDto.fromJson({
        'exposureId': 'exposure-1',
        'areaId': 'area-1',
        'severity': 'Medium',
        'recordedAt': null,
      }),
      throwsFormatException,
    );
  });

  test('mapper keeps the documented values', () {
    const mapper = ExposureMapper();
    final exposure = mapper.toEntity(
      ExposureDto(
        exposureId: 'exposure-1',
        areaId: 'area-1',
        severity: 'None',
        recordedAt: DateTime.utc(2026, 5, 20, 15, 40),
      ),
    );

    expect(exposure.exposureId, 'exposure-1');
    expect(exposure.areaId, 'area-1');
    expect(exposure.severity, ExposureSeverity.none);
    expect(exposure.recordedAt, DateTime.utc(2026, 5, 20, 15, 40));
  });

  test('an unknown severity fails instead of using a default', () {
    expect(
      () => const ExposureMapper().toEntity(
        ExposureDto(
          exposureId: 'exposure-1',
          areaId: 'area-1',
          severity: 'Critical',
          recordedAt: DateTime.utc(2026, 5, 20, 15, 40),
        ),
      ),
      throwsFormatException,
    );
  });
}
