import '../../domain/entities/area_setup.dart';
import '../dtos/area_setup_dto.dart';
import 'device_kind_mapper.dart';

class AreaSetupMapper {
  const AreaSetupMapper();

  AreaSetup toEntity(AreaSetupDto dto) {
    return AreaSetup(
      id: dto.id,
      name: dto.name,
      location: dto.location,
      co2LimitPpm: dto.co2LimitPpm,
      noiseLimitDb: dto.noiseLimitDb,
      devices: dto.devices.map(_device).toList(),
    );
  }

  AreaDevice _device(AreaDeviceDto dto) {
    return AreaDevice(
      id: dto.id,
      deviceId: dto.deviceId,
      kind: deviceKindFromWire(dto.kind),
    );
  }
}
