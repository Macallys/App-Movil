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
      appBar: AppBar(
        toolbarHeight: MediaQuery.textScalerOf(context).scale(kToolbarHeight),
        title: const Text(
          'Restablecer contraseña',
          maxLines: 2,
          style: TextStyle(height: 1.2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _tokenController,
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: const InputDecoration(
                            labelText: 'Código de recuperación',
                            prefixIcon: Icon(Icons.pin_outlined),
                            fillColor: AppColors.ice,
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
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            labelText: 'Nueva contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            fillColor: AppColors.ice,
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
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            labelText: 'Confirmar contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            fillColor: AppColors.ice,
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
            ),
          ),
        ),
      ),
    );
  }
}
