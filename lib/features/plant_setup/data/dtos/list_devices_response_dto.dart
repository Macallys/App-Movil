import 'device_dto.dart';

class ListDevicesResponseDto {
  const ListDevicesResponseDto({required this.items});

  factory ListDevicesResponseDto.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    if (items is! List) {
      throw const FormatException('Unexpected items');
    }
    return ListDevicesResponseDto(
      items: [for (final item in items) DeviceDto.fromJson(_itemMap(item))],
    );
  }

  final List<DeviceDto> items;
}

Map<String, dynamic> _itemMap(Object? item) {
  if (item is Map<String, dynamic>) {
    return item;
  }
  if (item is Map) {
    return Map<String, dynamic>.from(item);
  }
  throw const FormatException('Unexpected items');
}
