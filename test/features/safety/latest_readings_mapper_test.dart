import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/carbon_dioxide_reading_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/latest_readings_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/noise_reading_dto.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/presence_reading_dto.dart';
import 'package:safeplant_mobile/features/safety/data/mappers/latest_readings_mapper.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';

void main() {
  const mapper = LatestReadingsMapper();

  test('keeps each reading field on its own entity', () {
    final readings = mapper.toEntity(
      LatestReadingsDto(
        carbonDioxide: CarbonDioxideReadingDto(
          deviceId: 'co2-1',
          ppm: 810,
          recordedAt: DateTime.utc(2026, 5, 20, 15, 35),
        ),
        noise: NoiseReadingDto(
          deviceId: 'noise-1',
          decibels: 85.5,
          recordedAt: DateTime.utc(2026, 5, 20, 15, 33),
        ),
        presence: PresenceReadingDto(
          deviceId: 'presence-1',
          state: 'Detected',
          recordedAt: DateTime.utc(2026, 5, 20, 15, 36),
        ),
      ),
    );

    expect(readings.carbonDioxide?.deviceId, 'co2-1');
    expect(readings.carbonDioxide?.ppm, 810);
    expect(
      readings.carbonDioxide?.recordedAt,
      DateTime.utc(2026, 5, 20, 15, 35),
    );
    expect(readings.noise?.deviceId, 'noise-1');
    expect(readings.noise?.decibels, 85.5);
    expect(readings.noise?.recordedAt, DateTime.utc(2026, 5, 20, 15, 33));
    expect(readings.presence?.deviceId, 'presence-1');
    expect(readings.presence?.state, PresenceState.detected);
    expect(readings.presence?.recordedAt, DateTime.utc(2026, 5, 20, 15, 36));
  });

  test('does not invent a reading for a null section', () {
    final readings = mapper.toEntity(
      const LatestReadingsDto(carbonDioxide: null, noise: null, presence: null),
    );

    expect(readings.carbonDioxide, isNull);
    expect(readings.noise, isNull);
    expect(readings.presence, isNull);
  });
}
