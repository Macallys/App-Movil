import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/exposure.dart';
import '../../../../core/shared/widgets/safeplant_status_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/safety_providers.dart';
import '../widgets/exposure_list_item.dart';

class ShortExposureHistoryPage extends ConsumerStatefulWidget {
  const ShortExposureHistoryPage({required this.areaId, super.key});

  final String areaId;

  @override
  ConsumerState<ShortExposureHistoryPage> createState() =>
      _ShortExposureHistoryPageState();
}

class _ShortExposureHistoryPageState
    extends ConsumerState<ShortExposureHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(exposureHistoryControllerProvider.notifier).load(widget.areaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exposureHistoryControllerProvider);
    return switch (state) {
      ExposureHistoryInitial() || ExposureHistoryLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      ExposureHistoryNetworkError() => _Status(
        message: 'No se pudo obtener la exposición reciente.',
        onRetry: _reload,
      ),
      ExposureHistoryFailure() => _Status(
        message: 'No se pudo completar la solicitud.',
        onRetry: _reload,
      ),
      ExposureHistoryEmpty(:final refreshError) => _HistoryList(
        exposures: const [],
        refreshError: refreshError,
        onRefresh: _refresh,
      ),
      ExposureHistoryData(:final exposures, :final refreshError) =>
        _HistoryList(
          exposures: _recentFirst(exposures),
          refreshError: refreshError,
          onRefresh: _refresh,
        ),
    };
  }

  List<Exposure> _recentFirst(List<Exposure> exposures) {
    final ordered = [...exposures];
    // CLIENT-SIDE PRESENTATION DECISION.
    // The available contract does not define an order.
    ordered.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return ordered;
  }

  Future<void> _reload() {
    return ref
        .read(exposureHistoryControllerProvider.notifier)
        .load(widget.areaId);
  }

  Future<void> _refresh() {
    return ref
        .read(exposureHistoryControllerProvider.notifier)
        .load(widget.areaId, refresh: true);
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.exposures,
    required this.refreshError,
    required this.onRefresh,
  });

  final List<Exposure> exposures;
  final bool refreshError;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: exposures.isEmpty ? 2 : exposures.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exposición reciente',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (refreshError) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'No se pudo actualizar la exposición reciente.',
                    style: TextStyle(color: AppColors.red),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
            );
          }
          if (exposures.isEmpty) {
            return const SafePlantStatusView(
              icon: Icons.history,
              message: 'No hay exposiciones recientes registradas.',
            );
          }
          final exposure = exposures[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ExposureListItem(
              key: ValueKey(exposure.exposureId),
              exposure: exposure,
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
