import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/associate_device_request_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/device_association_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/issue_device_request_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/issue_device_response_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/device_association_mapper.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/device_kind_mapper.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/device_mapper.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';

void main() {
  test('issue request contains only deviceId, areaId and kind', () {
    final json = const IssueDeviceRequestDto(
      deviceId: 'dev-1',
      areaId: 'area-1',
      kind: 'Sensor',
    ).toJson();

    expect(json.keys.toSet(), {'deviceId', 'areaId', 'kind'});
    expect(json['model'], isNull);
    expect(json['firmwareVersion'], isNull);
    expect(json['secret'], isNull);
  });

  test('associate request contains only deviceId and kind', () {
    final json = const AssociateDeviceRequestDto(
      deviceId: 'dev-1',
      kind: 'Actuator',
    ).toJson();

    expect(json.keys.toSet(), {'deviceId', 'kind'});
    expect(json.containsKey('areaId'), isFalse);
    expect(json['model'], isNull);
    expect(json['firmwareVersion'], isNull);
    expect(json['secret'], isNull);
  });

  test('issue response parses the confirmed fields and ignores secret', () {
    final dto = IssueDeviceResponseDto.fromJson({
      'deviceId': 'dev-1',
      'issuedAt': '2026-01-01T00:00:00Z',
      'expiresAt': '2026-02-01T00:00:00Z',
      'secret': 'not-a-field',
    });

    final device = const DeviceMapper().toEntity(dto);
    expect(device.deviceId, 'dev-1');
    expect(device.issuedAt, DateTime.utc(2026, 1, 1));
    expect(device.expiresAt, DateTime.utc(2026, 2, 1));
  });

  test('Sensor and Actuator map to the domain kind', () {
    expect(deviceKindFromWire('Sensor'), DeviceKind.sensor);
    expect(deviceKindFromWire('Actuator'), DeviceKind.actuator);
    expect(deviceKindToWire(DeviceKind.sensor), 'Sensor');
    expect(deviceKindToWire(DeviceKind.actuator), 'Actuator');
  });

  test('an unknown kind fails instead of becoming a sensor', () {
    expect(() => deviceKindFromWire('CO2'), throwsFormatException);
    expect(
      () => const DeviceAssociationMapper().toEntity(
        const DeviceAssociationDto(
          id: 'assoc-1',
          areaId: 'area-1',
          deviceId: 'dev-1',
          kind: 'Extractor',
        ),
      ),
      throwsFormatException,
    );
  });
}
