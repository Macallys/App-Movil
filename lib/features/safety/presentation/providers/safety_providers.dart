import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../session/presentation/providers/session_providers.dart';
import '../../application/use_cases/get_active_alerts.dart';
import '../../application/use_cases/get_actuator_actions.dart';
import '../../application/use_cases/get_latest_readings.dart';
import '../../application/use_cases/get_operational_status.dart';
import '../../application/use_cases/get_short_exposure_history.dart';
import '../../application/use_cases/override_actuator.dart';
import '../../data/datasources/safety_remote_data_source.dart';
import '../../data/mappers/actuator_action_mapper.dart';
import '../../data/mappers/area_operational_status_mapper.dart';
import '../../data/mappers/environmental_alert_mapper.dart';
import '../../data/mappers/exposure_mapper.dart';
import '../../data/mappers/latest_readings_mapper.dart';
import '../../data/repositories/safety_repository_impl.dart';
import '../../domain/entities/actuator_action.dart';
import '../../domain/entities/actuator_state.dart';
import '../../domain/entities/area_operational_status.dart';
import '../../domain/entities/environmental_alert.dart';
import '../../domain/entities/exposure.dart';
import '../../domain/entities/latest_readings.dart';
import '../active_alerts_polling.dart';
import '../../domain/repositories/safety_repository.dart';

part '../controllers/active_alerts_controller.dart';
part '../controllers/actuator_actions_controller.dart';
part '../controllers/actuator_override_controller.dart';
part '../controllers/exposure_history_controller.dart';
part '../controllers/latest_readings_controller.dart';
part '../controllers/safety_dashboard_controller.dart';

final safetyRemoteDataSourceProvider = Provider<SafetyRemoteDataSource>((ref) {
  return SafetyRemoteDataSource(ref.watch(apiClientProvider));
});

final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  return SafetyRepositoryImpl(
    remote: ref.watch(safetyRemoteDataSourceProvider),
    statusMapper: const AreaOperationalStatusMapper(),
    readingsMapper: const LatestReadingsMapper(),
    alertMapper: const EnvironmentalAlertMapper(),
    exposureMapper: const ExposureMapper(),
    actionMapper: const ActuatorActionMapper(),
  );
});

final getOperationalStatusUseCaseProvider = Provider<GetOperationalStatus>((
  ref,
) {
  return GetOperationalStatus(ref.watch(safetyRepositoryProvider));
});

final safetyDashboardControllerProvider =
    NotifierProvider<SafetyDashboardController, SafetyDashboardState>(
      SafetyDashboardController.new,
    );

final getLatestReadingsUseCaseProvider = Provider<GetLatestReadings>((ref) {
  return GetLatestReadings(ref.watch(safetyRepositoryProvider));
});

final latestReadingsControllerProvider =
    NotifierProvider.autoDispose<LatestReadingsController, LatestReadingsState>(
      LatestReadingsController.new,
    );

final getActiveAlertsUseCaseProvider = Provider<GetActiveAlerts>((ref) {
  return GetActiveAlerts(ref.watch(safetyRepositoryProvider));
});

final activeAlertsPollingEnabledProvider = Provider<bool>((ref) => true);

final activeAlertsControllerProvider =
    NotifierProvider.autoDispose<ActiveAlertsController, ActiveAlertsState>(
      ActiveAlertsController.new,
    );

final getShortExposureHistoryUseCaseProvider =
    Provider<GetShortExposureHistory>((ref) {
      return GetShortExposureHistory(ref.watch(safetyRepositoryProvider));
    });

final exposureHistoryControllerProvider =
    NotifierProvider.autoDispose<
      ExposureHistoryController,
      ExposureHistoryState
    >(ExposureHistoryController.new);

final getActuatorActionsUseCaseProvider = Provider<GetActuatorActions>((ref) {
  return GetActuatorActions(ref.watch(safetyRepositoryProvider));
});

final actuatorActionsControllerProvider =
    NotifierProvider.autoDispose<
      ActuatorActionsController,
      ActuatorActionsState
    >(ActuatorActionsController.new);

final overrideActuatorUseCaseProvider = Provider<OverrideActuator>((ref) {
  return OverrideActuator(ref.watch(safetyRepositoryProvider));
});

final actuatorOverrideControllerProvider =
    NotifierProvider.autoDispose<
      ActuatorOverrideController,
      ActuatorOverrideState
    >(ActuatorOverrideController.new);
