import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/network/api_client.dart';
import 'package:safeplant_mobile/features/plant_setup/data/datasources/plant_setup_remote_data_source.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';

import '../../support/memory_token_storage.dart';

void main() {
  test(
    'create area posts only name and location with the bearer token',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      final source = PlantSetupRemoteDataSource(
        ApiClient(
          dio: dio,
          tokenStorage: MemoryTokenStorage()..accessToken = 'abc',
        ),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.path, '/api/v1/areas');
            expect(options.data, {'name': 'Horno', 'location': 'Nave 1'});
            expect(options.extra['authenticated'], isNot(false));
            expect(options.headers['Authorization'], 'Bearer abc');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 201,
                data: {'id': 'area-1', 'name': 'Horno', 'location': 'Nave 1'},
              ),
            );
          },
        ),
      );

      final dto = await source.createArea(name: 'Horno', location: 'Nave 1');

      expect(dto.id, 'area-1');
      expect(dto.name, 'Horno');
      expect(dto.location, 'Nave 1');
    },
  );

  test('area setup is not requested while its path stays open', () async {
    var calls = 0;
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    final source = PlantSetupRemoteDataSource(ApiClient(dio: dio));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          calls += 1;
          handler.resolve(
            Response<dynamic>(requestOptions: options, statusCode: 200),
          );
        },
      ),
    );

    await expectLater(
      source.getAreaSetup(areaId: 'area-1'),
      throwsA(isA<UnimplementedError>()),
    );
    expect(calls, 0);
  });

  test('configure thresholds puts both limits and the bearer token', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    final source = PlantSetupRemoteDataSource(
      ApiClient(
        dio: dio,
        tokenStorage: MemoryTokenStorage()..accessToken = 'abc',
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'PUT');
          expect(options.path, '/api/v1/areas/area-1/thresholds');
          expect(options.data, {'co2LimitPpm': 800, 'noiseLimitDb': 85.5});
          expect((options.data as Map).containsKey('areaId'), isFalse);
          expect(options.extra['authenticated'], isNot(false));
          expect(options.headers['Authorization'], 'Bearer abc');
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'areaId': 'area-1',
                'co2LimitPpm': 800,
                'noiseLimitDb': 85.5,
              },
            ),
          );
        },
      ),
    );

    final dto = await source.configureEnvironmentalThresholds(
      areaId: 'area-1',
      co2LimitPpm: 800,
      noiseLimitDb: 85.5,
    );

    expect(dto.areaId, 'area-1');
    expect(dto.co2LimitPpm, 800);
    expect(dto.noiseLimitDb, 85.5);
  });

  test(
    'issue device posts deviceId, areaId and kind with the bearer token',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      final source = PlantSetupRemoteDataSource(
        ApiClient(
          dio: dio,
          tokenStorage: MemoryTokenStorage()..accessToken = 'abc',
        ),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.method, 'POST');
            expect(options.path, '/api/v1/devices');
            expect(options.data, {
              'deviceId': 'dev-1',
              'areaId': 'area-1',
              'kind': 'Sensor',
            });
            expect(options.headers['Authorization'], 'Bearer abc');
            handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'deviceId': 'dev-1',
                  'issuedAt': '2026-01-01T00:00:00Z',
                  'expiresAt': '2026-02-01T00:00:00Z',
                  'secret': 'ignored',
                },
              ),
            );
          },
        ),
      );

      final dto = await source.issueDevice(
        deviceId: 'dev-1',
        areaId: 'area-1',
        kind: DeviceKind.sensor,
      );

      expect(dto.deviceId, 'dev-1');
    },
  );

  test('associate device posts deviceId and kind on the area path', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    final source = PlantSetupRemoteDataSource(
      ApiClient(
        dio: dio,
        tokenStorage: MemoryTokenStorage()..accessToken = 'abc',
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'POST');
          expect(options.path, '/api/v1/areas/area-1/devices');
          expect(options.data, {'deviceId': 'dev-1', 'kind': 'Actuator'});
          expect((options.data as Map).containsKey('areaId'), isFalse);
          expect(options.headers['Authorization'], 'Bearer abc');
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 201,
              data: {
                'id': 'assoc-1',
                'areaId': 'area-1',
                'deviceId': 'dev-1',
                'kind': 'Actuator',
              },
            ),
          );
        },
      ),
    );

    final dto = await source.associateDeviceToArea(
      areaId: 'area-1',
      deviceId: 'dev-1',
      kind: DeviceKind.actuator,
    );

    expect(dto.id, 'assoc-1');
    expect(dto.kind, 'Actuator');
  });

  test('list devices gets the inventory with the bearer token', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    final source = PlantSetupRemoteDataSource(
      ApiClient(
        dio: dio,
        tokenStorage: MemoryTokenStorage()..accessToken = 'abc',
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'GET');
          expect(options.path, '/api/v1/devices');
          expect(options.data, isNull);
          expect(options.headers['Authorization'], 'Bearer abc');
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'items': [
                  {
                    'deviceId': 'dev-1',
                    'areaId': 'area-1',
                    'kind': 'Sensor',
                    'issuedAt': '2026-01-01T00:00:00Z',
                    'expiresAt': '2026-02-01T00:00:00Z',
                    'revokedAt': null,
                  },
                ],
              },
            ),
          );
        },
      ),
    );

    final dto = await source.listDevices();

    expect(dto.items.single.deviceId, 'dev-1');
    expect(dto.items.single.revokedAt, isNull);
  });

  test('revoke posts without a body', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    final source = PlantSetupRemoteDataSource(
      ApiClient(
        dio: dio,
        tokenStorage: MemoryTokenStorage()..accessToken = 'abc',
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'POST');
          expect(options.path, '/api/v1/devices/dev-1/revoke');
          expect(options.data, isNull);
          expect(options.headers['Authorization'], 'Bearer abc');
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: {'deviceId': 'dev-1', 'revokedAt': '2026-03-01T00:00:00Z'},
            ),
          );
        },
      ),
    );

    final dto = await source.revokeDevice(deviceId: 'dev-1');

    expect(dto.deviceId, 'dev-1');
    expect(dto.revokedAt, DateTime.utc(2026, 3, 1));
  });
}
