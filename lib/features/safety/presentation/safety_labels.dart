import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/entities/actuator_state.dart';
import '../domain/entities/area_operational_status.dart';

String presenceLabel(PresenceState? state) {
  return switch (state) {
    null => 'Sin datos',
    PresenceState.detected => 'Detectada',
    PresenceState.cleared => 'Despejada',
  };
}

String severityLabel(ExposureSeverity severity) {
  return switch (severity) {
    ExposureSeverity.none => 'Ninguna',
    ExposureSeverity.medium => 'Media',
    ExposureSeverity.high => 'Alta',
  };
}

Color severityColor(ExposureSeverity severity, ColorScheme scheme) {
  return switch (severity) {
    ExposureSeverity.none => scheme.onSurfaceVariant,
    ExposureSeverity.medium => AppColors.amber,
    ExposureSeverity.high => scheme.error,
  };
}

String measureLabel(num? value, String unit) {
  if (value == null) {
    return 'Sin datos';
  }
  return '${_number(value)} $unit';
}

String actuatorSummary(ActuatorState actuator) {
  return '${actuatorTypeLabel(actuator.type)} — '
      '${runStateLabel(actuator.runState)} — '
      '${modeLabel(actuator.mode)}';
}

String actuatorTypeLabel(ActuatorType type) {
  return switch (type) {
    ActuatorType.extractor => 'Extractor',
    ActuatorType.siren => 'Siren',
    ActuatorType.barrier => 'Barrier',
  };
}

String runStateLabel(ActuatorRunState state) {
  return switch (state) {
    ActuatorRunState.off => 'Apagado',
    ActuatorRunState.on => 'Encendido',
    ActuatorRunState.deployed => 'Desplegado',
    ActuatorRunState.retracted => 'Replegado',
    ActuatorRunState.failed => 'Fallo',
  };
}

String modeLabel(ActuatorMode mode) {
  return switch (mode) {
    ActuatorMode.auto => 'Automático',
    ActuatorMode.overridden => 'Anulado',
  };
}

String formatStatusDate(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} '
      '${two(local.hour)}:${two(local.minute)}';
}

String _number(num value) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toString();
}
