import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:safeplant_mobile/app/router/route_names.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/get_latest_readings.dart';
import 'package:safeplant_mobile/features/safety/application/use_cases/get_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_state.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/area_operational_status.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/environmental_alert.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/exposure.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/actuator_action.dart';
import 'package:safeplant_mobile/features/safety/domain/entities/latest_readings.dart';
import 'package:safeplant_mobile/features/safety/domain/repositories/safety_repository.dart';
import 'package:safeplant_mobile/features/safety/presentation/pages/safety_area_detail_page.dart';
import 'package:safeplant_mobile/features/safety/presentation/pages/safety_home_page.dart';
import 'package:safeplant_mobile/features/safety/presentation/providers/safety_providers.dart';
import 'package:safeplant_mobile/features/safety/presentation/widgets/area_operational_status_card.dart';

void main() {
  testWidgets('the dashboard shows areas and null metrics as missing data', (
    tester,
  ) async {
    final useCase = _Scripted(
      Success([
        _area(
          name: 'Horno',
          co2Ppm: null,
          noiseDb: null,
          presenceState: null,
          severity: ExposureSeverity.high,
          alertActive: true,
          highlighted: true,
        ),
        _area(
          id: 'area-2',
          name: 'Nave',
          co2Ppm: 400,
          noiseDb: 60,
          presenceState: PresenceState.cleared,
          severity: ExposureSeverity.none,
          alertActive: false,
          highlighted: false,
        ),
      ]),
    );
    await _pump(tester, useCase);
    await tester.pumpAndSettle();

    expect(find.text('Estado operativo'), findsOneWidget);
    expect(find.text('Hay alertas activas'), findsOneWidget);
    expect(find.text('Horno'), findsOneWidget);
    expect(find.text('CO₂: Sin datos'), findsOneWidget);
    expect(find.text('Ruido: Sin datos'), findsOneWidget);
    expect(find.text('Presencia: Sin datos'), findsOneWidget);
    expect(find.text('CO₂: 400 ppm'), findsOneWidget);
    expect(find.text('Ruido: 60 dB'), findsOneWidget);
    expect(find.text('Severidad: Alta'), findsOneWidget);
    expect(find.text('Severidad: Ninguna'), findsOneWidget);
    expect(find.text('Alerta activa'), findsOneWidget);
    expect(find.text('Destacada'), findsOneWidget);
    expect(find.text('0 ppm'), findsNothing);
    expect(find.text('0 dB'), findsNothing);
  });

  testWidgets('an empty inventory of areas is not an error', (tester) async {
    await _pump(tester, _Scripted(const Success([])));
    await tester.pumpAndSettle();

    expect(
      find.text('No hay información operativa disponible.'),
      findsOneWidget,
    );
    expect(find.text('No se pudo obtener el estado operativo.'), findsNothing);
  });

  testWidgets('pull to refresh reloads the operational status', (tester) async {
    final useCase = _Scripted(
      Success([
        _area(
          name: 'Horno',
          co2Ppm: 800,
          noiseDb: 70,
          presenceState: PresenceState.detected,
          severity: ExposureSeverity.medium,
          alertActive: false,
          highlighted: false,
        ),
      ]),
    );
    await _pump(tester, useCase);
    await tester.pumpAndSettle();
    expect(useCase.calls, 1);

    await tester.fling(find.byType(ListView), const Offset(0, 400), 1200);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(useCase.calls, 2);
  });

  testWidgets(
    'a card keeps Failed distinct from Off and shows barrier states',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AreaOperationalStatusCard(
              status: _area(
                name: 'Horno',
                co2Ppm: 1,
                noiseDb: 1,
                presenceState: PresenceState.detected,
                severity: ExposureSeverity.medium,
                alertActive: false,
                highlighted: false,
                actuators: [
                  _actuator(ActuatorType.extractor, ActuatorRunState.failed),
                  _actuator(ActuatorType.barrier, ActuatorRunState.deployed),
                  _actuator(
                    ActuatorType.barrier,
                    ActuatorRunState.retracted,
                    ActuatorMode.overridden,
                  ),
                ],
              ),
              onOpen: () {},
            ),
          ),
        ),
      );

      expect(find.text('Extractor — Fallo — Automático'), findsOneWidget);
      expect(find.text('Extractor — Apagado — Automático'), findsNothing);
      expect(find.text('Barrier — Desplegado — Automático'), findsOneWidget);
      expect(find.text('Barrier — Replegado — Anulado'), findsOneWidget);
    },
  );

  testWidgets('opening an area shows its operational detail', (tester) async {
    await _pump(
      tester,
      _Scripted(
        Success([
          _area(
            name: 'Horno',
            co2Ppm: 810,
            noiseDb: 88,
            presenceState: PresenceState.detected,
            severity: ExposureSeverity.high,
            alertActive: true,
            highlighted: true,
            actuators: [_actuator(ActuatorType.siren, ActuatorRunState.off)],
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Horno'));
    await tester.pumpAndSettle();

    expect(_detailText('Actuadores'), findsOneWidget);
    expect(_detailText('Siren — Apagado — Automático'), findsOneWidget);
    expect(_detailText('Alerta activa'), findsOneWidget);
    expect(_detailText('CO₂: 810 ppm'), findsOneWidget);
  });
}

Finder _detailText(String text) {
  return find.descendant(
    of: find.byType(SafetyAreaDetailPage),
    matching: find.text(text, skipOffstage: false),
  );
}

Future<void> _pump(WidgetTester tester, GetOperationalStatus useCase) {
  final router = GoRouter(
    initialLocation: RouteNames.safety,
    routes: [
      GoRoute(
        path: RouteNames.safety,
        builder: (context, state) => const SafetyHomePage(),
      ),
      GoRoute(
        path: '/app/safety/areas/:areaId',
        builder: (context, state) {
          final extra = state.extra;
          return SafetyAreaDetailPage(
            status: extra is AreaOperationalStatus ? extra : null,
          );
        },
      ),
    ],
  );
  addTearDown(router.dispose);
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        getOperationalStatusUseCaseProvider.overrideWithValue(useCase),
        getLatestReadingsUseCaseProvider.overrideWithValue(
          GetLatestReadings(_QuietReadings()),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

AreaOperationalStatus _area({
  String id = 'area-1',
  required String name,
  required num? co2Ppm,
  required num? noiseDb,
  required PresenceState? presenceState,
  required ExposureSeverity severity,
  required bool alertActive,
  required bool highlighted,
  List<ActuatorState> actuators = const [],
}) {
  return AreaOperationalStatus(
    areaId: id,
    name: name,
    co2Ppm: co2Ppm,
    noiseDb: noiseDb,
    presenceState: presenceState,
    severity: severity,
    alertActive: alertActive,
    highlighted: highlighted,
    actuators: actuators,
  );
}

ActuatorState _actuator(
  ActuatorType type,
  ActuatorRunState runState, [
  ActuatorMode mode = ActuatorMode.auto,
]) {
  return ActuatorState(
    type: type,
    runState: runState,
    mode: mode,
    lastChangedAt: DateTime.utc(2026, 3, 1),
  );
}

class _Scripted extends GetOperationalStatus {
  _Scripted(this.result) : super(_IdleRepository());

  final Result<List<AreaOperationalStatus>> result;
  var calls = 0;

  @override
  Future<Result<List<AreaOperationalStatus>>> call() async {
    calls += 1;
    return result;
  }
}

class _QuietReadings implements SafetyRepository {
  @override
  Future<Result<List<AreaOperationalStatus>>> getOperationalStatus() {
    throw UnimplementedError();
  }

  @override
  Future<Result<LatestReadings>> getLatestReadings({required String areaId}) {
    return Future.value(
      const Success(
        LatestReadings(carbonDioxide: null, noise: null, presence: null),
      ),
    );
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

class _IdleRepository implements SafetyRepository {
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

  @override
  Future<Result<ActuatorState>> overrideActuator({
    required String areaId,
    required ActuatorType type,
    required ActuatorRunState targetState,
  }) {
    throw UnimplementedError();
  }
}
