enum ActuatorType { extractor, siren, barrier }

enum ActuatorRunState { off, on, deployed, retracted, failed }

enum ActuatorMode { auto, overridden }

final class ActuatorState {
  const ActuatorState({
    required this.type,
    required this.runState,
    required this.mode,
    required this.lastChangedAt,
  });

  final ActuatorType type;
  final ActuatorRunState runState;
  final ActuatorMode mode;
  final DateTime lastChangedAt;
}
