import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/actuator_action.dart';
import '../../../../core/shared/widgets/safeplant_status_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/safety_providers.dart';
import '../widgets/actuator_action_list_item.dart';

class ActuatorActionsPage extends ConsumerStatefulWidget {
  const ActuatorActionsPage({required this.areaId, super.key});

  final String areaId;

  @override
  ConsumerState<ActuatorActionsPage> createState() =>
      _ActuatorActionsPageState();
}

class _ActuatorActionsPageState extends ConsumerState<ActuatorActionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(actuatorActionsControllerProvider.notifier).load(widget.areaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(actuatorActionsControllerProvider);
    return switch (state) {
      ActuatorActionsInitial() || ActuatorActionsLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      ActuatorActionsNetworkError() => _Status(
        message: 'No se pudo obtener la actividad de actuadores.',
        onRetry: _reload,
      ),
      ActuatorActionsFailure() => _Status(
        message: 'No se pudo completar la solicitud.',
        onRetry: _reload,
      ),
      ActuatorActionsEmpty(:final refreshError) => _ActionsList(
        actions: const [],
        refreshError: refreshError,
        onRefresh: _refresh,
      ),
      ActuatorActionsData(:final actions, :final refreshError) => _ActionsList(
        actions: _recentFirst(actions),
        refreshError: refreshError,
        onRefresh: _refresh,
      ),
    };
  }

  List<ActuatorAction> _recentFirst(List<ActuatorAction> actions) {
    final ordered = [...actions];
    // CLIENT-SIDE PRESENTATION DECISION.
    // The available contract does not define an order.
    ordered.sort((a, b) => b.executedAt.compareTo(a.executedAt));
    return ordered;
  }

  Future<void> _reload() {
    return ref
        .read(actuatorActionsControllerProvider.notifier)
        .load(widget.areaId);
  }

  Future<void> _refresh() {
    return ref
        .read(actuatorActionsControllerProvider.notifier)
        .load(widget.areaId, refresh: true);
  }
}

class _ActionsList extends StatelessWidget {
  const _ActionsList({
    required this.actions,
    required this.refreshError,
    required this.onRefresh,
  });

  final List<ActuatorAction> actions;
  final bool refreshError;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: actions.isEmpty ? 2 : actions.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actividad de actuadores',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (refreshError) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'No se pudo actualizar la actividad de actuadores.',
                    style: TextStyle(color: AppColors.red),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
            );
          }
          if (actions.isEmpty) {
            return const SafePlantStatusView(
              icon: Icons.playlist_remove,
              message: 'No hay acciones recientes de actuadores.',
            );
          }
          final action = actions[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ActuatorActionListItem(
              key: ValueKey(action.actionId),
              action: action,
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
