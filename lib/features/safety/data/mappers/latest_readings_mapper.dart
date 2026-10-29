import '../../domain/entities/latest_readings.dart';
import '../dtos/carbon_dioxide_reading_dto.dart';
import '../dtos/latest_readings_dto.dart';
import '../dtos/noise_reading_dto.dart';
import '../dtos/presence_reading_dto.dart';
import 'area_operational_status_mapper.dart';

class LatestReadingsMapper {
  const LatestReadingsMapper();

  LatestReadings toEntity(LatestReadingsDto dto) {
    return LatestReadings(
      carbonDioxide: dto.carbonDioxide == null
          ? null
          : _carbonDioxide(dto.carbonDioxide!),
      noise: dto.noise == null ? null : _noise(dto.noise!),
      presence: dto.presence == null ? null : _presence(dto.presence!),
    );
  }

  CarbonDioxideReading _carbonDioxide(CarbonDioxideReadingDto dto) {
    return CarbonDioxideReading(
      deviceId: dto.deviceId,
      ppm: dto.ppm,
      recordedAt: dto.recordedAt,
    );
  }

  NoiseReading _noise(NoiseReadingDto dto) {
    return NoiseReading(
      deviceId: dto.deviceId,
      decibels: dto.decibels,
      recordedAt: dto.recordedAt,
    );
  }

  PresenceReading _presence(PresenceReadingDto dto) {
    final state = presenceStateFromWire(dto.state);
    if (state == null) {
      throw const FormatException('Unexpected state');
    }
    return PresenceReading(
      deviceId: dto.deviceId,
      state: state,
      recordedAt: dto.recordedAt,
    );
  }
}
