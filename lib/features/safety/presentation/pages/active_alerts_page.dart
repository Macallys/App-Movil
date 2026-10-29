import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/shared/widgets/safeplant_status_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/environmental_alert.dart';
import '../providers/safety_providers.dart';
import '../widgets/environmental_alert_card.dart';

class ActiveAlertsPage extends ConsumerStatefulWidget {
  const ActiveAlertsPage({this.areaId, super.key});

  final String? areaId;

  @override
  ConsumerState<ActiveAlertsPage> createState() => _ActiveAlertsPageState();
}

class _ActiveAlertsPageState extends ConsumerState<ActiveAlertsPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final controller = ref.read(activeAlertsControllerProvider.notifier);
      controller.load();
      controller.startPolling();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = ref.read(activeAlertsControllerProvider.notifier);
    switch (state) {
      case AppLifecycleState.resumed:
        controller.startPolling();
      case AppLifecycleState.inactive ||
          AppLifecycleState.paused ||
          AppLifecycleState.hidden ||
          AppLifecycleState.detached:
        controller.stopPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeAlertsControllerProvider);
    return switch (state) {
      ActiveAlertsInitial() ||
      ActiveAlertsLoading() => const Center(child: CircularProgressIndicator()),
      ActiveAlertsNetworkError() => _Status(
        message: 'No se pudo obtener las alertas activas.',
        onRetry: _reload,
      ),
      ActiveAlertsFailure() => _Status(
        message: 'No se pudo completar la solicitud.',
        onRetry: _reload,
      ),
      ActiveAlertsEmpty(:final refreshError) => _AlertsList(
        refreshError: refreshError,
        alerts: const [],
        onRefresh: _backgroundReload,
      ),
      ActiveAlertsData(:final alerts, :final refreshError) => _AlertsList(
        refreshError: refreshError,
        alerts: _visible(alerts),
        onRefresh: _backgroundReload,
      ),
    };
  }

  List<EnvironmentalAlert> _visible(List<EnvironmentalAlert> alerts) {
    final areaId = widget.areaId;
    final filtered = [
      for (final alert in alerts)
        if (areaId == null || alert.areaId == areaId) alert,
    ];
    // CLIENT-SIDE PRESENTATION DECISION.
    // The available contract does not define an order.
    filtered.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return filtered;
  }

  Future<void> _reload() {
    return ref.read(activeAlertsControllerProvider.notifier).load();
  }

  Future<void> _backgroundReload() {
    return ref
        .read(activeAlertsControllerProvider.notifier)
        .load(background: true);
  }
}

class _AlertsList extends StatelessWidget {
  const _AlertsList({
    required this.alerts,
    required this.refreshError,
    required this.onRefresh,
  });

  final List<EnvironmentalAlert> alerts;
  final bool refreshError;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: alerts.isEmpty ? 2 : alerts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alertas activas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (refreshError) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'No se pudo actualizar las alertas.',
                    style: TextStyle(color: AppColors.red),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
            );
          }
          if (alerts.isEmpty) {
            return const SafePlantStatusView(
              icon: Icons.notifications_none,
              message: 'No hay alertas activas.',
            );
          }
          final alert = alerts[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: EnvironmentalAlertCard(
              key: ValueKey(alert.alertId),
              alert: alert,
            ),
          );
        },
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return SafePlantStatusView(
      icon: Icons.error_outline,
      message: message,
      actionLabel: 'Reintentar',
      onAction: () {
        onRetry();
      },
    );
  }
}
