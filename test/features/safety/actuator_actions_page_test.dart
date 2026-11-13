import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/get_actuator_actions.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';
import 'package:safeplant_mobile/features/safety/presentation/pages/actuator_actions_page.dart';
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';
import 'package:safeplant_mobile/features/safety/presentation/safety_labels.dart';

void main() {
  testWidgets('renders extractor, siren and barrier outcomes', (tester) async {
    final older = DateTime.utc(2026, 5, 20, 15, 20);
    final newer = DateTime.utc(2026, 5, 20, 15, 45);
    await _pump(
      tester,
      _Repository([
        Success([
          _action(
            'old',
            type: ActuatorType.extractor,
            succeeded: true,
            executedAt: older,
          ),
          _action(
            'siren',
            type: ActuatorType.siren,
            succeeded: true,
            executedAt: newer,
          ),
          _action(
            'deployed',
            type: ActuatorType.barrier,
            succeeded: true,
          ),
          _action(
            'failed',
            type: ActuatorType.extractor,
            succeeded: false,
          ),
        ]),
      ]),
    );

    expect(find.text('Extractor'), findsWidgets);
    expect(find.text('Siren'), findsOneWidget);
    expect(find.text('Barrier'), findsOneWidget);
    expect(find.text('Resultado: Aplicado'), findsNWidgets(3));
    expect(find.text('Resultado: Fallo'), findsOneWidget);
    expect(find.text(formatStatusDate(newer)), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(formatStatusDate(newer))).dy,
      lessThan(tester.getTopLeft(find.text(formatStatusDate(older))).dy),
    );
    expect(find.text('Override'), findsNothing);
    expect(find.text('Turn On'), findsNothing);
    expect(find.text('Turn Off'), findsNothing);
    expect(find.text('Deploy'), findsNothing);
    expect(find.text('Retract'), findsNothing);
    expect(find.text('Reintentar acción'), findsNothing);
  });

  testWidgets('an empty action list is a valid state', (tester) async {
    await _pump(tester, _Repository([const Success([])]));

    expect(
      find.text('No hay acciones recientes de actuadores.'),
      findsOneWidget,
    );
    expect(
      find.text('No se pudo obtener la actividad de actuadores.'),
      findsNothing,
    );
  });

  testWidgets('pull to refresh reloads the actions', (tester) async {
    final repository = _Repository([
      Success([_action('action-1', succeeded: true)]),
      Success([_action('action-2', succeeded: false)]),
    ]);
    await _pump(tester, repository);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.text('Resultado: Fallo'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, _Repository repository) {
  return tester
      .pumpWidget(
        ProviderScope(
          overrides: [
            getActuatorActionsUseCaseProvider.overrideWithValue(
              GetActuatorActions(repository),
            ),
          ],
          child: const MaterialApp(home: ActuatorActionsPage(areaId: 'area-1')),
        ),
      )
      .then((_) => tester.pumpAndSettle());
}

ActuatorAction _action(
  String actionId, {
  ActuatorType type = ActuatorType.extractor,
  bool succeeded = true,
  DateTime? executedAt,
}) {
  return ActuatorAction(
    id: actionId,
    areaId: 'area-1',
    type: type,
    succeeded: succeeded,
    recordedAt: executedAt ?? DateTime.utc(2026, 5, 20, 15, 40),
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.results);

  final List<Result<List<ActuatorAction>>> results;
  var calls = 0;

  @override
  Future<Result<List<ActuatorAction>>> getActuatorActions({
    required String areaId,
  }) async {
    final result = results[calls];
    calls += 1;
    return result;
  }

  @override
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() {
    throw UnimplementedError();
  }

  @override
  Future<Result<AreaOperationalStatus>> getAreaOperationalStatus({
    required String areaId,
  }) {
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
  Future<Result<Unit>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    throw UnimplementedError();
  }
}
