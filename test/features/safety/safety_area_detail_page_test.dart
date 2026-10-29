import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/get_latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';
import 'package:safeplant_mobile/features/safety/presentation/pages/safety_area_detail_page.dart';
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';
import 'package:safeplant_mobile/features/safety/presentation/safety_labels.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';

void main() {
  testWidgets('shows each reading with its own device and time', (
    tester,
  ) async {
    final co2At = DateTime.utc(2026, 5, 20, 15, 35);
    final noiseAt = DateTime.utc(2026, 5, 20, 15, 33);
    final presenceAt = DateTime.utc(2026, 5, 20, 15, 36);
    await _pump(
      tester,
      LatestReadings(
        carbonDioxide: CarbonDioxideReading(
          deviceId: 'co2-1',
          ppm: 810,
          recordedAt: co2At,
        ),
        noise: NoiseReading(
          deviceId: 'noise-1',
          decibels: 85.5,
          recordedAt: noiseAt,
        ),
        presence: PresenceReading(
          deviceId: 'presence-1',
          state: PresenceState.detected,
          recordedAt: presenceAt,
        ),
      ),
    );

    expect(find.text('Últimas lecturas'), findsOneWidget);
    expect(find.text('810 ppm'), findsOneWidget);
    expect(find.text('85.5 dB'), findsOneWidget);
    expect(find.text('Detectada'), findsOneWidget);
    expect(find.text('Dispositivo: co2-1'), findsOneWidget);
    expect(find.text('Dispositivo: noise-1'), findsOneWidget);
    expect(find.text('Dispositivo: presence-1'), findsOneWidget);
    expect(find.text(formatStatusDate(co2At)), findsOneWidget);
    expect(find.text(formatStatusDate(noiseAt)), findsOneWidget);
    expect(find.text(formatStatusDate(presenceAt)), findsOneWidget);
    expect(formatStatusDate(co2At), isNot(formatStatusDate(noiseAt)));
  });

  testWidgets('a missing reading does not hide the others', (tester) async {
    await _pump(
      tester,
      LatestReadings(
        carbonDioxide: CarbonDioxideReading(
          deviceId: 'co2-1',
          ppm: 810,
          recordedAt: DateTime.utc(2026, 5, 20, 15, 35),
        ),
        noise: null,
        presence: PresenceReading(
          deviceId: 'presence-1',
          state: PresenceState.cleared,
          recordedAt: DateTime.utc(2026, 5, 20, 15, 36),
        ),
      ),
    );

    expect(find.text('810 ppm'), findsOneWidget);
    expect(find.text('Despejada'), findsOneWidget);
    expect(find.text('Sin lectura reciente'), findsOneWidget);
    expect(
      find.text('No hay telemetría reciente disponible para esta área.'),
      findsNothing,
    );
  });

  testWidgets('three null readings show one empty message', (tester) async {
    await _pump(
      tester,
      const LatestReadings(carbonDioxide: null, noise: null, presence: null),
    );

    expect(
      find.text('No hay telemetría reciente disponible para esta área.'),
      findsOneWidget,
    );
    expect(find.text('Sin lectura reciente'), findsNothing);
  });

  testWidgets('pull to refresh reloads latest readings', (tester) async {
    final repository = _Repository(
      const Success(
        LatestReadings(carbonDioxide: null, noise: null, presence: null),
      ),
    );
    await _pumpRepository(tester, repository);
    expect(repository.calls, 1);

    await tester.fling(
      find.byType(SingleChildScrollView),
      const Offset(0, 300),
      1000,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(repository.calls, 2);
  });
}

Future<void> _pump(WidgetTester tester, LatestReadings readings) {
  return _pumpRepository(tester, _Repository(Success(readings)));
}

Future<void> _pumpRepository(WidgetTester tester, _Repository repository) {
  return tester
      .pumpWidget(
        ProviderScope(
          overrides: [
            getLatestReadingsUseCaseProvider.overrideWithValue(
              GetLatestReadings(repository),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(body: SafetyAreaDetailPage(status: _area())),
          ),
        ),
      )
      .then((_) => tester.pumpAndSettle());
}

AreaOperationalStatus _area() {
  return AreaOperationalStatus(
    areaId: 'area-1',
    name: 'Horno',
    co2Ppm: null,
    noiseDb: null,
    presenceState: null,
    severity: ExposureSeverity.none,
    alertActive: false,
    highlighted: false,
    actuators: const [],
  );
}

class _Repository implements SafetyRepository {
  _Repository(this.result);

  final Result<LatestReadings> result;
  var calls = 0;

  @override
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() {
    throw UnimplementedError();
  }

  @override
  Future<Result<LatestReadings>> getLatestReadings({required String areaId}) {
    calls += 1;
    return Future.value(result);
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

  @override
  Future<Result<ActuatorState>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    throw UnimplementedError();
  }
}
