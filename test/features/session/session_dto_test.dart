import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/session/data/dtos/session_dto.dart';
import 'package:safeplant_mobile/features/session/data/dtos/sign_in_request_dto.dart';

void main() {
  test('SignInRequestDto always sends the Mobile channel', () {
    final json = const SignInRequestDto(
      email: 'supervisor@plant.test',
      password: 'secret',
    ).toJson();

    expect(json, {
      'email': 'supervisor@plant.test',
      'password': 'secret',
      'channel': 'Mobile',
    });
  });

  test('SessionDto parses a valid login response', () {
    final dto = SessionDto.fromJson({
      'accessToken': 'token-1',
      'role': 'Supervisor',
      'expiresAt': '2026-10-23T20:00:00Z',
    });

    expect(dto.accessToken, 'token-1');
    expect(dto.role, 'Supervisor');
    expect(dto.expiresAt, DateTime.utc(2026, 10, 23, 20));
  });

  test('SessionDto rejects an expiresAt value that is not ISO-8601', () {
    expect(
      () => SessionDto.fromJson({
        'accessToken': 'token-1',
        'role': 'Supervisor',
        'expiresAt': '23/10/2026',
      }),
      throwsFormatException,
    );
  });
}
