class AreaThresholdsDto {
  const AreaThresholdsDto({
    required this.areaId,
    required this.co2LimitPpm,
    required this.noiseLimitDb,
  });

  factory AreaThresholdsDto.fromJson(Map<String, dynamic> json) {
    return AreaThresholdsDto(
      areaId: _string(json, 'areaId'),
      co2LimitPpm: _number(json, 'co2LimitPpm'),
      noiseLimitDb: _number(json, 'noiseLimitDb'),
    );
  }

  final String areaId;
  final num co2LimitPpm;
  final num noiseLimitDb;
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}

num _number(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) {
    return value;
  }
  throw FormatException('Unexpected $key');
}
