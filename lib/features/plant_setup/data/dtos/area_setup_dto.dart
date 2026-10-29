class AreaDeviceDto {
  const AreaDeviceDto({
    required this.id,
    required this.deviceId,
    required this.kind,
  });

  factory AreaDeviceDto.fromJson(Map<String, dynamic> json) {
    return AreaDeviceDto(
      id: _requiredString(json, 'id'),
      deviceId: _requiredString(json, 'deviceId'),
      kind: _requiredString(json, 'kind'),
    );
  }

  final String id;
  final String deviceId;
  final String kind;
}

class AreaSetupDto {
  const AreaSetupDto({
    required this.id,
    required this.name,
    required this.location,
    required this.co2LimitPpm,
    required this.noiseLimitDb,
    required this.devices,
  });

  factory AreaSetupDto.fromJson(Map<String, dynamic> json) {
    return AreaSetupDto(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      location: _requiredString(json, 'location'),
      co2LimitPpm: _optionalNumber(json, 'co2LimitPpm'),
      noiseLimitDb: _optionalNumber(json, 'noiseLimitDb'),
      devices: _devices(json),
    );
  }

  final String id;
  final String name;
  final String location;
  final num? co2LimitPpm;
  final num? noiseLimitDb;
  final List<AreaDeviceDto> devices;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}

num? _optionalNumber(Map<String, dynamic> json, String key) {
  if (!json.containsKey(key)) {
    throw FormatException('Missing $key');
  }
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value;
  }
  throw FormatException('Unexpected $key');
}

List<AreaDeviceDto> _devices(Map<String, dynamic> json) {
  final value = json['devices'];
  if (value is! List) {
    throw const FormatException('Unexpected devices');
  }
  return value.map((item) {
    if (item is! Map) {
      throw const FormatException('Unexpected device');
    }
    return AreaDeviceDto.fromJson(Map<String, dynamic>.from(item));
  }).toList();
}
