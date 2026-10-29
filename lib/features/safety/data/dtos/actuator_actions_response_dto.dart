import 'actuator_action_dto.dart';

class ActuatorActionsResponseDto {
  const ActuatorActionsResponseDto({required this.items});

  factory ActuatorActionsResponseDto.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    if (items is! List) {
      throw const FormatException('Unexpected items');
    }
    return ActuatorActionsResponseDto(
      items: [for (final item in items) ActuatorActionDto.fromJson(_map(item))],
    );
  }

  final List<ActuatorActionDto> items;
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  throw const FormatException('Unexpected items');
}
