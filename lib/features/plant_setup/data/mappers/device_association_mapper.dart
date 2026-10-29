import '../../domain/entities/device_association.dart';
import '../dtos/device_association_dto.dart';
import 'device_kind_mapper.dart';

class DeviceAssociationMapper {
  const DeviceAssociationMapper();

  DeviceAssociation toEntity(DeviceAssociationDto dto) {
    return DeviceAssociation(
      id: dto.id,
      areaId: dto.areaId,
      deviceId: dto.deviceId,
      kind: deviceKindFromWire(dto.kind),
    );
  }
}
