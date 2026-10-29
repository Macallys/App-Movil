import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the main manifest grants internet outside debug builds', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();

    expect(manifest, contains('android.permission.INTERNET'));
    expect(manifest, contains('android:label="SafePlant Supervisor"'));
    expect(manifest, isNot(contains('usesCleartextTraffic')));
  });
}
