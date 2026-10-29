import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/configure_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/pages/configure_thresholds_page.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/providers/plant_setup_providers.dart';

void main() {
  testWidgets('both limits are required', (tester) async {
    final useCase = _Counting(const FailureResult(UnknownFailure()));
    await _pump(
      tester,
      useCase,
      const ConfigureThresholdsPage(areaId: 'area-1'),
    );

    await tester.tap(find.text('Guardar configuración'));
    await tester.pump();

    expect(find.text('El valor es obligatorio'), findsNWidgets(2));
    expect(useCase.calls, 0);
  });

  testWidgets('numeric values keep decimals', (tester) async {
    final useCase = _Counting(
      const Success(
        AreaThresholds(areaId: 'area-1', co2LimitPpm: 800, noiseLimitDb: 85.5),
      ),
    );
    await _pump(
      tester,
      useCase,
      const ConfigureThresholdsPage(areaId: 'area-1'),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '800');
    await tester.enterText(find.byType(TextFormField).at(1), '85.5');
    await tester.tap(find.text('Guardar configuración'));
    await tester.pumpAndSettle();

    expect(useCase.calls, 1);
    expect(useCase.areaId, 'area-1');
    expect(useCase.co2LimitPpm, 800);
    expect(useCase.noiseLimitDb, 85.5);
    expect(find.text('Configuración guardada'), findsOneWidget);
    expect(find.text('Ruido: 85.5 dB'), findsOneWidget);
  });

  testWidgets('current limits are prefilled', (tester) async {
    await _pump(
      tester,
      _Counting(const FailureResult(UnknownFailure())),
      const ConfigureThresholdsPage(
        areaId: 'area-1',
        co2LimitPpm: 800,
        noiseLimitDb: 85.5,
      ),
    );

    expect(_text(tester, 0), '800');
    expect(_text(tester, 1), '85.5');
  });

  testWidgets('null limits leave the fields empty', (tester) async {
    await _pump(
      tester,
      _Counting(const FailureResult(UnknownFailure())),
      const ConfigureThresholdsPage(areaId: 'area-1'),
    );

    expect(_text(tester, 0), isEmpty);
    expect(_text(tester, 1), isEmpty);
  });

  testWidgets('loading blocks a second save', (tester) async {
    final useCase = _Pending(Completer<Result<AreaThresholds>>());
    await _pump(
      tester,
      useCase,
      const ConfigureThresholdsPage(areaId: 'area-1'),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '800');
    await tester.enterText(find.byType(TextFormField).at(1), '70');
    await tester.tap(find.text('Guardar configuración'));
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(useCase.calls, 1);
  });

  testWidgets('a validation failure shows the message', (tester) async {
    await _pump(
      tester,
      _Counting(const FailureResult(ValidationFailure())),
      const ConfigureThresholdsPage(areaId: 'area-1'),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '800');
    await tester.enterText(find.byType(TextFormField).at(1), '70');
    await tester.tap(find.text('Guardar configuración'));
    await tester.pumpAndSettle();

    expect(find.text('Los valores ingresados no son válidos.'), findsOneWidget);
  });
}

String _text(WidgetTester tester, int index) {
  return tester
      .widget<TextField>(find.byType(TextField).at(index))
      .controller!
      .text;
}

Future<void> _pump(
  WidgetTester tester,
  ConfigureThresholds useCase,
  Widget page,
) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        configureThresholdsUseCaseProvider.overrideWithValue(useCase),
      ],
      child: MaterialApp(home: Scaffold(body: page)),
    ),
  );
}

class _Counting extends ConfigureThresholds {
  _Counting(this.result) : super(_IdleRepository());

  final Result<AreaThresholds> result;
  var calls = 0;
  String? areaId;
  num? co2LimitPpm;
  num? noiseLimitDb;

  @override
  Future<Result<AreaThresholds>> call({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) async {
    calls += 1;
    this.areaId = areaId;
    this.co2LimitPpm = co2LimitPpm;
    this.noiseLimitDb = noiseLimitDb;
    return result;
  }
}

class _Pending extends ConfigureThresholds {
  _Pending(this.completer) : super(_IdleRepository());

  final Completer<Result<AreaThresholds>> completer;
  var calls = 0;

  @override
  Future<Result<AreaThresholds>> call({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) {
    calls += 1;
    return completer.future;
  }
}

class _IdleRepository implements PlantSetupRepository {
  @override
  Future<Result<AreaThresholds>> configureEnvironmentalThresholds({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
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
