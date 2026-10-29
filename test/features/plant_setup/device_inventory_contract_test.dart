import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/device_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/revoke_device_response_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/mappers/device_mapper.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';

void main() {
  test('a null revokedAt stays active', () {
    final device = const DeviceMapper().fromInventory(
      DeviceDto(
        deviceId: 'dev-1',
        areaId: 'area-1',
        kind: 'Sensor',
        issuedAt: DateTime.utc(2026, 1, 1),
        expiresAt: DateTime.utc(2026, 2, 1),
        revokedAt: null,
      ),
    );

    expect(device.revokedAt, isNull);
    expect(device.isRevoked, isFalse);
    expect(device.kind, DeviceKind.sensor);
  });

  test('revokedAt parses an ISO-8601 instant', () {
    final dto = DeviceDto.fromJson({
      'deviceId': 'dev-1',
      'areaId': 'area-1',
      'kind': 'Actuator',
      'issuedAt': '2026-01-01T00:00:00Z',
      'expiresAt': '2026-02-01T00:00:00Z',
      'revokedAt': '2026-03-01T12:30:00Z',
      'lastSeenAt': '2026-03-02T00:00:00Z',
      'model': 'ignored',
      'firmwareVersion': 'ignored',
    });
    final device = const DeviceMapper().fromInventory(dto);

    expect(device.kind, DeviceKind.actuator);
    expect(device.revokedAt, DateTime.utc(2026, 3, 1, 12, 30));
    expect(device.isRevoked, isTrue);
  });

  test('an unknown kind fails instead of becoming a sensor', () {
    expect(
      () => const DeviceMapper().fromInventory(
        DeviceDto(
          deviceId: 'dev-1',
          areaId: 'area-1',
          kind: 'Extractor',
          issuedAt: DateTime.utc(2026),
          expiresAt: DateTime.utc(2026, 2),
          revokedAt: null,
        ),
      ),
      throwsFormatException,
    );
  });

  test('revoke response parses deviceId and revokedAt', () {
    final dto = RevokeDeviceResponseDto.fromJson({
      'deviceId': 'dev-1',
      'revokedAt': '2026-03-01T00:00:00Z',
    });
    final revocation = const DeviceMapper().toRevocation(dto);

    expect(revocation.deviceId, 'dev-1');
    expect(revocation.revokedAt, DateTime.utc(2026, 3, 1));
  });
}
