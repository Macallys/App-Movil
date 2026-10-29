import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/shared/widgets/safeplant_button_progress.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/session_providers.dart';

class ResetCredentialsPage extends ConsumerStatefulWidget {
  const ResetCredentialsPage({super.key});

  @override
  ConsumerState<ResetCredentialsPage> createState() =>
      _ResetCredentialsPageState();
}

class _ResetCredentialsPageState extends ConsumerState<ResetCredentialsPage> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  var _obscurePassword = true;
  var _obscureConfirm = true;

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    await ref
        .read(resetCredentialsControllerProvider.notifier)
        .submit(
          token: _tokenController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resetCredentialsControllerProvider);
    final loading = state is ResetCredentialsLoading;
    final completed = state is ResetCredentialsCompleted;
    final message = switch (state) {
      ResetCredentialsCompleted() => 'La contraseña fue restablecida.',
      ResetCredentialsValidationError() =>
        'El enlace o código de recuperación no es válido o ha expirado.',
      ResetCredentialsNetworkError() => 'No se pudo conectar con el servidor.',
      ResetCredentialsFailed() => 'No se pudo completar la solicitud.',
      _ => null,
    };
    final isError =
        state is ResetCredentialsValidationError ||
        state is ResetCredentialsNetworkError ||
        state is ResetCredentialsFailed;

    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer contraseña')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Código de recuperación',
                  ),
                  enabled: !loading && !completed,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El código es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: loading || completed
                          ? null
                          : () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  enabled: !loading && !completed,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La contraseña es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _confirmController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    suffixIcon: IconButton(
                      tooltip: _obscureConfirm
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: loading || completed
                          ? null
                          : () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  obscureText: _obscureConfirm,
                  enabled: !loading && !completed,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirma la contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
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
                if (completed)
                  FilledButton(
                    onPressed: () {
                      context.go(RouteNames.signIn);
                    },
                    child: const Text('Ir a iniciar sesión'),
                  )
                else
                  FilledButton(
                    key: const Key('resetSubmitButton'),
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SafePlantButtonProgress()
                        : const Text('Restablecer contraseña'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
