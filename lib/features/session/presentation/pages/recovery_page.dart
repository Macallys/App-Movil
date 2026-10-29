import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/shared/widgets/safeplant_button_progress.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/session_providers.dart';

class RecoveryPage extends ConsumerStatefulWidget {
  const RecoveryPage({super.key});

  @override
  ConsumerState<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends ConsumerState<RecoveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    await ref
        .read(recoveryRequestControllerProvider.notifier)
        .submit(email: _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recoveryRequestControllerProvider);
    final loading = state is RecoveryLoading;
    final message = switch (state) {
      RecoveryRequested() =>
        'Revisa tu correo para continuar con la recuperación.',
      RecoveryNetworkError() => 'No se pudo conectar con el servidor.',
      RecoveryFailed() => 'No se pudo completar la solicitud.',
      _ => null,
    };
    final isError = state is RecoveryNetworkError || state is RecoveryFailed;

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar acceso')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !loading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El correo es obligatorio';
                    }
                    return null;
                  },
                ),
                if (message != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    message,
                    style: TextStyle(
                      color: isError ? AppColors.red : AppColors.navy,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  key: const Key('recoverySubmitButton'),
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SafePlantButtonProgress()
                      : const Text('Recuperar acceso'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () {
                    context.push(RouteNames.reset);
                  },
                  child: const Text('Ya tengo un código'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
