import 'iso_date_time.dart';

class ActuatorStateDto {
  const ActuatorStateDto({
    required this.type,
    required this.runState,
    required this.mode,
    required this.lastChangedAt,
  });

  factory ActuatorStateDto.fromJson(Map<String, dynamic> json) {
    return ActuatorStateDto(
      type: _string(json, 'type'),
      runState: _string(json, 'runState'),
      mode: _string(json, 'mode'),
      lastChangedAt: parseIsoDateTime(json['lastChangedAt'], 'lastChangedAt'),
    );
  }

  final String type;
  final String runState;
  final String mode;
  final DateTime lastChangedAt;
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}
