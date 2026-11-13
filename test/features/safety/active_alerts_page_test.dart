import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/get_active_alerts.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';
import 'package:safeplant_mobile/features/safety/presentation/pages/active_alerts_page.dart';
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';
import 'package:safeplant_mobile/features/safety/presentation/safety_labels.dart';

void main() {
  testWidgets('renders alerts with open state and independent times', (
    tester,
  ) async {
    final older = DateTime.utc(2026, 5, 20, 15, 30);
    final newer = DateTime.utc(2026, 5, 20, 15, 40);
    await _pump(
      tester,
      _Repository([
        Success([
          _alert('alert-old', recordedAt: older),
          _alert('alert-new', areaId: 'area-2', recordedAt: newer),
        ]),
      ]),
    );

    expect(find.text('Alertas activas'), findsOneWidget);
    expect(find.text('Área: area-2'), findsOneWidget);
    expect(find.text('Área: area-1'), findsOneWidget);
    expect(find.text('Alerta abierta'), findsNWidgets(2));
    expect(find.text('Inicio: ${formatStatusDate(newer)}'), findsOneWidget);
    expect(find.text('Inicio: ${formatStatusDate(older)}'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Área: area-2')).dy,
      lessThan(tester.getTopLeft(find.text('Área: area-1')).dy),
    );
  });

  testWidgets('an empty list is a valid state', (tester) async {
    await _pump(tester, _Repository([const Success([])]));

    expect(find.text('No hay alertas activas.'), findsOneWidget);
    expect(find.text('No se pudo obtener las alertas activas.'), findsNothing);
  });

  testWidgets('pull to refresh reloads without another timer', (tester) async {
    final repository = _Repository([
      Success([_alert('alert-1')]),
      Success([_alert('alert-2', areaId: 'area-9')]),
    ]);
    await _pump(tester, repository);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.text('Área: area-9'), findsOneWidget);
  });

  testWidgets('a background refresh failure keeps the visible alerts', (
    tester,
  ) async {
    final repository = _Repository([
      Success([_alert('alert-1')]),
      const FailureResult(NetworkFailure()),
    ]);
    await _pump(tester, repository);

    await tester.pump(const Duration(seconds: 15));
    await tester.pumpAndSettle();

    expect(find.text('Área: area-1'), findsOneWidget);
    expect(find.text('No se pudo obtener las alertas activas.'), findsNothing);
  });
}

Future<void> _pump(
  WidgetTester tester,
  _Repository repository, {
  String? areaId,
}) {
  return tester
      .pumpWidget(
        ProviderScope(
          overrides: [
            getActiveAlertsUseCaseProvider.overrideWithValue(
              GetActiveAlerts(repository),
            ),
          ],
          child: MaterialApp(home: ActiveAlertsPage(areaId: areaId)),
        ),
      )
      .then((_) => tester.pumpAndSettle());
}

EnvironmentalAlert _alert(
  String alertId, {
  String areaId = 'area-1',
  DateTime? recordedAt,
}) {
  return EnvironmentalAlert(
    id: alertId,
    areaId: areaId,
    raisedAt: recordedAt ?? DateTime.utc(2026, 5, 20, 15, 35),
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.results);

  final List<Result<List<EnvironmentalAlert>>> results;
  var calls = 0;

  @override
  Future<Result<List<EnvironmentalAlert>>> getActiveAlerts() async {
    final result = results[calls];
    calls += 1;
    return result;
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
  Future<Result<Unit>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    throw UnimplementedError();
  }
}
