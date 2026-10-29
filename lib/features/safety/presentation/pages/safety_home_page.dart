import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/shared/widgets/safeplant_status_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/safety_providers.dart';
import '../widgets/area_operational_status_card.dart';
import 'safety_area_detail_page.dart';

class SafetyHomePage extends ConsumerStatefulWidget {
  const SafetyHomePage({super.key});

  @override
  ConsumerState<SafetyHomePage> createState() => _SafetyHomePageState();
}

class _SafetyHomePageState extends ConsumerState<SafetyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final current = ref.read(safetyDashboardControllerProvider);
      if (current is SafetyDashboardData || current is SafetyDashboardEmpty) {
        return;
      }
      ref.read(safetyDashboardControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(safetyDashboardControllerProvider);
    return KeyedSubtree(
      key: const Key('safetyHome'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.push(RouteNames.activeAlerts),
              child: const Text('Alertas activas'),
            ),
          ),
          Expanded(
            child: switch (state) {
              SafetyDashboardInitial() || SafetyDashboardLoading() =>
                const Center(child: CircularProgressIndicator()),
              SafetyDashboardEmpty() => RefreshIndicator(
                onRefresh: () {
                  return ref
                      .read(safetyDashboardControllerProvider.notifier)
                      .load(refresh: true);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: const [
                    _DashboardHeading(alertCount: 0, areaCount: 0),
                    SizedBox(height: AppSpacing.lg),
                    SafePlantStatusView(
                      icon: Icons.inbox_outlined,
                      message: 'No hay información operativa disponible.',
                    ),
                  ],
                ),
              ),
              SafetyDashboardUnauthorized() => SafePlantStatusView(
                icon: Icons.lock_outline,
                message: 'La sesión no permite consultar el estado operativo.',
                actionLabel: 'Reintentar',
                onAction: _retry,
              ),
              SafetyDashboardNetworkError() => SafePlantStatusView(
                icon: Icons.wifi_off,
                message: 'No se pudo obtener el estado operativo.',
                actionLabel: 'Reintentar',
                onAction: _retry,
              ),
              SafetyDashboardFailure() => SafePlantStatusView(
                icon: Icons.error_outline,
                message: 'No se pudo completar la solicitud.',
                actionLabel: 'Reintentar',
                onAction: _retry,
              ),
              SafetyDashboardData(:final areas, :final refreshError) =>
                RefreshIndicator(
                  onRefresh: () {
                    return ref
                        .read(safetyDashboardControllerProvider.notifier)
                        .load(refresh: true);
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: areas.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DashboardHeading(
                              areaCount: areas.length,
                              alertCount: areas
                                  .where((area) => area.alertActive)
                                  .length,
                            ),
                            if (refreshError) ...[
                              const SizedBox(height: AppSpacing.md),
                              const Text(
                                'No se pudo obtener el estado operativo.',
                                style: TextStyle(color: AppColors.red),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      }
                      final area = areas[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: AreaOperationalStatusCard(
                          key: ValueKey(area.areaId),
                          status: area,
                          onOpen: () => openSafetyArea(context, area),
                        ),
                      );
                    },
                  ),
                ),
            },
          ),
        ],
      ),
    );
  }

  Future<void> _retry() {
    return ref.read(safetyDashboardControllerProvider.notifier).load();
  }
}

class _DashboardHeading extends StatelessWidget {
  const _DashboardHeading({required this.areaCount, required this.alertCount});

  final int areaCount;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado operativo',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(alertCount > 0 ? 'Hay alertas activas' : 'Sin alertas activas'),
        Text('Áreas: $areaCount'),
      ],
    );
  }
}
