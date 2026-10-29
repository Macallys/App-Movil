class OverrideActuatorRequestDto {
  const OverrideActuatorRequestDto({
    required this.type,
    required this.runState,
  });

  final String type;
  final String runState;

  Map<String, dynamic> toJson() {
    return {'type': type, 'runState': runState};
  }
}
