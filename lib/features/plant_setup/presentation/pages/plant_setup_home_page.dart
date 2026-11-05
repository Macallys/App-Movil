import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/plant_setup_visuals.dart';

class PlantSetupHomePage extends StatelessWidget {
  const PlantSetupHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('plantSetupHome'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      children: [
        PlantSetupIconLine(
          icon: Icons.factory_outlined,
          child: Text(
            'Plant Setup',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Áreas y dispositivos de la planta.',
          style: Theme.of(context).textTheme.bodyMedium,
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
