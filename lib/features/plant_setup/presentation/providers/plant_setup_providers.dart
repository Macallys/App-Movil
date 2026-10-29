import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../session/presentation/providers/session_providers.dart';
import '../../application/use_cases/configure_thresholds.dart';
import '../../application/use_cases/create_area.dart';
import '../../application/use_cases/get_area_setup.dart';
import '../../application/use_cases/list_devices.dart';
import '../../application/use_cases/register_device.dart';
import '../../application/use_cases/revoke_device.dart';
import '../../data/datasources/plant_setup_remote_data_source.dart';
import '../../data/mappers/area_setup_mapper.dart';
import '../../data/mappers/area_thresholds_mapper.dart';
import '../../data/mappers/device_association_mapper.dart';
import '../../data/mappers/device_mapper.dart';
import '../../data/mappers/industrial_area_mapper.dart';
import '../../data/repositories/plant_setup_repository_impl.dart';
import '../../domain/entities/area_setup.dart';
import '../../domain/entities/area_thresholds.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_association.dart';
import '../../domain/entities/industrial_area.dart';
import '../../domain/repositories/plant_setup_repository.dart';

part '../controllers/area_setup_controller.dart';
part '../controllers/configure_thresholds_controller.dart';
part '../controllers/device_inventory_controller.dart';
part '../controllers/device_registration_controller.dart';
part '../controllers/industrial_area_controller.dart';

final plantSetupRemoteDataSourceProvider = Provider<PlantSetupRemoteDataSource>(
  (ref) {
    return PlantSetupRemoteDataSource(ref.watch(apiClientProvider));
  },
);

final plantSetupRepositoryProvider = Provider<PlantSetupRepository>((ref) {
  return PlantSetupRepositoryImpl(
    remote: ref.watch(plantSetupRemoteDataSourceProvider),
    areaMapper: const IndustrialAreaMapper(),
    setupMapper: const AreaSetupMapper(),
    thresholdsMapper: const AreaThresholdsMapper(),
    deviceMapper: const DeviceMapper(),
    associationMapper: const DeviceAssociationMapper(),
  );
});

final createAreaUseCaseProvider = Provider<CreateArea>((ref) {
  return CreateArea(ref.watch(plantSetupRepositoryProvider));
});

final getAreaSetupUseCaseProvider = Provider<GetAreaSetup>((ref) {
  return GetAreaSetup(ref.watch(plantSetupRepositoryProvider));
});

final configureThresholdsUseCaseProvider = Provider<ConfigureThresholds>((ref) {
  return ConfigureThresholds(ref.watch(plantSetupRepositoryProvider));
});

final registerDeviceUseCaseProvider = Provider<RegisterDevice>((ref) {
  return RegisterDevice(ref.watch(plantSetupRepositoryProvider));
});

final listDevicesUseCaseProvider = Provider<ListDevices>((ref) {
  return ListDevices(ref.watch(plantSetupRepositoryProvider));
});

final revokeDeviceUseCaseProvider = Provider<RevokeDevice>((ref) {
  return RevokeDevice(ref.watch(plantSetupRepositoryProvider));
});

final industrialAreaControllerProvider =
    NotifierProvider<IndustrialAreaController, CreateAreaState>(
      IndustrialAreaController.new,
    );

final areaSetupControllerProvider =
    NotifierProvider<AreaSetupController, AreaSetupState>(
      AreaSetupController.new,
    );

final configureThresholdsControllerProvider =
    NotifierProvider<ConfigureThresholdsController, ConfigureThresholdsState>(
      ConfigureThresholdsController.new,
    );

final deviceRegistrationControllerProvider =
    NotifierProvider<DeviceRegistrationController, DeviceRegistrationState>(
      DeviceRegistrationController.new,
    );

final deviceInventoryControllerProvider =
    NotifierProvider<DeviceInventoryController, DeviceInventoryState>(
      DeviceInventoryController.new,
    );
