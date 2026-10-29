import '../../../../core/error/result.dart';
import '../../domain/entities/latest_readings.dart';
import '../../domain/repositories/safety_repository.dart';

class GetLatestReadings {
  const GetLatestReadings(this._repository);

  final SafetyRepository _repository;

  Future<Result<LatestReadings>> call({required String areaId}) {
    return _repository.getLatestReadings(areaId: areaId);
  }
}
