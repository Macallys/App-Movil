import '../../../../core/error/result.dart';
import '../entities/actuator_action.dart';
import '../entities/actuator_state.dart';
import '../entities/area_operational_status.dart';
import '../entities/environmental_alert.dart';
import '../entities/exposure.dart';
import '../entities/latest_readings.dart';

abstract class SafetyRepository {
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus();

  Future<Result<LatestReadings>> getLatestReadings({required String areaId});

  Future<Result<List<EnvironmentalAlert>>> getActiveAlerts();

  Future<Result<List<Exposure>>> getShortExposureHistory({
    required String areaId,
  });

  Future<Result<List<ActuatorAction>>> getActuatorActions({
    required String areaId,
  });

  Future<Result<ActuatorState>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  });
}
