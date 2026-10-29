import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/session_revocation.dart';
import '../../../../core/auth/token_storage.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_client.dart';
import '../../application/use_cases/request_credential_recovery.dart';
import '../../application/use_cases/reset_credentials.dart';
import '../../application/use_cases/restore_session.dart';
import '../../application/use_cases/sign_in.dart';
import '../../application/use_cases/sign_out.dart';
import '../../data/datasources/session_local_data_source.dart';
import '../../data/datasources/session_remote_data_source.dart';
import '../../data/mappers/session_mapper.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/session_repository.dart';

part '../controllers/credential_recovery_controller.dart';
part '../controllers/session_controller.dart';

final sessionRevocationProvider = Provider<SessionRevocation>(
  (ref) => SessionRevocation(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final revocation = ref.watch(sessionRevocationProvider);
  return ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),
    onUnauthorized: revocation.revoke,
  );
});

final sessionRemoteDataSourceProvider = Provider<SessionRemoteDataSource>((
  ref,
) {
  return SessionRemoteDataSource(ref.watch(apiClientProvider));
});

final sessionLocalDataSourceProvider = Provider<SessionLocalDataSource>((ref) {
  return SessionLocalDataSource(
    storage: ref.watch(tokenStorageProvider),
    mapper: const SessionMapper(),
  );
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepositoryImpl(
    remote: ref.watch(sessionRemoteDataSourceProvider),
    local: ref.watch(sessionLocalDataSourceProvider),
    mapper: const SessionMapper(),
  );
});

final signInUseCaseProvider = Provider<SignIn>((ref) {
  return SignIn(ref.watch(sessionRepositoryProvider));
});

final restoreSessionUseCaseProvider = Provider<RestoreSession>((ref) {
  return RestoreSession(ref.watch(sessionRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOut>((ref) {
  return SignOut(ref.watch(sessionRepositoryProvider));
});

final requestCredentialRecoveryUseCaseProvider =
    Provider<RequestCredentialRecovery>((ref) {
      return RequestCredentialRecovery(ref.watch(sessionRepositoryProvider));
    });

final resetCredentialsUseCaseProvider = Provider<ResetCredentials>((ref) {
  return ResetCredentials(ref.watch(sessionRepositoryProvider));
});

final recoveryRequestControllerProvider =
    NotifierProvider<RecoveryRequestController, RecoveryState>(
      RecoveryRequestController.new,
    );

final resetCredentialsControllerProvider =
    NotifierProvider<ResetCredentialsController, ResetCredentialsState>(
      ResetCredentialsController.new,
    );

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);
