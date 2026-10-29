import 'iso_date_time.dart';

class PresenceReadingDto {
  const PresenceReadingDto({
    required this.deviceId,
    required this.state,
    required this.recordedAt,
  });

  factory PresenceReadingDto.fromJson(Map<String, dynamic> json) {
    final state = json['state'];
    final deviceId = json['deviceId'];
    if (deviceId is! String || deviceId.isEmpty) {
      throw const FormatException('Unexpected deviceId');
    }
    if (state is! String || state.isEmpty) {
      throw const FormatException('Unexpected state');
    }
    return PresenceReadingDto(
      deviceId: deviceId,
      state: state,
      recordedAt: parseIsoDateTime(json['recordedAt'], 'recordedAt'),
    );
  }

  final String deviceId;
  final String state;
  final DateTime recordedAt;
}
