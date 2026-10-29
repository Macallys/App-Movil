import 'area_setup.dart';

final class DeviceAssociation {
  const DeviceAssociation({
    required this.id,
    required this.areaId,
    required this.deviceId,
    required this.kind,
  });

  final String id;
  final String areaId;
  final String deviceId;
  final DeviceKind kind;
}
