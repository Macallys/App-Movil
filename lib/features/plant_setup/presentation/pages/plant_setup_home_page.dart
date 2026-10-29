import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';

class PlantSetupHomePage extends StatelessWidget {
  const PlantSetupHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('plantSetupHome'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Plant Setup', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Áreas y dispositivos de la planta.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: () => context.push(RouteNames.createArea),
          icon: const Icon(Icons.add),
          label: const Text('Nueva área'),
        ),
        const SizedBox(height: AppSpacing.md),
        FilledButton.icon(
          onPressed: () => context.push(RouteNames.deviceInventory),
          icon: const Icon(Icons.devices_outlined),
          label: const Text('Inventario de dispositivos'),
        ),
      ],
    );
  }
}
