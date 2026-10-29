import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/override_actuator.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';
import 'package:safeplant_mobile/features/safety/presentation/pages/actuator_override_page.dart';
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';

void main() {
  testWidgets('extractor offers only on and off', (tester) async {
    await _pump(
      tester,
      _actuator(ActuatorType.extractor, ActuatorRunState.on),
      _Repository(const []),
    );

    expect(find.text('Encender'), findsOneWidget);
    expect(find.text('Apagar'), findsOneWidget);
    expect(find.text('Desplegar'), findsNothing);
    expect(find.text('Replegar'), findsNothing);
    expect(find.text('Activar'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Fallo'), findsNothing);
    expect(_enabled('Encender'), isFalse);
    expect(_enabled('Apagar'), isTrue);
  });

  testWidgets('siren offers activate and deactivate', (tester) async {
    await _pump(
      tester,
      _actuator(ActuatorType.siren, ActuatorRunState.off),
      _Repository(const []),
    );

    expect(find.text('Activar'), findsOneWidget);
    expect(find.text('Desactivar'), findsOneWidget);
    expect(find.text('Encender'), findsNothing);
    expect(find.text('Desplegar'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Fallo'), findsNothing);
  });

  testWidgets('barrier offers deploy and retract', (tester) async {
    await _pump(
      tester,
      _actuator(ActuatorType.barrier, ActuatorRunState.deployed),
      _Repository(const []),
    );

    expect(find.text('Desplegar'), findsOneWidget);
    expect(find.text('Replegar'), findsOneWidget);
    expect(find.text('Encender'), findsNothing);
    expect(find.text('Apagar'), findsNothing);
    expect(find.text('Estado actual: Desplegado'), findsOneWidget);
    expect(_enabled('Desplegar'), isFalse);
    expect(_enabled('Replegar'), isTrue);
    expect(find.widgetWithText(OutlinedButton, 'Fallo'), findsNothing);
  });

  testWidgets('a failed actuator is not offered as a command', (tester) async {
    await _pump(
      tester,
      _actuator(ActuatorType.extractor, ActuatorRunState.failed),
      _Repository(const []),
    );

    expect(find.text('Estado actual: Fallo'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Fallo'), findsNothing);
    expect(_enabled('Encender'), isTrue);
    expect(_enabled('Apagar'), isTrue);
  });

  testWidgets('confirmation happens before the request', (tester) async {
    final repository = _Repository([
      Future.value(
        Success(_actuator(ActuatorType.extractor, ActuatorRunState.off)),
      ),
    ]);
    await _pump(
      tester,
      _actuator(ActuatorType.extractor, ActuatorRunState.on),
      repository,
    );

    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();

    expect(find.text('Confirmar control manual'), findsOneWidget);
    expect(
      find.text('Se enviará el comando Apagar al extractor del área Horno.'),
      findsOneWidget,
    );
    expect(repository.calls, 0);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(repository.calls, 0);
  });

  testWidgets('submitting keeps the previous state until success', (
    tester,
  ) async {
    final pending = Completer<Result<ActuatorState>>();
    final repository = _Repository([pending.future]);
    await _pump(
      tester,
      _actuator(ActuatorType.extractor, ActuatorRunState.on),
      repository,
    );

    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pump();

    expect(find.text('Estado actual: Encendido'), findsOneWidget);
    expect(find.text('Modo: Automático'), findsOneWidget);
    expect(_enabled('Apagar'), isFalse);
    expect(repository.calls, 1);

    await tester.tap(find.text('Apagar'), warnIfMissed: false);
    expect(repository.calls, 1);

    pending.complete(
      Success(
        _actuator(
          ActuatorType.extractor,
          ActuatorRunState.off,
          mode: ActuatorMode.overridden,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Estado actual: Apagado'), findsOneWidget);
    expect(find.text('Modo: Anulado'), findsOneWidget);
    expect(find.text('Comando aplicado correctamente.'), findsOneWidget);
    expect(find.text('Estado actual: Encendido'), findsNothing);
  });

  testWidgets('edge unavailable keeps the actuator unchanged', (tester) async {
    final repository = _Repository([
      Future.value(const FailureResult(EdgeUnavailableFailure())),
    ]);
    await _pump(
      tester,
      _actuator(ActuatorType.extractor, ActuatorRunState.on),
      repository,
    );

    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'No se pudo entregar el comando al dispositivo Edge.',
      ),
      findsOneWidget,
    );
    expect(find.text('No se pudo conectar con el servidor.'), findsNothing);
    expect(find.text('Estado actual: Encendido'), findsOneWidget);
    expect(find.text('Modo: Automático'), findsOneWidget);
  });

  testWidgets('network failure keeps the actuator unchanged', (tester) async {
    final repository = _Repository([
      Future.value(const FailureResult(NetworkFailure())),
    ]);
    await _pump(
      tester,
      _actuator(ActuatorType.barrier, ActuatorRunState.retracted),
      repository,
    );

    await tester.tap(find.text('Desplegar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo conectar con el servidor.'), findsOneWidget);
    expect(find.textContaining('dispositivo Edge'), findsNothing);
    expect(find.text('Estado actual: Replegado'), findsOneWidget);
  });
}

bool _enabled(String label) {
  final button = find.widgetWithText(OutlinedButton, label);
  return button.evaluate().single.widget is OutlinedButton &&
      (button.evaluate().single.widget as OutlinedButton).onPressed != null;
}

Future<void> _pump(
  WidgetTester tester,
  ActuatorState actuator,
  _Repository repository,
) {
  return tester
      .pumpWidget(
        ProviderScope(
          overrides: [
            overrideActuatorUseCaseProvider.overrideWithValue(
              OverrideActuator(repository),
            ),
          ],
          child: MaterialApp(
            home: ActuatorOverridePage(
              target: ActuatorOverrideTarget(
                areaId: 'area-1',
                areaName: 'Horno',
                actuator: actuator,
              ),
            ),
          ),
        ),
      )
      .then((_) => tester.pumpAndSettle());
}

ActuatorState _actuator(
  ActuatorType type,
  ActuatorRunState runState, {
  ActuatorMode mode = ActuatorMode.auto,
}) {
  return ActuatorState(
    type: type,
    runState: runState,
    mode: mode,
    lastChangedAt: DateTime.utc(2026, 5, 20, 16),
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.pending);

  final List<Future<Result<ActuatorState>>> pending;
  var calls = 0;

  @override
  Future<Result<ActuatorState>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    final result = pending[calls];
    calls += 1;
    return result;
  }

  @override
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() {
    throw UnimplementedError();
  }

  @override
  Future<Result<LatestReadings>> getLatestReadings({required String areaId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<EnvironmentalAlert>>> getActiveAlerts() {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Exposure>>> getShortExposureHistory({
    required String areaId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<ActuatorAction>>> getActuatorActions({
    required String areaId,
  }) {
    throw UnimplementedError();
  }
}
