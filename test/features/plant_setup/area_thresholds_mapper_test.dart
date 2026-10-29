import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/area_thresholds_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/area_thresholds_mapper.dart';

void main() {
  test('AreaThresholdsMapper keeps the exact numbers', () {
    final thresholds = const AreaThresholdsMapper().toEntity(
      const AreaThresholdsDto(
        areaId: 'area-1',
        co2LimitPpm: 800.5,
        noiseLimitDb: 85.5,
      ),
    );

    expect(thresholds.areaId, 'area-1');
    expect(thresholds.co2LimitPpm, 800.5);
    expect(thresholds.noiseLimitDb, 85.5);
  });
}
