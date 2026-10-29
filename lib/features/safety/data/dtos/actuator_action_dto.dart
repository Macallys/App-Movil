import 'iso_date_time.dart';

class ActuatorActionDto {
  const ActuatorActionDto({
    required this.actionId,
    required this.areaId,
    required this.type,
    required this.runState,
    required this.executedAt,
  });

  factory ActuatorActionDto.fromJson(Map<String, dynamic> json) {
    return ActuatorActionDto(
      actionId: _requiredString(json, 'actionId'),
      areaId: _requiredString(json, 'areaId'),
      type: _requiredString(json, 'type'),
      runState: _requiredString(json, 'runState'),
      executedAt: parseIsoDateTime(json['executedAt'], 'executedAt'),
    );
  }

  final String actionId;
  final String areaId;
  final String type;
  final String runState;
  final DateTime executedAt;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}
