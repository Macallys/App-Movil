import 'carbon_dioxide_reading_dto.dart';
import 'noise_reading_dto.dart';
import 'presence_reading_dto.dart';

class LatestReadingsDto {
  const LatestReadingsDto({
    required this.areaId,
    required this.carbonDioxide,
    required this.noise,
    required this.presence,
  });

  factory LatestReadingsDto.fromJson(Map<String, dynamic> json) {
    final areaId = json['areaId'];
    if (areaId is! String || areaId.isEmpty) {
      throw const FormatException('Unexpected areaId');
    }
    return LatestReadingsDto(
      areaId: areaId,
      carbonDioxide: _object(
        json,
        'carbonDioxide',
        CarbonDioxideReadingDto.fromJson,
      ),
      noise: _object(json, 'noise', NoiseReadingDto.fromJson),
      presence: _object(json, 'presence', PresenceReadingDto.fromJson),
    );
  }

  final String areaId;
  final CarbonDioxideReadingDto? carbonDioxide;
  final NoiseReadingDto? noise;
  final PresenceReadingDto? presence;
}

T? _object<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic> json) parse,
) {
  if (!json.containsKey(key) || json[key] == null) {
    return null;
  }
  final value = json[key];
  if (value is Map<String, dynamic>) {
    return parse(value);
  }
  if (value is Map) {
    return parse(Map<String, dynamic>.from(value));
  }
  throw FormatException('Unexpected $key');
}
