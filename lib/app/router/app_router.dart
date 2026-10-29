import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/plant_setup/presentation/pages/area_setup_page.dart';
import '../../features/plant_setup/presentation/pages/configure_thresholds_page.dart';
import '../../features/plant_setup/presentation/pages/create_area_page.dart';
import '../../features/plant_setup/presentation/pages/device_inventory_page.dart';
import '../../features/plant_setup/presentation/pages/plant_setup_home_page.dart';
import '../../features/plant_setup/presentation/pages/register_device_page.dart';
import '../../features/safety/domain/entities/area_operational_status.dart';
import '../../features/safety/presentation/pages/actuator_override_page.dart';
import '../../features/safety/presentation/pages/active_alerts_page.dart';
import '../../features/safety/presentation/pages/actuator_actions_page.dart';
import '../../features/safety/presentation/pages/safety_area_detail_page.dart';
import '../../features/safety/presentation/pages/short_exposure_history_page.dart';
import '../../features/safety/presentation/pages/safety_home_page.dart';
import '../../features/session/presentation/pages/recovery_page.dart';
import '../../features/session/presentation/pages/reset_credentials_page.dart';
import '../../features/session/presentation/pages/sign_in_page.dart';
import '../../features/session/presentation/providers/session_providers.dart';
import '../shell/app_shell.dart';
import '../shell/bootstrap_page.dart';
import 'route_names.dart';

const _authLocations = {
  RouteNames.signIn,
  RouteNames.recovery,
  RouteNames.reset,
};

bool _insideShell(String location) {
  return location == RouteNames.safety ||
      location.startsWith('${RouteNames.safety}/') ||
      location == RouteNames.plantSetup ||
      location.startsWith('${RouteNames.plantSetup}/');
}

/// Auth guard. SessionController is the only source of session state.
String? resolveAppRedirect(SessionState session, String location) {
  if (session is SessionInitial || session is SessionRestoring) {
    return location == RouteNames.bootstrap ? null : RouteNames.bootstrap;
  }
  if (session is SessionAuthenticated) {
    return _insideShell(location) ? null : RouteNames.safety;
  }
  if (session is SessionFailed && location == RouteNames.bootstrap) {
    return null;
  }
  if (_authLocations.contains(location)) {
    return null;
  }
  return RouteNames.signIn;
}

num? _optionalNum(String? raw) {
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return num.tryParse(raw);
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionControllerProvider, (_, _) {
    refresh.value++;
  });

  final router = GoRouter(
    initialLocation: RouteNames.bootstrap,
    refreshListenable: refresh,
    redirect: (context, state) {
      return resolveAppRedirect(
        ref.read(sessionControllerProvider),
        state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: RouteNames.bootstrap,
        builder: (context, state) => const BootstrapPage(),
      ),
      GoRoute(
        path: RouteNames.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: RouteNames.recovery,
        builder: (context, state) => const RecoveryPage(),
      ),
      GoRoute(
        path: RouteNames.reset,
        builder: (context, state) => const ResetCredentialsPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.safety,
            builder: (context, state) => const SafetyHomePage(),
          ),
          GoRoute(
            path: RouteNames.activeAlerts,
            builder: (context, state) {
              return ActiveAlertsPage(
                areaId: state.uri.queryParameters['areaId'],
              );
            },
          ),
          GoRoute(
            path: '/app/safety/areas/:areaId/exposure',
            builder: (context, state) {
              return ShortExposureHistoryPage(
                areaId: state.pathParameters['areaId']!,
              );
            },
          ),
          GoRoute(
            path: '/app/safety/areas/:areaId/actions',
            builder: (context, state) {
              return ActuatorActionsPage(
                areaId: state.pathParameters['areaId']!,
              );
            },
          ),
          GoRoute(
            path: '/app/safety/areas/:areaId/override',
            builder: (context, state) {
              final extra = state.extra;
              final areaId = state.pathParameters['areaId'];
              if (extra is! ActuatorOverrideTarget || extra.areaId != areaId) {
                return const Center(child: Text('No hay actuador disponible.'));
              }
              return ActuatorOverridePage(target: extra);
            },
          ),
          GoRoute(
            path: '/app/safety/areas/:areaId',
            builder: (context, state) {
              final extra = state.extra;
              final status = extra is AreaOperationalStatus ? extra : null;
              if (status != null &&
                  status.areaId != state.pathParameters['areaId']) {
                return const SafetyAreaDetailPage(status: null);
              }
              return SafetyAreaDetailPage(status: status);
            },
          ),
          GoRoute(
            path: RouteNames.plantSetup,
            builder: (context, state) => const PlantSetupHomePage(),
          ),
          GoRoute(
            path: RouteNames.createArea,
            builder: (context, state) => const CreateAreaPage(),
          ),
          GoRoute(
            path: RouteNames.deviceInventory,
            builder: (context, state) => const DeviceInventoryPage(),
          ),
          GoRoute(
            path: '/app/setup/areas/:areaId/devices/new',
            builder: (context, state) {
              return RegisterDevicePage(
                areaId: state.pathParameters['areaId']!,
              );
            },
          ),
          GoRoute(
            path: '/app/setup/areas/:areaId/thresholds',
            builder: (context, state) {
              return ConfigureThresholdsPage(
                areaId: state.pathParameters['areaId']!,
                co2LimitPpm: _optionalNum(
                  state.uri.queryParameters['co2LimitPpm'],
                ),
                noiseLimitDb: _optionalNum(
                  state.uri.queryParameters['noiseLimitDb'],
                ),
              );
            },
          ),
          GoRoute(
            path: '/app/setup/areas/:areaId',
            builder: (context, state) {
              return AreaSetupPage(areaId: state.pathParameters['areaId']!);
            },
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
