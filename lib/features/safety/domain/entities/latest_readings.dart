import 'area_operational_status.dart';

final class CarbonDioxideReading {
  const CarbonDioxideReading({
    required this.deviceId,
    required this.ppm,
    required this.recordedAt,
  });

  final String deviceId;
  final int ppm;
  final DateTime recordedAt;
}

final class NoiseReading {
  const NoiseReading({
    required this.deviceId,
    required this.db,
    required this.recordedAt,
  });

  final String deviceId;
  final int db;
  final DateTime recordedAt;
}

final class PresenceReading {
  const PresenceReading({
    required this.deviceId,
    required this.state,
    required this.recordedAt,
  });

  final String deviceId;
  final PresenceState state;
  final DateTime recordedAt;
}

final class LatestReadings {
  const LatestReadings({
    required this.areaId,
    required this.carbonDioxide,
    required this.noise,
    required this.presence,
  });

  final String areaId;
  final CarbonDioxideReading? carbonDioxide;
  final NoiseReading? noise;
  final PresenceReading? presence;

  bool get hasTelemetry {
    return carbonDioxide != null || noise != null || presence != null;
  }
}
