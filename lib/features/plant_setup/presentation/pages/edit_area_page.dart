import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/shared/widgets/safeplant_button_progress.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/plant_setup_providers.dart';

class EditAreaPage extends ConsumerStatefulWidget {
  const EditAreaPage({
    required this.areaId,
    required this.initialName,
    required this.initialLocation,
    super.key,
  });

  final String areaId;
  final String initialName;
  final String initialLocation;

  @override
  ConsumerState<EditAreaPage> createState() => _EditAreaPageState();
}

class _EditAreaPageState extends ConsumerState<EditAreaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _locationController = TextEditingController(text: widget.initialLocation);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(updateAreaControllerProvider.notifier).reset();
    });
  }

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
        .read(updateAreaControllerProvider.notifier)
        .submit(
          areaId: widget.areaId,
          name: _nameController.text.trim(),
          location: _locationController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(updateAreaControllerProvider, (previous, next) {
      if (next is UpdateAreaSaved) {
        ref
            .read(areaSetupControllerProvider.notifier)
            .applyIdentity(name: next.area.name, location: next.area.location);
        context.pop();
      }
    });
    final state = ref.watch(updateAreaControllerProvider);
    final loading = state is UpdateAreaLoading;
    final message = switch (state) {
      UpdateAreaDuplicateName() => 'Ya existe un área con ese nombre.',
      UpdateAreaNotFound() => 'El área ya no se encuentra disponible.',
      UpdateAreaNetworkError() => 'No se pudo conectar con el servidor.',
      UpdateAreaFailure() => 'No se pudo completar la solicitud.',
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Editar área')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
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
                    : const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
