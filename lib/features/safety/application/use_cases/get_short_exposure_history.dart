import '../../../../core/error/result.dart';
import '../../domain/entities/exposure.dart';
import '../../domain/repositories/safety_repository.dart';

class GetShortExposureHistory {
  const GetShortExposureHistory(this._repository);

  final SafetyRepository _repository;

  Future<Result<List<Exposure>>> call({required String areaId}) {
    return _repository.getShortExposureHistory(areaId: areaId);
  }
}
