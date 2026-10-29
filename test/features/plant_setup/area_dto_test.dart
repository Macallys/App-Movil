import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/area_setup_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/create_area_request_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/industrial_area_dto.dart';

void main() {
  test('CreateAreaRequestDto serializes only name and location', () {
    final json = const CreateAreaRequestDto(
      name: 'Horno',
      location: 'Nave 1',
    ).toJson();

    expect(json, {'name': 'Horno', 'location': 'Nave 1'});
  });

  test('IndustrialAreaDto parses id, name and location', () {
    final dto = IndustrialAreaDto.fromJson({
      'id': 'area-1',
      'name': 'Horno',
      'location': 'Nave 1',
    });

    expect(dto.id, 'area-1');
    expect(dto.name, 'Horno');
    expect(dto.location, 'Nave 1');
  });

  test('AreaSetupDto parses limits and devices', () {
    final dto = AreaSetupDto.fromJson({
      'id': 'area-1',
      'name': 'Horno',
      'location': 'Nave 1',
      'co2LimitPpm': 800,
      'noiseLimitDb': 85.5,
      'devices': [
        {'id': 'row-1', 'deviceId': 'sensor-1', 'kind': 'Sensor'},
      ],
    });

    expect(dto.co2LimitPpm, 800);
    expect(dto.noiseLimitDb, 85.5);
    expect(dto.devices.single.deviceId, 'sensor-1');
    expect(dto.devices.single.kind, 'Sensor');
  });

  test('AreaSetupDto keeps null limits and an empty device list', () {
    final dto = AreaSetupDto.fromJson({
      'id': 'area-1',
      'name': 'Horno',
      'location': 'Nave 1',
      'co2LimitPpm': null,
      'noiseLimitDb': null,
      'devices': [],
    });

    expect(dto.co2LimitPpm, isNull);
    expect(dto.noiseLimitDb, isNull);
    expect(dto.devices, isEmpty);
  });
}
