import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../dtos/request_credential_recovery_dto.dart';
import '../dtos/reset_credentials_request_dto.dart';
import '../dtos/session_dto.dart';
import '../dtos/sign_in_request_dto.dart';

class SessionRemoteDataSource {
  SessionRemoteDataSource(this._client);

  static const _loginPath = '/api/v1/auth/login';

  // TODO: Pending API/domain contract decision.
  static const _logoutPath = '/api/v1/auth/logout';

  // TODO: Pending API/domain contract decision.
  static const _recoveryPath = '/api/v1/auth/recovery';

  // TODO: Pending API/domain contract decision.
  static const _resetPath = '/api/v1/auth/reset';

  final ApiClient _client;

  Future<SessionDto> signIn({
    required String email,
    required String password,
  }) async {
    final body = SignInRequestDto(email: email, password: password).toJson();
    final json = await _client.post(
      _loginPath,
      body: body,
      authenticated: false,
    );
    if (json == null) {
      throw const FormatException('Unexpected login response');
    }
    return SessionDto.fromJson(json);
  }

  Future<void> signOut() async {
    await _client.post(_logoutPath, requiresBody: false);
  }

  Future<void> requestCredentialRecovery({required String email}) async {
    final status = await _client.postStatus(
      _recoveryPath,
      body: RequestCredentialRecoveryDto(email: email).toJson(),
      authenticated: false,
    );
    if (status != 202) {
      throw ApiException(message: 'Unexpected response', statusCode: status);
    }
  }

  Future<void> resetCredentials({
    required String token,
    required String password,
  }) async {
    final status = await _client.postStatus(
      _resetPath,
      body: ResetCredentialsRequestDto(
        token: token,
        password: password,
      ).toJson(),
      authenticated: false,
    );
    if (status != 204) {
      throw ApiException(message: 'Unexpected response', statusCode: status);
    }
  }
}
