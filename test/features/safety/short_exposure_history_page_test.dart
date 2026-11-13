import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/get_short_exposure_history.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';
import 'package:safeplant_mobile/features/safety/presentation/pages/short_exposure_history_page.dart';
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';
import 'package:safeplant_mobile/features/safety/presentation/safety_labels.dart';

void main() {
  testWidgets('renders records with open state and readable times', (
    tester,
  ) async {
    final older = DateTime.utc(2026, 5, 20, 15, 20);
    final newer = DateTime.utc(2026, 5, 20, 15, 40);
    await _pump(
      tester,
      _Repository([
        Success([
          _exposure('exposure-old', recordedAt: older),
          _exposure('exposure-new', recordedAt: newer),
        ]),
      ]),
    );

    expect(find.text('Exposición reciente'), findsOneWidget);
    expect(find.text('Exposición abierta'), findsNWidgets(2));
    expect(find.text('Inicio: ${formatStatusDate(newer)}'), findsOneWidget);
    expect(find.text('Inicio: ${formatStatusDate(older)}'), findsOneWidget);
    expect(find.text('Desde'), findsNothing);
    expect(find.text('Hasta'), findsNothing);
    expect(find.text('Exportar'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Inicio: ${formatStatusDate(newer)}')).dy,
      lessThan(
        tester.getTopLeft(find.text('Inicio: ${formatStatusDate(older)}')).dy,
      ),
    );
  });

  testWidgets('an empty history is a valid state', (tester) async {
    await _pump(tester, _Repository([const Success([])]));

    expect(
      find.text('No hay exposiciones recientes registradas.'),
      findsOneWidget,
    );
    expect(
      find.text('No se pudo obtener la exposición reciente.'),
      findsNothing,
    );
  });

  testWidgets('pull to refresh reloads the history', (tester) async {
    final repository = _Repository([
      Success([_exposure('exposure-1')]),
      Success([
        _exposure(
          'exposure-2',
          withdrawnAt: DateTime.utc(2026, 5, 20, 16),
        ),
      ]),
    ]);
    await _pump(tester, repository);

    await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
    expect(find.text('Exposición retirada'), findsOneWidget);
  });
}

Future<void> _pump(WidgetTester tester, _Repository repository) {
  return tester
      .pumpWidget(
        ProviderScope(
          overrides: [
            getShortExposureHistoryUseCaseProvider.overrideWithValue(
              GetShortExposureHistory(repository),
            ),
          ],
          child: const MaterialApp(
            home: ShortExposureHistoryPage(areaId: 'area-1'),
          ),
        ),
      )
      .then((_) => tester.pumpAndSettle());
}

Exposure _exposure(
  String exposureId, {
  DateTime? recordedAt,
  DateTime? withdrawnAt,
}) {
  return Exposure(
    id: exposureId,
    areaId: 'area-1',
    raisedAt: recordedAt ?? DateTime.utc(2026, 5, 20, 15, 40),
    withdrawnAt: withdrawnAt,
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.results);

  final List<Result<List<Exposure>>> results;
  var calls = 0;

  @override
  Future<Result<List<Exposure>>> getShortExposureHistory({
    required String areaId,
  }) async {
    final result = results[calls];
    calls += 1;
    return result;
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
  Future<Result<List<EnvironmentalAlert>>> getActiveAlerts() {
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
