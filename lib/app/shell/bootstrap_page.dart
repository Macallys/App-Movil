import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/session/presentation/providers/session_providers.dart';
import '../../core/theme/app_spacing.dart';

class BootstrapPage extends ConsumerWidget {
  const BootstrapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failed = ref.watch(sessionControllerProvider) is SessionFailed;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: failed
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No se pudo iniciar la aplicación.',
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () {
                        ref
                            .read(sessionControllerProvider.notifier)
                            .restoreSession();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppSpacing.md),
                    Text('SafePlant', style: textTheme.titleLarge),
                  ],
                ),
        ),
      ),
    );
  }
}
