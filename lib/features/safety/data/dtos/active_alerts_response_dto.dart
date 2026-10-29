import 'environmental_alert_dto.dart';

class ActiveAlertsResponseDto {
  const ActiveAlertsResponseDto({required this.items});

  factory ActiveAlertsResponseDto.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    if (items is! List) {
      throw const FormatException('Unexpected items');
    }
    return ActiveAlertsResponseDto(
      items: [
        for (final item in items) EnvironmentalAlertDto.fromJson(_map(item)),
      ],
    );
  }

  final List<EnvironmentalAlertDto> items;
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
