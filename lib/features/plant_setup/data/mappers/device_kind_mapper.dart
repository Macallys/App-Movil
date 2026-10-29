import '../../domain/entities/area_setup.dart';

DeviceKind deviceKindFromWire(String value) {
  return switch (value) {
    'Sensor' => DeviceKind.sensor,
    'Actuator' => DeviceKind.actuator,
    _ => throw FormatException('Unknown device kind'),
  };
}

String deviceKindToWire(DeviceKind kind) {
  return switch (kind) {
    DeviceKind.sensor => 'Sensor',
    DeviceKind.actuator => 'Actuator',
  };
}
