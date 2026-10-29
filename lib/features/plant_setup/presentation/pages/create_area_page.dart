import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/safeplant_button_progress.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../app/router/route_names.dart';
import '../providers/plant_setup_providers.dart';

class CreateAreaPage extends ConsumerStatefulWidget {
  const CreateAreaPage({super.key});

  @override
  ConsumerState<CreateAreaPage> createState() => _CreateAreaPageState();
}

class _CreateAreaPageState extends ConsumerState<CreateAreaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    await ref
        .read(industrialAreaControllerProvider.notifier)
        .submit(
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(industrialAreaControllerProvider);
    final loading = state is CreateAreaLoading;
    final created = state is CreateAreaCreated ? state.area : null;
    final message = switch (state) {
      CreateAreaDuplicateName() => 'Ya existe un área con ese nombre.',
      CreateAreaUnauthorized() => 'Acceso no permitido',
      CreateAreaNetworkError() => 'No se pudo conectar con el servidor.',
      CreateAreaFailure() => 'No se pudo completar la solicitud.',
      _ => null,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: created == null
          ? Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nueva área',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del área',
                    ),
                    textInputAction: TextInputAction.next,
                    enabled: !loading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Ubicación'),
                    textInputAction: TextInputAction.done,
                    enabled: !loading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La ubicación es obligatoria';
                      }
                      return null;
                    },
                  ),
                  if (message != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(message, style: const TextStyle(color: AppColors.red)),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SafePlantButtonProgress()
                        : const Text('Crear área'),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Área creada',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(created.name),
                const SizedBox(height: AppSpacing.sm),
                Text(created.location),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () {
                    context.push(RouteNames.areaSetup(created.id));
                  },
                  child: const Text('Ver ficha'),
                ),
              ],
            ),
    );
  }
}
