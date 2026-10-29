class DeviceAssociationDto {
  const DeviceAssociationDto({
    required this.id,
    required this.areaId,
    required this.deviceId,
    required this.kind,
  });

  factory DeviceAssociationDto.fromJson(Map<String, dynamic> json) {
    return DeviceAssociationDto(
      id: _required(json, 'id'),
      areaId: _required(json, 'areaId'),
      deviceId: _required(json, 'deviceId'),
      kind: _required(json, 'kind'),
    );
  }

  final String id;
  final String areaId;
  final String deviceId;
  final String kind;
}

String _required(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}
