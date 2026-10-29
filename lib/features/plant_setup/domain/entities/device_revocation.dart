final class DeviceRevocation {
  const DeviceRevocation({required this.deviceId, required this.revokedAt});

  final String deviceId;
  final DateTime revokedAt;
}
