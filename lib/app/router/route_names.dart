abstract final class RouteNames {
  static const bootstrap = '/bootstrap';
  static const signIn = '/sign-in';
  static const recovery = '/recovery';
  static const reset = '/reset';
  static const appShell = '/app';
  static const safety = '/app/safety';
  static const activeAlerts = '/app/safety/alerts';

  static String safetyArea(String areaId) {
    return '/app/safety/areas/${Uri.encodeComponent(areaId)}';
  }

  static String shortExposureHistory(String areaId) {
    return '/app/safety/areas/${Uri.encodeComponent(areaId)}/exposure';
  }

  static String actuatorActions(String areaId) {
    return '/app/safety/areas/${Uri.encodeComponent(areaId)}/actions';
  }

  static String actuatorOverride(String areaId) {
    return '/app/safety/areas/${Uri.encodeComponent(areaId)}/override';
  }

  static const plantSetup = '/app/setup';
  static const createArea = '/app/setup/new';

  static String areaSetup(String areaId) => '/app/setup/areas/$areaId';

  static String configureThresholds(
    String areaId, {
    num? co2LimitPpm,
    num? noiseLimitDb,
  }) {
    final path = '/app/setup/areas/${Uri.encodeComponent(areaId)}/thresholds';
    final query = <String, String>{};
    if (co2LimitPpm != null) {
      query['co2LimitPpm'] = '$co2LimitPpm';
    }
    if (noiseLimitDb != null) {
      query['noiseLimitDb'] = '$noiseLimitDb';
    }
    if (query.isEmpty) {
      return path;
    }
    return Uri(path: path, queryParameters: query).toString();
  }

  static String registerDevice(String areaId) {
    return '/app/setup/areas/${Uri.encodeComponent(areaId)}/devices/new';
  }

  static const deviceInventory = '/app/setup/devices';
}
