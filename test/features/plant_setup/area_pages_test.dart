import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/create_area.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/get_area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/pages/area_setup_page.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/pages/create_area_page.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/providers/plant_setup_providers.dart';

void main() {
  testWidgets('create area requires name and location', (tester) async {
    final create = _CountingCreate(const FailureResult(UnknownFailure()));
    await _pumpCreate(tester, create);

    await tester.tap(find.text('Crear área'));
    await tester.pump();

    expect(find.text('El nombre es obligatorio'), findsOneWidget);
    expect(find.text('La ubicación es obligatoria'), findsOneWidget);
    expect(create.calls, 0);
  });

  testWidgets('create area submits the trimmed fields', (tester) async {
    final create = _CountingCreate(
      const Success(
        IndustrialArea(id: 'area-1', name: 'Horno', location: 'Nave 1'),
      ),
    );
    await _pumpCreate(tester, create);

    await tester.enterText(find.byType(TextFormField).at(0), '  Horno  ');
    await tester.enterText(find.byType(TextFormField).at(1), ' Nave 1 ');
    await tester.tap(find.text('Crear área'));
    await tester.pumpAndSettle();

    expect(create.calls, 1);
    expect(create.name, 'Horno');
    expect(create.location, 'Nave 1');
    expect(find.text('Área creada'), findsOneWidget);
  });

  testWidgets('loading blocks a second submit', (tester) async {
    final create = _PendingCreate(Completer<Result<IndustrialArea>>());
    await _pumpCreate(tester, create);

    await tester.enterText(find.byType(TextFormField).at(0), 'Horno');
    await tester.enterText(find.byType(TextFormField).at(1), 'Nave 1');
    await tester.tap(find.text('Crear área'));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(create.calls, 1);
  });

  testWidgets('a duplicate name shows the area message', (tester) async {
    await _pumpCreate(
      tester,
      _CountingCreate(const FailureResult(ConflictFailure())),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Horno');
    await tester.enterText(find.byType(TextFormField).at(1), 'Nave 1');
    await tester.tap(find.text('Crear área'));
    await tester.pumpAndSettle();

    expect(find.text('Ya existe un área con ese nombre.'), findsOneWidget);
  });

  testWidgets('area setup renders null limits and an empty device list', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getAreaSetupUseCaseProvider.overrideWithValue(
            _FixedSetup(Success(_setup(limits: false, devices: const []))),
          ),
        ],
        child: const MaterialApp(home: AreaSetupPage(areaId: 'area-1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Horno'), findsOneWidget);
    expect(find.text('Nave 1'), findsOneWidget);
    expect(find.text('No configurado'), findsNWidgets(2));
    expect(find.text('No hay dispositivos asociados.'), findsOneWidget);
    expect(find.text('Configurar umbrales'), findsOneWidget);
    expect(find.text('Agregar dispositivo'), findsOneWidget);
    expect(find.textContaining('0'), findsNothing);
  });

  testWidgets('area setup renders configured limits and devices', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          getAreaSetupUseCaseProvider.overrideWithValue(
            _FixedSetup(
              Success(
                _setup(
                  limits: true,
                  devices: const [
                    AreaDevice(
                      id: 'row-1',
                      deviceId: 'sensor-1',
                      kind: DeviceKind.sensor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: AreaSetupPage(areaId: 'area-1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CO₂: 800 ppm'), findsOneWidget);
    expect(find.text('Ruido: 85 dB'), findsOneWidget);
    expect(find.text('sensor-1 · Sensor'), findsOneWidget);
    expect(find.text('No configurado'), findsNothing);
    expect(find.text('No hay dispositivos asociados.'), findsNothing);
    expect(find.text('Configurar umbrales'), findsOneWidget);
    expect(find.text('Agregar dispositivo'), findsOneWidget);
  });
}

Future<void> _pumpCreate(WidgetTester tester, CreateArea create) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [createAreaUseCaseProvider.overrideWithValue(create)],
      child: const MaterialApp(home: Scaffold(body: CreateAreaPage())),
    ),
  );
}

class _CountingCreate extends CreateArea {
  _CountingCreate(this.result) : super(_IdleRepository());

  final Result<IndustrialArea> result;
  var calls = 0;
  String? name;
  String? location;

  @override
  Future<Result<IndustrialArea>> call({
    required String name,
    required String location,
  }) async {
    calls += 1;
    this.name = name;
    this.location = location;
    return result;
  }
}

class _PendingCreate extends CreateArea {
  _PendingCreate(this.completer) : super(_IdleRepository());

  final Completer<Result<IndustrialArea>> completer;
  var calls = 0;

  @override
  Future<Result<IndustrialArea>> call({
    required String name,
    required String location,
  }) {
    calls += 1;
    return completer.future;
  }
}

class _FixedSetup extends GetAreaSetup {
  _FixedSetup(this.result) : super(_IdleRepository());

  final Result<AreaSetup> result;

  @override
  Future<Result<AreaSetup>> call({required String areaId}) async {
    return result;
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

AreaSetup _setup({required bool limits, required List<AreaDevice> devices}) {
  return AreaSetup(
    id: 'area-1',
    name: 'Horno',
    location: 'Nave 1',
    co2LimitPpm: limits ? 800 : null,
    noiseLimitDb: limits ? 85 : null,
    devices: devices,
  );
}
