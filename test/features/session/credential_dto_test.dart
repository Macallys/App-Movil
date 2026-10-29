import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/session/data/dtos/request_credential_recovery_dto.dart';
import 'package:safeplant_mobile/features/session/data/dtos/reset_credentials_request_dto.dart';

void main() {
  test('recovery request serializes only email', () {
    final json = const RequestCredentialRecoveryDto(
      email: 'supervisor@plant.test',
    ).toJson();

    expect(json, {'email': 'supervisor@plant.test'});
  });

  test('reset request serializes only token and password', () {
    final json = const ResetCredentialsRequestDto(
      token: 'recovery-token',
      password: 'new-secret',
    ).toJson();

    expect(json, {'token': 'recovery-token', 'password': 'new-secret'});
  });
}
