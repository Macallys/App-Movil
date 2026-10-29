import 'actuator_state_dto.dart';

class AreaOperationalStatusDto {
  const AreaOperationalStatusDto({
    required this.areaId,
    required this.name,
    required this.co2Ppm,
    required this.noiseDb,
    required this.presenceState,
    required this.severity,
    required this.alertActive,
    required this.highlighted,
    required this.actuators,
  });

  factory AreaOperationalStatusDto.fromJson(Map<String, dynamic> json) {
    final actuators = json['actuators'];
    if (actuators is! List) {
      throw const FormatException('Unexpected actuators');
    }
    return AreaOperationalStatusDto(
      areaId: _string(json, 'areaId'),
      name: _string(json, 'name'),
      co2Ppm: _optionalNum(json, 'co2Ppm'),
      noiseDb: _optionalNum(json, 'noiseDb'),
      presenceState: _optionalString(json, 'presenceState'),
      severity: _string(json, 'severity'),
      alertActive: _bool(json, 'alertActive'),
      highlighted: _bool(json, 'highlighted'),
      actuators: [
        for (final actuator in actuators)
          ActuatorStateDto.fromJson(_map(actuator)),
      ],
    );
  }

  final String areaId;
  final String name;
  final num? co2Ppm;
  final num? noiseDb;
  final String? presenceState;
  final String severity;
  final bool alertActive;
  final bool highlighted;
  final List<ActuatorStateDto> actuators;
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}

String? _optionalString(Map<String, dynamic> json, String key) {
  if (!json.containsKey(key) || json[key] == null) {
    return null;
  }
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}

num? _optionalNum(Map<String, dynamic> json, String key) {
  if (!json.containsKey(key) || json[key] == null) {
    return null;
  }
  final value = json[key];
  if (value is num) {
    return value;
  }
  throw FormatException('Unexpected $key');
}

bool _bool(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is bool) {
    return value;
  }
  throw FormatException('Unexpected $key');
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  throw const FormatException('Unexpected actuators');
}
