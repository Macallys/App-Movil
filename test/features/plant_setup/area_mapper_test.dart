import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/area_setup_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/industrial_area_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/area_setup_mapper.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/industrial_area_mapper.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';

void main() {
  test('IndustrialAreaMapper copies the confirmed fields', () {
    final area = const IndustrialAreaMapper().toEntity(
      const IndustrialAreaDto(id: 'area-1', name: 'Horno', location: 'Nave 1'),
    );

    expect(area.id, 'area-1');
    expect(area.name, 'Horno');
    expect(area.location, 'Nave 1');
  });

  test('AreaSetupMapper keeps null limits and device kinds', () {
    final setup = const AreaSetupMapper().toEntity(
      const AreaSetupDto(
        id: 'area-1',
        name: 'Horno',
        location: 'Nave 1',
        co2LimitPpm: null,
        noiseLimitDb: 70,
        devices: [
          AreaDeviceDto(id: 'row-1', deviceId: 'sensor-1', kind: 'Sensor'),
          AreaDeviceDto(id: 'row-2', deviceId: 'fan-1', kind: 'Actuator'),
        ],
      ),
    );

    expect(setup.co2LimitPpm, isNull);
    expect(setup.noiseLimitDb, 70);
    expect(setup.devices[0].kind, DeviceKind.sensor);
    expect(setup.devices[1].kind, DeviceKind.actuator);
  });

  test('an unknown device kind is not treated as a sensor', () {
    expect(
      () => const AreaSetupMapper().toEntity(
        const AreaSetupDto(
          id: 'area-1',
          name: 'Horno',
          location: 'Nave 1',
          co2LimitPpm: null,
          noiseLimitDb: null,
          devices: [AreaDeviceDto(id: 'row-1', deviceId: 'x', kind: 'Gateway')],
        ),
      ),
      throwsFormatException,
    );
  });
}
