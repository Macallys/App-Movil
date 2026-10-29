import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/sign_in.dart';
import 'package:safeplant_mobile/features/session/domain/entities/session.dart';
import 'package:safeplant_mobile/features/session/domain/repositories/session_repository.dart';

void main() {
  test(
    'SignIn forwards email and password and persists a supervisor',
    () async {
      final repository = _RecordingRepository();
      final useCase = SignIn(repository);

      final result = await useCase.call(
        email: 'supervisor@plant.test',
        password: 'secret',
      );

      expect(repository.email, 'supervisor@plant.test');
      expect(repository.password, 'secret');
      expect(result, isA<Success<Session>>());
      expect(repository.persisted?.role, UserRole.supervisor);
    },
  );

  test('SignIn does not persist PlantManager', () async {
    final repository = _RecordingRepository(role: UserRole.plantManager);
    final useCase = SignIn(repository);

    await useCase.call(email: 'manager@plant.test', password: 'secret');

    expect(repository.persisted, isNull);
  });
}

class _RecordingRepository implements SessionRepository {
  _RecordingRepository({this.role = UserRole.supervisor});

  final UserRole role;
  String? email;
  String? password;
  Session? persisted;
  var clears = 0;

  @override
  Future<void> clearPersistedSession() async {
    clears += 1;
    persisted = null;
  }

  @override
  Future<void> persistSession(Session session) async {
    persisted = session;
  }

  @override
  Future<Session?> readPersistedSession() async => persisted;

  @override
  Future<Result<Session>> signIn({
    required String email,
    required String password,
  }) async {
    this.email = email;
    this.password = password;
    return Success(
      Session(
        accessToken: 'token',
        role: role,
        expiresAt: DateTime.utc(2026, 10, 23, 20),
      ),
    );
  }

  @override
  Future<Failure?> signOut() async {
    await clearPersistedSession();
    return null;
  }

  @override
  Future<Result<Unit>> requestCredentialRecovery({required String email}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Unit>> resetCredentials({
    required String token,
    required String password,
  }) {
    throw UnimplementedError();
  }
}
