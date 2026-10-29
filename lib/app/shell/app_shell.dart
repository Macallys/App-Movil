import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
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
        title: const Text('SafePlant'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.white),
            onPressed: () {
              ref.read(sessionControllerProvider.notifier).signOut();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
