import 'iso_date_time.dart';

class ActuatorActionDto {
  const ActuatorActionDto({
    required this.id,
    required this.areaId,
    required this.type,
    required this.succeeded,
    required this.recordedAt,
  });

  factory ActuatorActionDto.fromJson(Map<String, dynamic> json) {
    final succeeded = json['succeeded'];
    if (succeeded is! bool) {
      throw const FormatException('Unexpected succeeded');
    }
    return ActuatorActionDto(
      id: _requiredString(json, 'id'),
      areaId: _requiredString(json, 'areaId'),
      type: _requiredString(json, 'type'),
      succeeded: succeeded,
      recordedAt: parseIsoDateTime(json['recordedAt'], 'recordedAt'),
    );
  }

  final String id;
  final String areaId;
  final String type;
  final bool succeeded;
  final DateTime recordedAt;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}
