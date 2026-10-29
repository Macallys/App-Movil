import '../../../../core/error/result.dart';
import '../entities/area_setup.dart';
import '../entities/area_thresholds.dart';
import '../entities/device.dart';
import '../entities/device_association.dart';
import '../entities/device_revocation.dart';
import '../entities/industrial_area.dart';

abstract class PlantSetupRepository {
  Future<Result<IndustrialArea>> createArea({
    required String name,
    required String location,
  });

  Future<Result<AreaSetup>> getAreaSetup({required String areaId});

  Future<Result<AreaThresholds>> configureEnvironmentalThresholds({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  });

  Future<Result<Device>> issueDevice({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
  });

  Future<Result<DeviceAssociation>> associateDeviceToArea({
    required String areaId,
    required String deviceId,
    required DeviceKind kind,
  });

  Future<Result<List<Device>>> listDevices();

  Future<Result<DeviceRevocation>> revokeDevice({required String deviceId});
}
