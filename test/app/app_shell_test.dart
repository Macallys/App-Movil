import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/app/app.dart';
import 'package:safeplant_mobile/features/session/application/use_cases/restore_session.dart';
import 'package:safeplant_mobile/features/session/domain/entities/session.dart';
import 'package:safeplant_mobile/features/session/presentation/providers/session_providers.dart';

import '../support/scripted_session.dart';

void main() {
  testWidgets('shell opens Safety and Plant Setup and keeps the session', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          restoreSessionUseCaseProvider.overrideWithValue(
            ScriptedRestore(SessionRestored(_supervisor)),
          ),
        ],
        child: const SafePlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('safetyHome')), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(NavigationBar)),
    );
    final before = container.read(sessionControllerProvider);

    await tester.tap(find.text('Plant Setup'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('plantSetupHome')), findsOneWidget);
    expect(find.byKey(const Key('safetyHome')), findsNothing);
    expect(container.read(sessionControllerProvider), same(before));
    expect(before, isA<SessionAuthenticated>());

    await tester.tap(find.text('Safety'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('safetyHome')), findsOneWidget);
    expect(container.read(sessionControllerProvider), same(before));
  });

  testWidgets('plant setup home opens create area inside the shell', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          restoreSessionUseCaseProvider.overrideWithValue(
            ScriptedRestore(SessionRestored(_supervisor)),
          ),
        ],
        child: const SafePlantApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Plant Setup'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nueva área'));
    await tester.pumpAndSettle();

    expect(find.text('Nombre del área'), findsOneWidget);
    expect(find.text('Crear área'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });
}

final _supervisor = Session(
  accessToken: 'token',
  role: UserRole.supervisor,
  expiresAt: DateTime.utc(2099),
);
