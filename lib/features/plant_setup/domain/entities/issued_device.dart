import 'device.dart';

/// Credencial emitida. El [secret] vive solo en memoria de la UI de emisión.
final class IssuedDevice {
  const IssuedDevice({required this.device, required this.secret});

  final Device device;
  final String secret;
}
