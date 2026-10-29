import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/session/presentation/providers/session_providers.dart';
import 'router/app_router.dart';

class SafePlantApp extends ConsumerStatefulWidget {
  const SafePlantApp({super.key});

  @override
  ConsumerState<SafePlantApp> createState() => _SafePlantAppState();
}

class _SafePlantAppState extends ConsumerState<SafePlantApp> {
  final ThemeData _theme = AppTheme.light();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(sessionControllerProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SafePlant',
      theme: _theme,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
