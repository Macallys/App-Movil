import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/session/presentation/providers/session_providers.dart';
import '../router/route_names.dart';

class AppShell extends ConsumerWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = location.startsWith(RouteNames.plantSetup) ? 1 : 0;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.textScalerOf(context).scale(kToolbarHeight),
        shape: const Border(bottom: BorderSide(color: AppColors.lightBlue)),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final showMark =
                constraints.maxWidth >=
                MediaQuery.textScalerOf(context).scale(160);
            return Row(
              children: [
                if (showMark) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(AppRadius.control),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      child: Icon(
                        Icons.shield_outlined,
                        color: AppColors.cyan,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    'SafePlant',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.navy),
            onPressed: () {
              ref.read(sessionControllerProvider.notifier).signOut();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.lightBlue)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.health_and_safety_outlined),
              selectedIcon: Icon(Icons.health_and_safety),
              label: 'Safety',
            ),
            NavigationDestination(
              icon: Icon(Icons.factory_outlined),
              selectedIcon: Icon(Icons.factory),
              label: 'Plant Setup',
            ),
          ],
          onDestinationSelected: (index) {
            context.go(index == 0 ? RouteNames.safety : RouteNames.plantSetup);
          },
        ),
      ),
    );
  }
}
