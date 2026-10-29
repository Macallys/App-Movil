class IssueDeviceRequestDto {
  const IssueDeviceRequestDto({
    required this.deviceId,
    required this.areaId,
    required this.kind,
  });

  final String deviceId;
  final String areaId;
  final String kind;

  Map<String, String> toJson() {
    return {'deviceId': deviceId, 'areaId': areaId, 'kind': kind};
  }
}
