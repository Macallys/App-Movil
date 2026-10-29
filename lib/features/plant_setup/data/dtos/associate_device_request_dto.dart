class AssociateDeviceRequestDto {
  const AssociateDeviceRequestDto({required this.deviceId, required this.kind});

  final String deviceId;
  final String kind;

  Map<String, String> toJson() {
    return {'deviceId': deviceId, 'kind': kind};
  }
}
