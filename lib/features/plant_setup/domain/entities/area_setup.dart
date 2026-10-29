enum DeviceKind { sensor, actuator }

/// Device row returned inside an area setup sheet.
/// It is not the device lifecycle model.
final class AreaDevice {
  const AreaDevice({
    required this.id,
    required this.deviceId,
    required this.kind,
  });

  final String id;
  final String deviceId;
  final DeviceKind kind;
}

final class AreaSetup {
  const AreaSetup({
    required this.id,
    required this.name,
    required this.location,
    required this.co2LimitPpm,
    required this.noiseLimitDb,
    required this.devices,
  });

  final String id;
  final String name;
  final String location;
  final num? co2LimitPpm;
  final num? noiseLimitDb;
  final List<AreaDevice> devices;
}
