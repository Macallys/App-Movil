import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/area_thresholds_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/configure_thresholds_request_dto.dart';

void main() {
  test('request serializes only the two limits', () {
    final json = const ConfigureThresholdsRequestDto(
      co2LimitPpm: 800,
      noiseLimitDb: 85.5,
    ).toJson();

    expect(json.keys, ['co2LimitPpm', 'noiseLimitDb']);
    expect(json['co2LimitPpm'], 800);
    expect(json['noiseLimitDb'], 85.5);
    expect(json.containsKey('areaId'), isFalse);
  });

  test('response parses integers and decimals', () {
    final integers = AreaThresholdsDto.fromJson({
      'areaId': 'area-1',
      'co2LimitPpm': 800,
      'noiseLimitDb': 70,
    });
    final decimals = AreaThresholdsDto.fromJson({
      'areaId': 'area-1',
      'co2LimitPpm': 800.5,
      'noiseLimitDb': 85.5,
    });

    expect(integers.co2LimitPpm, 800);
    expect(integers.noiseLimitDb, 70);
    expect(decimals.co2LimitPpm, 800.5);
    expect(decimals.noiseLimitDb, 85.5);
    expect(decimals.noiseLimitDb, isNot(85));
  });
}
