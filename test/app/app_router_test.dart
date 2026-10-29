import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/app/app.dart';
import 'package:safeplant_mobile/app/shell/app_shell.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/restore_session.dart';
import 'package:safeplant_mobile/features/session/domain/entities/session.dart';
import 'package:safeplant_mobile/features/session/presentation/providers/session_providers.dart';

import '../support/scripted_session.dart';

void main() {
  testWidgets('unauthenticated session opens Sign In', (tester) async {
    await _pump(tester, const NoPersistedSession());

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets('authenticated supervisor opens the app shell', (tester) async {
    await _pump(tester, SessionRestored(_supervisor));

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byKey(const Key('safetyHome')), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNothing);
  });

  testWidgets('expired session opens Sign In', (tester) async {
    await _pump(tester, const SessionExpiredOutcome());

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('La sesión expiró'), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets('PlantManager does not enter the app shell', (tester) async {
    await _pump(tester, const SessionNotAllowed());

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Acceso no permitido'), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets('sign out returns to Sign In', (tester) async {
    await _pump(tester, SessionRestored(_supervisor), signOut: QuietSignOut());

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets('Android back from the shell does not open Sign In', (
    tester,
  ) async {
    await _pump(tester, SessionRestored(_supervisor));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsNothing);
  });

  testWidgets('unexpected restore failure can be retried', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          restoreSessionUseCaseProvider.overrideWithValue(ThrowingRestore()),
        ],
        child: const SafePlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No se pudo iniciar la aplicación.'), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });
}

final _supervisor = Session(
  accessToken: 'token',
  role: UserRole.supervisor,
  expiresAt: DateTime.utc(2099),
);

Future<void> _pump(
  WidgetTester tester,
  RestoreSessionOutcome outcome, {
  QuietSignOut? signOut,
}) {
  return tester
      .pumpWidget(
        ProviderScope(
          overrides: [
            restoreSessionUseCaseProvider.overrideWithValue(
              ScriptedRestore(outcome),
            ),
            if (signOut != null)
              signOutUseCaseProvider.overrideWithValue(signOut),
          ],
          child: const SafePlantApp(),
        ),
      )
      .then((_) => tester.pumpAndSettle());
}
