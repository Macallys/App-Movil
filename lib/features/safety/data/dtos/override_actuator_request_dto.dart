class OverrideActuatorRequestDto {
  const OverrideActuatorRequestDto({
    required this.actuatorType,
    required this.runState,
  });

  final String actuatorType;
  final String runState;

  Map<String, String> toJson() {
    return {'actuatorType': actuatorType, 'runState': runState};
  }
}
