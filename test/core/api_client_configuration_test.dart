import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/network/api_client.dart';
import 'package:safeplant_mobile/core/network/api_exception.dart';
import 'package:safeplant_mobile/core/network/base_url_policy.dart';

void main() {
  test('an empty host is rejected and cleartext is release-only', () {
    expect(assessBaseUrl('', release: false), BaseUrlDecision.missing);
    expect(assessBaseUrl('   ', release: true), BaseUrlDecision.missing);
    expect(
      assessBaseUrl('http://10.0.2.2:8080', release: false),
      BaseUrlDecision.allowed,
    );
    expect(
      assessBaseUrl('http://10.0.2.2:8080', release: true),
      BaseUrlDecision.cleartext,
    );
    expect(
      assessBaseUrl('https://api.example.test', release: true),
      BaseUrlDecision.allowed,
    );
  });

  test('the default client fails before opening a socket', () async {
    final client = ApiClient();

    await expectLater(
      client.post(
        '/api/v1/auth/login',
        body: const {'email': 'a@b.c', 'password': 'secret'},
        authenticated: false,
      ),
      throwsA(
        isA<ApiException>().having(
          (error) => error.statusCode,
          'statusCode',
          isNull,
        ),
      ),
    );
  });

  test('timeouts are finite technical limits', () {
    expect(ApiClient.connectTimeout, const Duration(seconds: 15));
    expect(ApiClient.sendTimeout, const Duration(seconds: 20));
    expect(ApiClient.receiveTimeout, const Duration(seconds: 20));
  });
}
