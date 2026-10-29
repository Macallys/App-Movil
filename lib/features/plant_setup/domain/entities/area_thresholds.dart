final class AreaThresholds {
  const AreaThresholds({
    required this.areaId,
    required this.co2LimitPpm,
    required this.noiseLimitDb,
  });

  final String areaId;
  final num co2LimitPpm;
  final num noiseLimitDb;
}
