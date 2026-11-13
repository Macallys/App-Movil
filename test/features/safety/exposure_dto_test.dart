import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/exposure_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/short_exposure_history_response_dto.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/exposure_mapper.dart';

void main() {
  test('parses a complete exposure', () {
    final dto = ShortExposureHistoryResponseDto.fromJson({
      'items': [
        {
          'id': 'exposure-1',
          'areaId': 'area-1',
          'raisedAt': '2026-05-20T15:40:00Z',
          'withdrawnAt': null,
        },
      ],
    });

    expect(dto.items.single.id, 'exposure-1');
    expect(dto.items.single.areaId, 'area-1');
    expect(dto.items.single.raisedAt, DateTime.utc(2026, 5, 20, 15, 40));
    expect(dto.items.single.withdrawnAt, isNull);
  });

  test('empty items stay an empty list', () {
    final dto = ShortExposureHistoryResponseDto.fromJson(const {'items': []});

    expect(dto.items, isEmpty);
  });

  test('a null timestamp is rejected', () {
    expect(
      () => ExposureDto.fromJson({
        'id': 'exposure-1',
        'areaId': 'area-1',
        'raisedAt': null,
      }),
      throwsFormatException,
    );
  });

  test('mapper keeps the documented values', () {
    const mapper = ExposureMapper();
    final exposure = mapper.toEntity(
      ExposureDto(
        id: 'exposure-1',
        areaId: 'area-1',
        raisedAt: DateTime.utc(2026, 5, 20, 15, 40),
      ),
    );

    expect(exposure.id, 'exposure-1');
    expect(exposure.areaId, 'area-1');
    expect(exposure.isOpen, isTrue);
    expect(exposure.raisedAt, DateTime.utc(2026, 5, 20, 15, 40));
  });
}
