import 'package:flutter_test/flutter_test.dart';
import 'package:safeplant_mobile/features/safety/data/dtos/latest_readings_dto.dart';

void main() {
  test('parses three independent readings', () {
    final dto = LatestReadingsDto.fromJson(_json());

    expect(dto.areaId, 'area-1');
    expect(dto.carbonDioxide?.deviceId, 'co2-1');
    expect(dto.carbonDioxide?.ppm, 810);
    expect(dto.noise?.deviceId, 'noise-1');
    expect(dto.noise?.db, 85);
    expect(dto.presence?.deviceId, 'presence-1');
    expect(dto.presence?.state, 'Cleared');
  });

  test('keeps distinct timestamps and device ids', () {
    final dto = LatestReadingsDto.fromJson(_json());

    expect(dto.carbonDioxide?.recordedAt, isNot(dto.noise?.recordedAt));
    expect(dto.noise?.recordedAt, isNot(dto.presence?.recordedAt));
    expect(dto.carbonDioxide?.deviceId, isNot(dto.noise?.deviceId));
    expect(dto.noise?.deviceId, isNot(dto.presence?.deviceId));
  });

  test('a null carbon dioxide section stays null', () {
    final dto = LatestReadingsDto.fromJson(_json(carbonDioxide: null));

    expect(dto.carbonDioxide, isNull);
    expect(dto.noise?.db, 85);
    expect(dto.presence?.state, 'Cleared');
  });

  test('a null noise section stays null', () {
    final dto = LatestReadingsDto.fromJson(_json(noise: null));

    expect(dto.noise, isNull);
    expect(dto.carbonDioxide?.ppm, 810);
  });

  test('a null presence section stays null', () {
    final dto = LatestReadingsDto.fromJson(_json(presence: null));

    expect(dto.presence, isNull);
    expect(dto.carbonDioxide?.deviceId, 'co2-1');
  });

  test('all null sections stay null', () {
    final dto = LatestReadingsDto.fromJson(const {
      'areaId': 'area-1',
      'carbonDioxide': null,
      'noise': null,
      'presence': null,
    });

    expect(dto.areaId, 'area-1');
    expect(dto.carbonDioxide, isNull);
    expect(dto.noise, isNull);
    expect(dto.presence, isNull);
  });

  test('decimal noise is rejected', () {
    expect(
      () => LatestReadingsDto.fromJson(_json(noise: {
        'deviceId': 'noise-1',
        'db': 85.5,
        'recordedAt': '2026-05-20T15:33:00Z',
      })),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> _json({
  Object? carbonDioxide = _present,
  Object? noise = _present,
  Object? presence = _present,
}) {
  return {
    'areaId': 'area-1',
    'carbonDioxide': identical(carbonDioxide, _present)
        ? {
            'deviceId': 'co2-1',
            'ppm': 810,
            'recordedAt': '2026-05-20T15:35:00Z',
          }
        : carbonDioxide,
    'noise': identical(noise, _present)
        ? {
            'deviceId': 'noise-1',
            'db': 85,
            'recordedAt': '2026-05-20T15:33:00Z',
          }
        : noise,
    'presence': identical(presence, _present)
        ? {
            'deviceId': 'presence-1',
            'state': 'Cleared',
            'recordedAt': '2026-05-20T15:36:00Z',
          }
        : presence,
  };
}

const _present = Object();
