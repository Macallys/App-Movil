import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/app/app.dart';
import 'package:safeplant_mobile/features/session/presentation/providers/session_providers.dart';

import 'support/memory_token_storage.dart';

void main() {
  testWidgets('Sign in page renders the login form', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Sign in requires email and password', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('El correo es obligatorio'), findsOneWidget);
    expect(find.text('La contraseña es obligatoria'), findsOneWidget);
  });

  testWidgets('sign in remains reachable at larger text scales', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 800));
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    for (final scale in [1.0, 1.3, 1.5]) {
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      await _pumpApp(tester);

      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [tokenStorageProvider.overrideWithValue(MemoryTokenStorage())],
      child: const SafePlantApp(),
    ),
  );
  await tester.pumpAndSettle();
}
