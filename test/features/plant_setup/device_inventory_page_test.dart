import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/list_devices.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/revoke_device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/pages/device_inventory_page.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/providers/plant_setup_providers.dart';

void main() {
  testWidgets('shows active and revoked devices', (tester) async {
    await _pump(
      tester,
      list: _FixedList(
        Success([
          _device(id: 'dev-1'),
          _device(id: 'dev-2', revokedAt: DateTime.utc(2026, 3, 1)),
        ]),
      ),
      revoke: _FixedRevoke(const FailureResult(UnknownFailure())),
    );
    await tester.pumpAndSettle();

    expect(find.text('dev-1'), findsOneWidget);
    expect(find.text('dev-2'), findsOneWidget);
    expect(find.text('Área: area-1'), findsNWidgets(2));
    expect(find.text('Sensor'), findsNWidgets(2));
    expect(find.text('Activo'), findsOneWidget);
    expect(find.text('Revocado'), findsOneWidget);
    expect(find.text('Revocar dispositivo'), findsOneWidget);
    expect(find.text('Última conexión'), findsNothing);
    expect(find.text('Modelo'), findsNothing);
    expect(find.text('Firmware'), findsNothing);
  });

  testWidgets('an empty inventory is not an error', (tester) async {
    await _pump(
      tester,
      list: _FixedList(const Success([])),
      revoke: _FixedRevoke(const FailureResult(UnknownFailure())),
    );
    await tester.pumpAndSettle();

    expect(find.text('No hay dispositivos registrados.'), findsOneWidget);
    expect(find.text('No se pudo completar la solicitud.'), findsNothing);
  });

  testWidgets('confirmation appears before revoke', (tester) async {
    final revoke = _FixedRevoke(
      Success(
        DeviceRevocation(
          deviceId: 'dev-1',
          revokedAt: DateTime.utc(2026, 3, 1),
        ),
      ),
    );
    await _pump(
      tester,
      list: _FixedList(Success([_device(id: 'dev-1')])),
      revoke: revoke,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Revocar dispositivo'));
    await tester.pumpAndSettle();

    expect(find.text('¿Revocar este dispositivo?'), findsOneWidget);
    expect(
      find.text('El dispositivo dejará de tener credenciales válidas.'),
      findsOneWidget,
    );
    expect(revoke.calls, 0);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Activo'), findsOneWidget);
    expect(revoke.calls, 0);
  });

  testWidgets('revoking blocks a second revoke of that device', (tester) async {
    final revoke = _PendingRevoke();
    await _pump(
      tester,
      list: _FixedList(Success([_device(id: 'dev-1')])),
      revoke: revoke,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Revocar dispositivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revocar'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(revoke.calls, 1);
    expect(find.text('Activo'), findsOneWidget);
  });

  testWidgets('a revoke failure does not mark the device revoked', (
    tester,
  ) async {
    await _pump(
      tester,
      list: _FixedList(Success([_device(id: 'dev-1')])),
      revoke: _FixedRevoke(const FailureResult(NetworkFailure())),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Revocar dispositivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revocar'));
    await tester.pumpAndSettle();

    expect(find.text('Activo'), findsOneWidget);
    expect(find.text('Revocado'), findsNothing);
    expect(find.text('No se pudo conectar con el servidor.'), findsOneWidget);
    expect(find.text('Revocar dispositivo'), findsOneWidget);
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required ListDevices list,
  required RevokeDevice revoke,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        listDevicesUseCaseProvider.overrideWithValue(list),
        revokeDeviceUseCaseProvider.overrideWithValue(revoke),
      ],
      child: const MaterialApp(home: Scaffold(body: DeviceInventoryPage())),
    ),
  );
}

Device _device({required String id, DateTime? revokedAt}) {
  return Device(
    deviceId: id,
    areaId: 'area-1',
    kind: DeviceKind.sensor,
    issuedAt: DateTime.utc(2026, 1, 1),
    expiresAt: DateTime.utc(2027, 1, 1),
    revokedAt: revokedAt,
  );
}

class _FixedList extends ListDevices {
  _FixedList(this.result) : super(_IdleRepository());

  final Result<List<Device>> result;

  @override
  Future<Result<List<Device>>> call() async => result;
}

class _FixedRevoke extends RevokeDevice {
  _FixedRevoke(this.result) : super(_IdleRepository());

  final Result<DeviceRevocation> result;
  var calls = 0;

  @override
  Future<Result<DeviceRevocation>> call({required String deviceId}) async {
    calls += 1;
    return result;
  }
}

class _PendingRevoke extends RevokeDevice {
  _PendingRevoke() : super(_IdleRepository());

  final Completer<Result<DeviceRevocation>> completer =
      Completer<Result<DeviceRevocation>>();
  var calls = 0;

  @override
  Future<Result<DeviceRevocation>> call({required String deviceId}) {
    calls += 1;
    return completer.future;
  }
}

class _IdleRepository implements PlantSetupRepository {
  @override
  Future<Result<List<Device>>> listDevices() {
    throw UnimplementedError();
  }

  @override
  Future<Result<DeviceRevocation>> revokeDevice({required String deviceId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Device>> issueDevice({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DeviceAssociation>> associateDeviceToArea({
    required String areaId,
    required String deviceId,
    required DeviceKind kind,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<IndustrialArea>> createArea({
    required String name,
    required String location,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<AreaSetup>> getAreaSetup({required String areaId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<AreaThresholds>> configureEnvironmentalThresholds({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) {
    throw UnimplementedError();
  }
}
