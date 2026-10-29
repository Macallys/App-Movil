import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/area_setup.dart';
import '../dtos/area_setup_dto.dart';
import '../dtos/area_thresholds_dto.dart';
import '../dtos/associate_device_request_dto.dart';
import '../dtos/configure_thresholds_request_dto.dart';
import '../dtos/create_area_request_dto.dart';
import '../dtos/device_association_dto.dart';
import '../dtos/industrial_area_dto.dart';
import '../dtos/issue_device_request_dto.dart';
import '../dtos/issue_device_response_dto.dart';
import '../dtos/list_devices_response_dto.dart';
import '../dtos/revoke_device_response_dto.dart';
import '../mappers/device_kind_mapper.dart';

class PlantSetupRemoteDataSource {
  PlantSetupRemoteDataSource(this._client);

  static const _createAreaPath = '/api/v1/areas';

  final ApiClient _client;

  Future<IndustrialAreaDto> createArea({
    required String name,
    required String location,
  }) async {
    final response = await _client.postJson(
      _createAreaPath,
      body: CreateAreaRequestDto(name: name, location: location).toJson(),
    );
    if (response.statusCode != 201) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return IndustrialAreaDto.fromJson(response.body);
  }

  Future<AreaThresholdsDto> configureEnvironmentalThresholds({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) async {
    final response = await _client.putJson(
      '/api/v1/areas/${Uri.encodeComponent(areaId)}/thresholds',
      body: ConfigureThresholdsRequestDto(
        co2LimitPpm: co2LimitPpm,
        noiseLimitDb: noiseLimitDb,
      ).toJson(),
    );
    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return AreaThresholdsDto.fromJson(response.body);
  }

  Future<IssueDeviceResponseDto> issueDevice({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
  }) async {
    final response = await _client.postJson(
      '/api/v1/devices',
      body: IssueDeviceRequestDto(
        deviceId: deviceId,
        areaId: areaId,
        kind: deviceKindToWire(kind),
      ).toJson(),
    );
    if (response.statusCode != 201) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return IssueDeviceResponseDto.fromJson(response.body);
  }

  Future<DeviceAssociationDto> associateDeviceToArea({
    required String areaId,
    required String deviceId,
    required DeviceKind kind,
  }) async {
    final response = await _client.postJson(
      '/api/v1/areas/${Uri.encodeComponent(areaId)}/devices',
      body: AssociateDeviceRequestDto(
        deviceId: deviceId,
        kind: deviceKindToWire(kind),
      ).toJson(),
    );
    if (response.statusCode != 201) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return DeviceAssociationDto.fromJson(response.body);
  }

  Future<ListDevicesResponseDto> listDevices() async {
    final response = await _client.getJson('/api/v1/devices');
    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return ListDevicesResponseDto.fromJson(response.body);
  }

  Future<RevokeDeviceResponseDto> revokeDevice({
    required String deviceId,
  }) async {
    final response = await _client.postWithoutBody(
      '/api/v1/devices/${Uri.encodeComponent(deviceId)}/revoke',
    );
    if (response.statusCode != 200) {
      throw ApiException(
        message: 'Unexpected response',
        statusCode: response.statusCode,
      );
    }
    return RevokeDeviceResponseDto.fromJson(response.body);
  }

  Future<AreaSetupDto> getAreaSetup({required String areaId}) {
    // TODO: Pending API/domain contract decision.
    return Future<AreaSetupDto>.error(UnimplementedError(areaId));
  }
}
