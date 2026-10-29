import 'exposure_dto.dart';

class ShortExposureHistoryResponseDto {
  const ShortExposureHistoryResponseDto({required this.items});

  factory ShortExposureHistoryResponseDto.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    if (items is! List) {
      throw const FormatException('Unexpected items');
    }
    return ShortExposureHistoryResponseDto(
      items: [for (final item in items) ExposureDto.fromJson(_map(item))],
    );
  }

  final List<ExposureDto> items;
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
