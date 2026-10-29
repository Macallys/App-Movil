import 'area_operational_status_dto.dart';

class OperationalStatusResponseDto {
  const OperationalStatusResponseDto({required this.items});

  factory OperationalStatusResponseDto.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    if (items is! List) {
      throw const FormatException('Unexpected items');
    }
    return OperationalStatusResponseDto(
      items: [
        for (final item in items) AreaOperationalStatusDto.fromJson(_map(item)),
      ],
    );
  }

  final List<AreaOperationalStatusDto> items;
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
