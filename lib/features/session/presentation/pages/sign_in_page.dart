import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/shared/widgets/safeplant_button_progress.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/session_providers.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (ref.read(sessionControllerProvider) is SessionLoading) {
      return;
    }
    await ref
        .read(sessionControllerProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionControllerProvider);
    final loading = state is SessionLoading;
    final message = switch (state) {
      SessionInvalidCredentials() => 'Credenciales inválidas',
      SessionForbidden() => 'Acceso no permitido',
      SessionExpired() => 'La sesión expiró',
      SessionNetworkError() => 'No hay conexión',
      SessionFailed() => 'No se pudo iniciar sesión',
      SessionAuthenticated() => 'Sesión iniciada',
      _ => null,
    };
    final messageColor = state is SessionAuthenticated
        ? Theme.of(context).colorScheme.onSurface
        : Theme.of(context).colorScheme.error;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandMark(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'MONITOREO INDUSTRIAL',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Tu planta segura,\nestés donde estés.',
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Ingresa a SafePlant con tus credenciales de equipo.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.slate,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Correo corporativo',
                              hintText: 'tu.nombre@empresa.com',
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.next,
                            enabled: !loading,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El correo es obligatorio';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Mostrar contraseña'
                                    : 'Ocultar contraseña',
                                onPressed: loading
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
                            autofillHints: const [AutofillHints.password],
                            enabled: !loading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La contraseña es obligatoria';
                              }
                              return null;
                            },
                          ),
                          if (message != null) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              message,
                              style: TextStyle(color: messageColor),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton(
                            onPressed: loading ? null : _submit,
                            child: loading
                                ? const SafePlantButtonProgress()
                                : const Text('Iniciar sesión'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: loading
                        ? null
                        : () {
                            context.push(RouteNames.recovery);
                          },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.shield_outlined, color: AppColors.white),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SafePlant',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                'BY MACALLYS',
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: AppColors.slate),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
