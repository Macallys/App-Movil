import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/core/error/failure.dart';
import 'package:safeplant_mobile/core/error/result.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/create_area.dart';
import 'package:safeplant_mobile/features/plant_setup/application/use_cases/get_area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_setup.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/area_thresholds.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_revocation.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/device_association.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/entities/industrial_area.dart';
import 'package:safeplant_mobile/features/plant_setup/domain/repositories/plant_setup_repository.dart';
import 'package:safeplant_mobile/features/plant_setup/presentation/providers/plant_setup_providers.dart';

void main() {
  test('create moves from loading to created', () async {
    final completer = Completer<Result<IndustrialArea>>();
    final container = _container(create: _PendingCreate(completer));
    addTearDown(container.dispose);
    container.listen(industrialAreaControllerProvider, (_, _) {});

    final pending = container
        .read(industrialAreaControllerProvider.notifier)
        .submit(name: 'Horno', location: 'Nave 1');

    expect(
      container.read(industrialAreaControllerProvider),
      isA<CreateAreaLoading>(),
    );

    completer.complete(
      const Success(
        IndustrialArea(id: 'area-1', name: 'Horno', location: 'Nave 1'),
      ),
    );
    await pending;

    final state = container.read(industrialAreaControllerProvider);
    expect(state, isA<CreateAreaCreated>());
    expect((state as CreateAreaCreated).area.id, 'area-1');
  });

  test('a duplicate name leaves the duplicate state', () async {
    final container = _container(
      create: _FixedCreate(const FailureResult(ConflictFailure())),
    );
    addTearDown(container.dispose);
    container.listen(industrialAreaControllerProvider, (_, _) {});

    await container
        .read(industrialAreaControllerProvider.notifier)
        .submit(name: 'Horno', location: 'Nave 1');

    expect(
      container.read(industrialAreaControllerProvider),
      isA<CreateAreaDuplicateName>(),
    );
  });

  test('setup moves from loading to data', () async {
    final completer = Completer<Result<AreaSetup>>();
    final container = _container(setup: _PendingSetup(completer));
    addTearDown(container.dispose);
    container.listen(areaSetupControllerProvider, (_, _) {});

    final pending = container
        .read(areaSetupControllerProvider.notifier)
        .load('area-1');

    expect(
      container.read(areaSetupControllerProvider),
      isA<AreaSetupLoading>(),
    );

    completer.complete(Success(_setup()));
    await pending;

    expect(container.read(areaSetupControllerProvider), isA<AreaSetupData>());
  });

  test('a missing area becomes notFound', () async {
    final container = _container(
      setup: _FixedSetup(const FailureResult(NotFoundFailure())),
    );
    addTearDown(container.dispose);
    container.listen(areaSetupControllerProvider, (_, _) {});

    await container.read(areaSetupControllerProvider.notifier).load('missing');

    expect(
      container.read(areaSetupControllerProvider),
      isA<AreaSetupNotFound>(),
    );
  });

  test('saved thresholds replace the limits on the current sheet', () async {
    final container = _container(setup: _FixedSetup(Success(_setup())));
    addTearDown(container.dispose);
    container.listen(areaSetupControllerProvider, (_, _) {});

    await container.read(areaSetupControllerProvider.notifier).load('area-1');
    container
        .read(areaSetupControllerProvider.notifier)
        .applyThresholds(
          const AreaThresholds(
            areaId: 'area-1',
            co2LimitPpm: 850.5,
            noiseLimitDb: 70,
          ),
        );

    final state = container.read(areaSetupControllerProvider) as AreaSetupData;
    expect(state.setup.name, 'Horno');
    expect(state.setup.co2LimitPpm, 850.5);
    expect(state.setup.noiseLimitDb, 70);
    expect(state.setup.devices, isEmpty);
  });
}

ProviderContainer _container({CreateArea? create, GetAreaSetup? setup}) {
  return ProviderContainer(
    overrides: [
      if (create != null) createAreaUseCaseProvider.overrideWithValue(create),
      if (setup != null) getAreaSetupUseCaseProvider.overrideWithValue(setup),
    ],
  );
}

class _PendingCreate extends CreateArea {
  _PendingCreate(this.completer) : super(_IdleRepository());

  final Completer<Result<IndustrialArea>> completer;

  @override
  Future<Result<IndustrialArea>> call({
    required String name,
    required String location,
  }) {
    return completer.future;
  }
}

class _FixedCreate extends CreateArea {
  _FixedCreate(this.result) : super(_IdleRepository());

  final Result<IndustrialArea> result;

  @override
  Future<Result<IndustrialArea>> call({
    required String name,
    required String location,
  }) async {
    return result;
  }
}

class _PendingSetup extends GetAreaSetup {
  _PendingSetup(this.completer) : super(_IdleRepository());

  final Completer<Result<AreaSetup>> completer;

  @override
  Future<Result<AreaSetup>> call({required String areaId}) {
    return completer.future;
  }
}

class _FixedSetup extends GetAreaSetup {
  _FixedSetup(this.result) : super(_IdleRepository());

  final Result<AreaSetup> result;

  @override
  Future<Result<AreaSetup>> call({required String areaId}) async {
    return result;
  }
}

class _IdleRepository implements PlantSetupRepository {
  @override
  Future<Result<IndustrialArea>> createArea({
    required String name,
    required String location,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<AreaSetup>> getAreaSetup({required String areaId}) {
    throw UnimplementedError();
  }

  @override
  Future<Result<AreaThresholds>> configureEnvironmentalThresholds({
    required String areaId,
    required num co2LimitPpm,
    required num noiseLimitDb,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Device>> issueDevice({
    required String deviceId,
    required String areaId,
    required DeviceKind kind,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<DeviceAssociation>> associateDeviceToArea({
    required String areaId,
    required String deviceId,
    required DeviceKind kind,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Device>>> listDevices() {
    throw UnimplementedError();
  }

  @override
  Future<Result<DeviceRevocation>> revokeDevice({required String deviceId}) {
    throw UnimplementedError();
  }
}

AreaSetup _setup() {
  return const AreaSetup(
    id: 'area-1',
    name: 'Horno',
    location: 'Nave 1',
    co2LimitPpm: 800,
    noiseLimitDb: null,
    devices: [],
  );
}
