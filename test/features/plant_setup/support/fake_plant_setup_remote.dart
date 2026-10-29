import 'package:dio/dio.dart';
import 'package:safeplant_mobile/core/network/api_client.dart';
import 'package:safeplant_mobile/core/network/api_exception.dart';
import 'package:safeplant_mobile/features/plant_setup/data/datasources/plant_setup_remote_data_source.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/area_setup_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/area_thresholds_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/device_association_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/industrial_area_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/issue_device_response_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/list_devices_response_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/data/dtos/revoke_device_response_dto.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';

class FakePlantSetupRemote extends PlantSetupRemoteDataSource {
  FakePlantSetupRemote({
    this.created,
    this.createError,
    this.setup,
    this.setupError,
    this.thresholds,
    this.thresholdsError,
    this.issued,
    this.issueError,
    this.association,
    this.associationError,
    this.devices,
    this.devicesError,
    this.revocation,
    this.revokeError,
  }) : super(ApiClient(dio: Dio()));

  final IndustrialAreaDto? created;
  final ApiException? createError;
  final AreaSetupDto? setup;
  final ApiException? setupError;
  final AreaThresholdsDto? thresholds;
  final ApiException? thresholdsError;
  final IssueDeviceResponseDto? issued;
  final ApiException? issueError;
  final DeviceAssociationDto? association;
  final ApiException? associationError;
  final ListDevicesResponseDto? devices;
  final ApiException? devicesError;
  final RevokeDeviceResponseDto? revocation;
  final ApiException? revokeError;

  @override
  Future<IndustrialAreaDto> createArea({
    required String name,
    required String location,
  }) async {
    final error = createError;
    if (error != null) {
      throw error;
    }
    return created!;
  }

  @override
  Future<AreaSetupDto> getAreaSetup({required String areaId}) async {
    final error = setupError;
    if (error != null) {
      throw error;
    }
    return setup!;
  }

  @override
  Future<AreaThresholdsDto> configureEnvironmentalThresholds({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) async {
    final error = thresholdsError;
    if (error != null) {
      throw error;
    }
    return thresholds!;
  }

  @override
  Future<IssueDeviceResponseDto> issueDevice({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
  }) async {
    final error = issueError;
    if (error != null) {
      throw error;
    }
    return issued!;
  }

  @override
  Future<DeviceAssociationDto> associateDeviceToArea({
    required String areaId,
    required String deviceId,
    required DeviceKind kind,
  }) async {
    final error = associationError;
    if (error != null) {
      throw error;
    }
    return association!;
  }

  @override
  Future<ListDevicesResponseDto> listDevices() async {
    final error = devicesError;
    if (error != null) {
      throw error;
    }
    return devices!;
  }

  @override
  Future<RevokeDeviceResponseDto> revokeDevice({
    required String deviceId,
  }) async {
    final error = revokeError;
    if (error != null) {
      throw error;
    }
    return revocation!;
  }
}
