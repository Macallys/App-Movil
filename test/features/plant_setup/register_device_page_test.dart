import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/register_device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/pages/register_device_page.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/providers/plant_setup_providers.dart';

void main() {
  testWidgets('device id is required', (tester) async {
    final useCase = _Scripted();
    await _pump(tester, useCase, const RegisterDevicePage(areaId: 'area-9'));

    await tester.tap(find.text('Sensor'));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('El identificador es obligatorio'), findsOneWidget);
    expect(useCase.issueCalls, 0);
  });

  testWidgets('kind is required', (tester) async {
    final useCase = _Scripted();
    await _pump(tester, useCase, const RegisterDevicePage(areaId: 'area-9'));

    await tester.enterText(find.byType(TextFormField), 'dev-1');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('El tipo es obligatorio'), findsOneWidget);
    expect(useCase.issueCalls, 0);
  });

  testWidgets('area id comes from the page context', (tester) async {
    await _pump(
      tester,
      _Scripted(),
      const RegisterDevicePage(areaId: 'area-9'),
    );

    expect(find.text('area-9'), findsOneWidget);
    expect(find.text('Sensor'), findsOneWidget);
    expect(find.text('Actuador'), findsOneWidget);
    expect(find.text('CO2'), findsNothing);
    expect(find.text('Extractor'), findsNothing);
    expect(find.text('Modelo'), findsNothing);
    expect(find.text('Firmware'), findsNothing);
    expect(find.text('Secret'), findsNothing);
    expect(find.text('Dirección'), findsNothing);
  });

  testWidgets('loading blocks a second submit', (tester) async {
    final useCase = _Pending();
    await _pump(tester, useCase, const RegisterDevicePage(areaId: 'area-9'));

    await tester.enterText(find.byType(TextFormField), 'dev-1');
    await tester.tap(find.text('Sensor'));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Registrando dispositivo...'), findsOneWidget);
    expect(useCase.issueCalls, 1);
  });

  testWidgets('partial failure explains the issued device and retries only '
      'the association', (tester) async {
    final useCase = _Scripted();
    await _pump(tester, useCase, const RegisterDevicePage(areaId: 'area-9'));

    await tester.enterText(find.byType(TextFormField), 'dev-1');
    await tester.tap(find.text('Sensor'));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(
      find.text(
        'El dispositivo fue registrado, pero no pudo asociarse al área.',
      ),
      findsOneWidget,
    );
    expect(find.text('Registro fallido'), findsNothing);
    expect(useCase.issueCalls, 1);

    await tester.tap(find.text('Reintentar asociación'));
    await tester.pump();

    expect(useCase.issueCalls, 1);
    expect(useCase.associateCalls, 1);
    expect(find.text('Dispositivo registrado'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, RegisterDevice useCase, Widget page) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [registerDeviceUseCaseProvider.overrideWithValue(useCase)],
      child: MaterialApp(home: Scaffold(body: page)),
    ),
  );
}

class _Scripted extends RegisterDevice {
  _Scripted() : super(_IdleRepository());

  var issueCalls = 0;
  var associateCalls = 0;

  @override
  Future<RegisterDeviceResult> call({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
    void Function(RegisterDevicePhase phase)? onPhase,
  }) async {
    issueCalls += 1;
    onPhase?.call(RegisterDevicePhase.issuing);
    return RegisterDeviceAssociationFailed(
      device: Device(
        deviceId: deviceId,
        issuedAt: DateTime.utc(2026, 1, 1),
        expiresAt: DateTime.utc(2026, 2, 1),
      ),
      failure: const NetworkFailure(),
    );
  }

  @override
  Future<Result<DeviceAssociation>> associate({
    required String areaId,
    required String deviceId,
    required DeviceKind kind,
  }) async {
    associateCalls += 1;
    return const Success(
      DeviceAssociation(
        id: 'assoc-1',
        areaId: 'area-9',
        deviceId: 'dev-1',
        kind: DeviceKind.sensor,
      ),
    );
  }
}

class _Pending extends RegisterDevice {
  _Pending() : super(_IdleRepository());

  final Completer<RegisterDeviceResult> completer =
      Completer<RegisterDeviceResult>();
  var issueCalls = 0;

  @override
  Future<RegisterDeviceResult> call({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
    void Function(RegisterDevicePhase phase)? onPhase,
  }) {
    issueCalls += 1;
    onPhase?.call(RegisterDevicePhase.issuing);
    return completer.future;
  }
}

class _IdleRepository implements PlantSetupRepository {
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
  Future<Result<List<Device>>> listDevices() {
    throw UnimplementedError();
  }

  @override
  Future<Result<DeviceRevocation>> revokeDevice({required String deviceId}) {
    throw UnimplementedError();
  }
}
