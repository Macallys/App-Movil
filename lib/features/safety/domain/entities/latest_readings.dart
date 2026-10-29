import 'area_operational_status.dart';

final class CarbonDioxideReading {
  const CarbonDioxideReading({
    required this.deviceId,
    required this.ppm,
    required this.recordedAt,
  });

  final String deviceId;
  final num ppm;
  final DateTime recordedAt;
}

final class NoiseReading {
  const NoiseReading({
    required this.deviceId,
    required this.decibels,
    required this.recordedAt,
  });

  final String deviceId;
  final num decibels;
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
    required this.carbonDioxide,
    required this.noise,
    required this.presence,
  });

  final CarbonDioxideReading? carbonDioxide;
  final NoiseReading? noise;
  final PresenceReading? presence;

  bool get hasTelemetry {
    return carbonDioxide != null || noise != null || presence != null;
  }
}
