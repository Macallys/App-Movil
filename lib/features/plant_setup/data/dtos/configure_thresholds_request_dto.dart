class ConfigureThresholdsRequestDto {
  const ConfigureThresholdsRequestDto({
    required this.co2LimitPpm,
    required this.noiseLimitDb,
  });

  final num co2LimitPpm;
  final num noiseLimitDb;

  Map<String, dynamic> toJson() {
    return {'co2LimitPpm': co2LimitPpm, 'noiseLimitDb': noiseLimitDb};
  }
}
