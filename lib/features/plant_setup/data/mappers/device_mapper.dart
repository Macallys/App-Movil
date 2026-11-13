import '../../domain/entities/device.dart';
import '../../domain/entities/device_revocation.dart';
import '../../domain/entities/issued_device.dart';
import '../dtos/device_dto.dart';
import '../dtos/issue_device_response_dto.dart';
import '../dtos/revoke_device_response_dto.dart';
import 'device_kind_mapper.dart';

class DeviceMapper {
  const DeviceMapper();

  IssuedDevice toIssued(IssueDeviceResponseDto dto) {
    return IssuedDevice(
      device: Device(
        deviceId: dto.deviceId,
        issuedAt: dto.issuedAt,
        expiresAt: dto.expiresAt,
      ),
      secret: dto.secret,
    );
  }

  Device fromInventory(DeviceDto dto) {
    return Device(
      deviceId: dto.deviceId,
      areaId: dto.areaId,
      kind: deviceKindFromWire(dto.kind),
      issuedAt: dto.issuedAt,
      expiresAt: dto.expiresAt,
      revokedAt: dto.revokedAt,
      lastSeenAt: dto.lastSeenAt,
    );
  }

  DeviceRevocation toRevocation(RevokeDeviceResponseDto dto) {
    return DeviceRevocation(deviceId: dto.deviceId, revokedAt: dto.revokedAt);
  }
}
