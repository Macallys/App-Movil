import 'area_setup.dart';

final class Device {
  const Device({
    required this.deviceId,
    required this.issuedAt,
    required this.expiresAt,
    this.areaId,
    this.kind,
    this.revokedAt,
  });

  final String deviceId;
  final String? areaId;
  final DeviceKind? kind;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final DateTime? revokedAt;

  bool get isRevoked => revokedAt != null;

  Device withRevocation(DateTime revokedAt) {
    return Device(
      deviceId: deviceId,
      areaId: areaId,
      kind: kind,
      issuedAt: issuedAt,
      expiresAt: expiresAt,
      revokedAt: revokedAt,
    );
  }
}
