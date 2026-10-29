import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/request_credential_recovery.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/reset_credentials.dart';
import 'package:safeplant_mobile/features/session/domain/entities/session.dart';
import 'package:safeplant_mobile/features/session/domain/repositories/session_repository.dart';
import 'package:safeplant_mobile/features/session/presentation/pages/recovery_page.dart';
import 'package:safeplant_mobile/features/session/presentation/pages/reset_credentials_page.dart';
import 'package:safeplant_mobile/features/session/presentation/providers/session_providers.dart';

void main() {
  testWidgets('recovery button is available and email is required', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const RecoveryPage(), _idleRepository()));

    expect(find.text('Recuperar acceso'), findsWidgets);
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('recoverySubmitButton')))
          .onPressed,
      isNotNull,
    );

    await tester.tap(find.byKey(const Key('recoverySubmitButton')));
    await tester.pump();

    expect(find.text('El correo es obligatorio'), findsOneWidget);
  });

  testWidgets('recovery loading disables a second submit', (tester) async {
    final repository = _PendingRepository(Completer<Result<Unit>>());
    await tester.pumpWidget(_app(const RecoveryPage(), repository));

    await tester.enterText(find.byType(TextFormField), 'supervisor@plant.test');
    await tester.tap(find.byKey(const Key('recoverySubmitButton')));
    await tester.pump();

    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('recoverySubmitButton')))
          .onPressed,
      isNull,
    );
    expect(repository.recoveryCalls, 1);
  });

  testWidgets('reset requires fields and matching passwords', (tester) async {
    final repository = _PendingRepository(Completer<Result<Unit>>());
    await tester.pumpWidget(_app(const ResetCredentialsPage(), repository));

    await tester.tap(find.byKey(const Key('resetSubmitButton')));
    await tester.pump();

    expect(find.text('El código es obligatorio'), findsOneWidget);
    expect(find.text('La contraseña es obligatoria'), findsOneWidget);
    expect(find.text('Confirma la contraseña'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Código de recuperación'),
      'recovery-token',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nueva contraseña'),
      'new-secret',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmar contraseña'),
      'other-secret',
    );
    await tester.tap(find.byKey(const Key('resetSubmitButton')));
    await tester.pump();

    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(repository.resetCalls, 0);
  });

  testWidgets('successful reset shows the return to sign in action', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const ResetCredentialsPage(),
        _PendingRepository(
          Completer<Result<Unit>>()..complete(const Success(Unit())),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Código de recuperación'),
      'recovery-token',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nueva contraseña'),
      'new-secret',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmar contraseña'),
      'new-secret',
    );
    await tester.tap(find.byKey(const Key('resetSubmitButton')));
    await tester.pump();

    expect(find.text('Ir a iniciar sesión'), findsOneWidget);
  });
}

Widget _app(Widget home, SessionRepository repository) {
  return ProviderScope(
    overrides: [
      requestCredentialRecoveryUseCaseProvider.overrideWithValue(
        RequestCredentialRecovery(repository),
      ),
      resetCredentialsUseCaseProvider.overrideWithValue(
        ResetCredentials(repository),
      ),
    ],
    child: MaterialApp(home: home),
  );
}

SessionRepository _idleRepository() {
  return _PendingRepository(Completer<Result<Unit>>());
}

class _PendingRepository implements SessionRepository {
  _PendingRepository(this.completer);

  final Completer<Result<Unit>> completer;
  var recoveryCalls = 0;
  var resetCalls = 0;

  @override
  Future<Result<Unit>> requestCredentialRecovery({required String email}) {
    recoveryCalls += 1;
    return completer.future;
  }

  @override
  Future<Result<Unit>> resetCredentials({
    required String token,
    required String password,
  }) {
    resetCalls += 1;
    return completer.future;
  }

  @override
  Future<void> clearPersistedSession() => throw UnimplementedError();

  @override
  Future<void> persistSession(Session session) => throw UnimplementedError();

  @override
  Future<Session?> readPersistedSession() => throw UnimplementedError();

  @override
  Future<Result<Session>> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Failure?> signOut() => throw UnimplementedError();
}
