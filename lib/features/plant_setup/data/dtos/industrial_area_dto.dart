class IndustrialAreaDto {
  const IndustrialAreaDto({
    required this.id,
    required this.name,
    required this.location,
  });

  factory IndustrialAreaDto.fromJson(Map<String, dynamic> json) {
    return IndustrialAreaDto(
      id: _string(json, 'id'),
      name: _string(json, 'name'),
      location: _string(json, 'location'),
    );
  }

  final String id;
  final String name;
  final String location;
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw FormatException('Unexpected $key');
}
